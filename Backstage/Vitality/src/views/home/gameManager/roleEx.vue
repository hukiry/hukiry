<template>
  <div class="app-container">
    <div class="filter-container">
      <el-button v-waves class="filter-item" type="primary" icon="el-icon-search" @click="getList"> 查询90天未登陆的数据 </el-button>
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
          <span>{{ row.roleId }}</span>
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
          <span>{{ row.coinNum }}</span>
        </template>
      </el-table-column>
      <el-table-column label="关卡">
        <template slot-scope="{row}">
          <span>{{ row.level }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button type="danger" size="small" @click="handleDelete(scope)">删除</el-button>
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
import {getGameInfos, deleteGame} from '@/api/game'
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
        limit: 50,
        timestamp: 0,
        state: 8, // 1=查询日登陆，2=查询日注册, 3=查询月登陆，4=查询月注册
        type: 0// 数据查询类型
      },
      downloadLoading: false,
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
    sortChange(data) {
      const { prop } = data
      if (prop === 'roleID') {
        this.getList()
      }
    },
    //删除数据
    handleDelete({row }) {
      console.log(row.roleId)
      this.$confirm('是否移除此数据?', '警告', {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
          await deleteGame({ roleId: row.roleId }, ROLE_TYPE)
          this.$message({
            type: 'success',
            message: '删除成功!'
          })
          // 删除数据，处理唯一id
          this.getList()
        }).catch(err => { console.error(err) })
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
    }
  }
}
</script>
