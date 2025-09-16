<template>
  <div class="app-container">
    <div class="filter-container">
      <!-- <el-input v-model="listQuery.title" placeholder="标题" style="width: 200px;" class="filter-item" @keyup.enter.native="handleFilter" /> -->
      <el-select v-model="listQuery.state" placeholder="日期查询" clearable style="width: 150px" class="filter-item"  @change="selectStateTime()">
        <el-option v-for="item in stateOptions" :key="item.key" :label="item.label" :value="item.key" />
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
      <el-table-column label="ID" prop="id" sortable="custom" width="80">
        <template slot-scope="{row}">
          <span>{{ row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="设备码">
        <template slot-scope="{row}">
          <span>{{ row.deviceId }}</span>
        </template>
      </el-table-column>
      <el-table-column label="账号类型">
        <template slot-scope="{row}">
          <span>{{ getBindAccountText(row.bindAccount) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="是绑定账号">
        <template slot-scope="{row}">
          <span>{{ row.token===""?'否':'是' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="语言代码">
        <template slot-scope="{row}">
          <span>{{ row.lanCode }}</span>
        </template>
      </el-table-column>
      <el-table-column label="注册时间" width="150px" align="center">
        <template slot-scope="{row}">
          <span>{{ row.createTime | parseTime('{y}-{m}-{d} {h}:{i}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="登陆时间" width="150px" align="center">
        <template slot-scope="{row}">
          <span>{{ row.expirateTime | parseTime('{y}-{m}-{d} {h}:{i}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="昵称">
        <template slot-scope="{row}">
          <span>{{ row.roleNick }}</span>
        </template>
      </el-table-column>
      <el-table-column label="IP地址">
        <template slot-scope="{row}">
          <span>{{ row.ipAddress }}</span>
          <el-button v-show="true" type="primary" size="small" @click="getAddressByIP(row)">查询地址</el-button>
        </template>
      </el-table-column>
      <el-table-column label="金币">
        <template slot-scope="{row}">
          <span>{{ getMoney(row.items, 9) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="关卡">
        <template slot-scope="{row}">
          <span>{{ getMoney(row.items, 15) }}</span>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="listQuery.page" :limit.sync="listQuery.limit" @pagination="getList" />
  </div>
</template>

<script>
import waves from '@/directive/waves' // waves directive
import { parseTime } from '@/utils'
import Pagination from '@/components/Pagination' // secondary package based on el-pagination
import axiosRE from 'axios'
import {getGameInfos} from '@/api/game'
import { date } from 'jszip/lib/defaults'

// const defaultRole = {
//   roleId: 0, // 角色id （开发：1到10000；发布，10001以上）
//   deviceId: '', // 设备唯一标示符
//   token: '', // 用户
//   lanCode: '', // 语言代码
//   regeditTime: 0, // 注册时间
//   loginTime: 0, // 登陆时间
//   roleNick: '',
//   ipAddress: '',
//   coinNum: 0, // 金币
//   level: 0,
//   jsonItem: 0,
// }

const ROLE_TYPE = 1

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
        { label: '按每日登陆查询', key: 1 },
        { label: '按每日注册查询', key: 2 },
        { label: '按每月登陆查询', key: 3 },
        { label: '按每月注册查询', key: 4 }
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
      getGameInfos(this.listQuery, ROLE_TYPE).then(response => {
        this.list = response.items
        this.total = this.list.length
        setTimeout(() => {
          this.listLoading = false
        }, 500)
      })
    },

    selectStateTime() {
      this.listQuery.timestamp = parseInt(new Date(this.selectDate).getTime() / 1000)
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
      //https://qifu-api.baidubce.com/ip/geo/v1/district?ip=183.48.26.13
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
    formatJson(filterVal) {
      // 导出excal数据的字段
      return this.list.map(v => filterVal.map(j => {
        if (j === 'timestamp') {
          return parseTime(v[j])
        } else {
          return v[j]
        }
      }))
    },
    getBindAccountText(account)
    {
      if(account==1)
      {
        return "Apple"
      }else if(account==2)
      {
        return "Google"
      }
      return "游客"
    },
    getMoney(items, type)
    {
        for (const key in items) {
          if (items[key].type == type) {
            return items[key].number
          }
        }
        return 0;
    }
  }
}
</script>

<!--
  {"code":"Success",
  "data":{
    "continent":"亚洲",
  "country":"中国",
  "zipcode":"510010",
  "timezone":"UTC+8",
  "accuracy":"区县",
  "owner":"中国电信",
  "isp":"中国电信",
  "source":"数据挖掘",
  "areacode":"CN",
  "adcode":"440111",
  "asnumber":"4134",
  "lat":"23.291296",
  "lng":"113.319325",
  "radius":"21.9706",
  "prov":"广东省",
  "city":"广州市",
  "district":"白云区"
},"charge":true,
"msg":"查询成功",
"ip":"183.48.26.13",
"coordsys":"WGS84"}
 -->
