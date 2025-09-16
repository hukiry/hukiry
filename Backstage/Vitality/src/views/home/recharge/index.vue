<template>
  <div class="app-container">
    <div class="filter-container">
      <!-- <el-input v-model="listQuery.title" placeholder="标题" style="width: 200px;" class="filter-item" @keyup.enter.native="handleFilter" /> -->
      <el-select v-model="listQuery.state" placeholder="日期查询" clearable style="width: 150px" class="filter-item"  @change="selectStateTime()">
        <el-option v-for="item in stateOptions" :key="item.key" :label="item.label" :value="item.key"/>
      </el-select>
      <el-badge class="filter-item">
        <el-date-picker v-show="listQuery.state!=0" v-model="selectDate" style="width:150px;" :picker-options="pickerOptionsStart" 
        type="date" value-format="yyyy-MM-dd" placeholder="选择日期"  @change="selectStateTime()"/>
      </el-badge>

      <el-button v-waves class="filter-item" type="primary" icon="el-icon-search" @click="getList"> 搜索 </el-button>
      <el-button v-waves :loading="downloadLoading" class="filter-item" type="primary" icon="el-icon-download" @click="handleDownload"> 导出 </el-button>
    </div>

    <el-table
      :key="tableKey"
      v-loading="listLoading"
      :data="list"
      fit
      highlight-current-row
      style="width: 100%;"
      @sort-change="sortChange"
      border
    >
      <el-table-column label="ID" prop="id" sortable="custom" width="80" >
        <template slot-scope="{row}">
          <span>{{ row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="商品ID">
        <template slot-scope="{row}">
          <span>{{ row.shopId }}</span>
        </template>
      </el-table-column>
      <el-table-column label="充值累计">
        <template slot-scope="{row}">
          <span>{{ row.total }}</span>
        </template>
      </el-table-column>
      <el-table-column label="最新充值价格">
        <template slot-scope="{row}">
          <span>{{ row.price}}</span>
        </template>
      </el-table-column>
      <el-table-column label="充值时间">
        <template slot-scope="{row}">
          <span>{{ row.t}}</span>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="listQuery.page" :limit.sync="listQuery.limit" @pagination="getList" />
  </div>
</template>

<script>
// getTextTime(row.createTime,"{y}年{m}月{d}日 {h}时{i}分{s}秒")
import waves from '@/directive/waves' // waves directive
import { parseTime } from '@/utils'
import Pagination from '@/components/Pagination' // secondary package based on el-pagination
import axiosRE from 'axios'
import {getGameInfos} from '@/api/game'
import { date } from 'jszip/lib/defaults'

const RECHARGE_TYPE = 2

export default {
  name: 'ComplexTable',
  components: { Pagination },
  directives: { waves },
  filters: {
    statusFilter(status) {
      const statusMap = {
        published: 'success',
        draft: 'info',
        deleted: 'danger'
      }
      return statusMap[status]
    }
  },
  data() {
    return {
      tableKey: 0,
      list: null,
      total: 0,
      listLoading: true,
      selectDate:new Date(),
      listQuery: {
        page: 1,
        limit: 20,
        timestamp: 0,
        state: 0, // 1=查询日登陆，2=查询日注册, 3=查询月登陆，4=查询月注册
        type: 0// 数据查询类型
      },
      stateOptions: [
        { label: '查询全部', key: 0 },
        { label: '按每日查询', key: 1 },
        { label: '按每月查询', key: 3 },
      ],
      downloadLoading: false,

      pickerOptionsStart: {
        disabledDate: time => {
          return false
        }
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.listLoading = true
      getGameInfos(this.listQuery, RECHARGE_TYPE).then(response => {
        if(response.items.length>0)
        {
          this.list = response.items[0].chargeData
          this.total = this.list.length
        }
        setTimeout(() => {
          this.listLoading = false
        }, 500)
      
      })
    },

    selectStateTime() {
      this.listQuery.timestamp = parseInt(new Date(this.selectDate).getTime() / 1000)
      // console.log("selectStateTime timestamp:"+this.listQuery.timestamp)
    },

    sortChange(data) {
      const { prop } = data
      if (prop === 'roleID') {
        this.getList()
      }
    },

    handleDownload() {
      this.downloadLoading = true
      import('@/vendor/Export2Excel').then(excel => {
        // 导出excal数据的字段
        const tHeader = ['timestamp', 'title', 'platform']
        const filterVal = ['timestamp', 'title', 'platform']
        const data = this.formatJson(filterVal)
        excel.export_json_to_excel({
          header: tHeader,
          data,
          filename: 'table-list'
        })
        this.downloadLoading = false
      })
    },
    getAddressByIP(row) {
      const address = row.ipAddress.split(':')[0]
      axiosRE.get(`https://qifu-api.baidubce.com/ip/geo/v1/district?ip=${address}`)
        .then(response => {
          const data = response.data.data
          const areaData = `${data.country} ${data.prov} ${data.city}`
          if (areaData.trim().length === 0) {
            this.$message({
              type: 'warning',
              message: '查询数据失败!'
            })
            return
          }
          row.ipAddress = address + ':' + areaData
        })
        .catch(error => {
          console.log(error)
        })
    },
    getTextTime(t, s) {
      
      return parseTime(t, s)
    },
    formatJson(filterVal) {
      // 导出excal数据的字段
      return this.list.map(v => filterVal.map(j => {
        if (j === 'timestamp') {
          return parseTime(v[j])
        } else {
          return v[j]
        }
      }))
    }
  }
}
</script>
