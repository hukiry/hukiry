<template>
  <div class="app-container">
    <el-button type="primary" @click="handleAdd">添加公告</el-button>
    <el-button v-show="itemList.length>0" :type="isPushMail?'success':'primary'" @click="isPushMail=!isPushMail">{{ isPushMail?"取消操作":"推送公告" }}</el-button>
    <el-button v-show="itemList.length>0" :type="isDeleteMail?'success':'danger'" @click="isDeleteMail=!isDeleteMail">{{ isDeleteMail?"取消操作":"删除公告" }}</el-button>
    <el-table :data="itemList" style="width: 100%;margin-top:30px;" border>
      <el-table-column align="header-center" label="语言" width="100">
        <template slot-scope="scope">
          {{ getLanguageName(scope.row.lanCode) }}
        </template>
      </el-table-column>
      <el-table-column align="center" label="公告标题">
        <template slot-scope="scope">
          {{ scope.row.title }}
        </template>
      </el-table-column>
      <el-table-column align="header-center" label="公告内容">
        <template slot-scope="scope">
          {{ scope.row.content }}
        </template>
      </el-table-column>
      <el-table-column align="header-center" label="生效时间">
        <template slot-scope="scope">
          <span v-if="scope.row.createTime!=null">
            {{ getTextTime(scope.row.createTime,"{y}年{m}月{d}日 {h}时{i}分{s}秒") }}
          </span>
        </template>
      </el-table-column>
      <el-table-column align="header-center" label="过期时间">
        <template slot-scope="scope">
          <span v-if="scope.row.expirateTime!=null">
            {{ getTextTime(scope.row.expirateTime,"{y}年{m}月{d}日 {h}时{i}分{s}秒") }}
          </span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作" width="160">
        <template slot-scope="scope">
          <el-button v-show="!isDeleteMail" type="primary" size="small" style="margin-left:10px;" @click="handleEdit(scope)">编辑</el-button>
          <el-button v-show="isDeleteMail" type="danger" size="small" @click="handleDelete(scope)">删除</el-button>
          <el-button v-show="isPushMail" type="success" size="small" style="margin-left:10px;" @click="handPush(scope)">{{ scope.row.pushState==1?"完成":"推送" }}</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :visible.sync="dialogVisible" :title="dialogType==='edit'?'编辑 公告':'新建 公告'">
      <el-form :model="role" prop="role" label-width="80px" label-position="left">
        <el-form-item label="语言代码">
          <el-select v-model="role.lanCode" placeholder="选择语言" clearable style="width: 150px;text-align: left;" class="filter-item">
            <el-option v-for="item in multiLanageCode" :key="item.key" :label="item.label+`(${item.key})`" :value="item.key" />
          </el-select>
          <!-- <label style="margin-left:20px; margin-right:5px;">公告类型</label> -->
        </el-form-item>
        <el-form-item label="标题" prop="title">
          <el-input v-model="role.title" placeholder="输入标题" />
        </el-form-item>
        <el-form-item label="内容" prop="content" placeholder="请输入">
          <el-input
            v-model="role.content"
            :autosize="{ minRows: 2, maxRows: 4}"
            type="textarea"
            placeholder="输入描述"
          />
        </el-form-item>
        <el-form-item label="有效时间:">
          <el-date-picker v-model="role.createTime" style="width:220px;" :picker-options="pickerOptionsStart" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="开始日期" />
          <span> 至 </span>
          <el-date-picker v-model="role.expirateTime" style="width:220px;" :picker-options="pickerOptionsEnd" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="结束日期" />
        </el-form-item>
      </el-form>
      <div style="text-align:right;">
        <el-button type="danger" @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="confirmRole">确认</el-button>
      </div>
    </el-dialog>

    <pagination v-show="total>0" :total="total" :page.sync="listQuery.page" :limit.sync="listQuery.limit" @pagination="getList" />

  </div>
</template>

<script>

import { deepClone, parseTime } from '@/utils'
import Pagination from '@/components/Pagination'
import { getGameInfos, addGame, deleteGame, editorGame, sendGame } from '@/api/game'
import { forEach } from 'jszip/lib/object'

const defaultRole = {
  id: 0,
  configId: 0,
  title: '',
  content: '',
  lanCode: '',
  createTime: 0,
  expirateTime: 0,
  type: 2, // 1=邮件，2=公告
  pushState: 0// 推送状态 1=已经推送
}

const BILLBOARD_TYPE = 3

export default {
  components: { Pagination },
  data() {
    return {
      role: Object.assign({}, defaultRole),
      itemList: [],
      dialogVisible: false,
      dialogType: 'new',
      checkStrictly: false,
      defaultProps: {
        children: 'children',
        label: 'title'
      },
      total: 10,
      indexId: 1,
      listLoading: true,
      listQuery: {
        page: 1,
        limit: 10,
        timestamp: 0,
        state: 0,
        type: 2
      },

      isDeleteMail: false,
      isPushMail: false,
      multiLanageCode: [
        { label: '简体中文', key: 'cn' },
        { label: '繁体', key: 'hk' },
        { label: '英语', key: 'en' },
        { label: '日语', key: 'ja' },
        { label: '韩语', key: 'ko' },
        { label: '西班牙语', key: 'es' },
        { label: '葡萄牙语', key: 'pt' },
        { label: '法语', key: 'fr' },
        { label: '德语', key: 'de' },
        { label: '俄语', key: 'ru' },
        { label: '意大利语', key: 'it' },
        { label: '越南语', key: 'vi' },
        { label: '波兰语', key: 'pl' },
        { label: '印尼语', key: 'id' },
        { label: '泰语', key: 'th' },
        { label: '马来语', key: 'ms' },
        { label: '土耳其语', key: 'tr' },
        { label: '荷兰语', key: 'nl' }
      ],
      // 设置结束时间不能早于开始时间
      pickerOptionsStart: {
        disabledDate: time => {
          const endDateVal = new Date(this.role.expirateTime).getTime()
          console.log('createTime=' + parseInt(new Date(this.role.expirateTime).getTime() / 1000))
          if (endDateVal) {
            return new Date(time).getTime() > endDateVal + 1
          }
        }
      },
      pickerOptionsEnd: {
        disabledDate: time => {
          const beginDateVal = new Date(this.role.createTime).getTime()
          console.log('expirateTime=' + this.role.createTime)
          if (beginDateVal) {
            return new Date(time).getTime() < beginDateVal + 1
          }
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
      getGameInfos(this.listQuery, BILLBOARD_TYPE).then(response => {
        this.itemList = response.items
        this.total = response.total
        this.indexId = 0
        setTimeout(() => {
          this.listLoading = false
        }, 500)

        for (let index = 0; index < this.itemList.length; index++) {
          if (this.itemList[index].configId > this.indexId) {
            this.indexId = this.itemList[index].configId
          }
        }
      })
    },

    handleAdd() {
      this.role = Object.assign({}, defaultRole)
      if (this.$refs.tree) {
        this.$refs.tree.setCheckedNodes([])
      }
      var d = new Date()
      this.role.createTime = d
      this.role.expirateTime = new Date(d.getTime() + 1000)
      this.role.configId = this.indexId + 1
      this.dialogType = 'new'
      this.dialogVisible = true
    },
    handleEdit(scope) {
      this.dialogType = 'edit'
      this.dialogVisible = true
      this.checkStrictly = true
      this.role = deepClone(scope.row)
      this.role.createTime = new Date(parseInt(scope.row.createTime) * 1000)
      this.role.expirateTime = new Date(parseInt(scope.row.expirateTime) * 1000)
      this.$nextTick(() => {
        // set checked state of a node not affects its father and child nodes
        this.checkStrictly = false
      })
    },
    handleDelete({ $index, row }) {
      this.$confirm('是否移除此数据?', '警告', {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: 'warning'
      })
        .then(async() => {
          await deleteGame({ id: row.id }, BILLBOARD_TYPE)
          this.itemList.splice($index, 1)
          // 删除数据，处理唯一id
          for (let index = 0; index < this.itemList.length; index++) {
            if (this.itemList[index].configId > this.indexId) {
              this.indexId = this.itemList[index].configId
            }
          }

          this.$message({
            type: 'success',
            message: '删除成功!'
          })
        })
        .catch(err => { console.error(err) })
    },

    async confirmRole() {
      const isEdit = this.dialogType === 'edit'
      const mailRole = Object.assign({}, this.role)
      mailRole.createTime = parseInt(new Date(mailRole.createTime).getTime() / 1000)
      mailRole.expirateTime = parseInt(new Date(mailRole.expirateTime).getTime() / 1000)
      if (isEdit) {
        // 编辑当前数据
        await editorGame(mailRole, BILLBOARD_TYPE)
        for (let index = 0; index < this.itemList.length; index++) {
          if (this.itemList[index].configId === this.role.configId) {
            this.itemList.splice(index, 1, Object.assign({}, this.role))
            break
          }
        }
      } else {
        // 新建
        mailRole.id = mailRole.createTime
        await addGame(mailRole, BILLBOARD_TYPE)
        this.itemList.splice(0, 0, this.role)
        if (this.itemList.length > this.listQuery.limit) {
          this.itemList.pop()// 删除最后一个元素
        }
        this.total = this.total + 1
        this.indexId = this.indexId + 1
      }

      const { content, configId, title, lanCode } = this.role
      this.dialogVisible = false
      this.$notify({
        title: 'Success',
        dangerouslyUseHTMLString: true,
        message: `
            <div>configId: ${configId}</div>
            <div>名称: ${title}</div>
            <div>备注: ${content}</div>
            <div>代码: ${lanCode}</div>
          `,
        type: 'success'
      })
      // 编辑和添加后需要刷新数据
      this.getList()
    },

    // 推送数据
    async handPush(scope) {
      const mailRole = deepClone(scope.row)
      var nowTime = parseInt(new Date().getTime() / 1000)
      if (nowTime >= mailRole.expirateTime || mailRole.pushState == 1) {
        this.$message({
          type: 'error',
          message: mailRole.pushState == 1 ? '此邮件已经推送过，不可重复推送' : '此活动已过期，请选择其他推送!'
        })
        return
      }

      mailRole.pushState = 1 // 将 pushState 属性设置为 1
      // 这里需要转换为时间戳，否则发送到服务器会导致报错异常
      mailRole.createTime = scope.row.createTime // 将 createTime 属性设置为 scope.createTime 的时间戳
      mailRole.expirateTime = scope.row.expirateTime // 将 expirateTime 属性设置为 scope.expirateTime 的时间戳

      await sendGame(mailRole, BILLBOARD_TYPE).then(() => {
        for (let index = 0; index < this.itemList.length; index++) {
          if (this.itemList[index].configId == mailRole.configId) {
            this.itemList[index].pushState = 1
          }
        }
      }).catch(() => {
        this.$message({
          type: 'error',
          message: '请重新刷新后，再进行推送！'
        })
      })
    },

    getTextTime(t, s) {
      return parseTime(t, s)
    },
    getLanguageName(code) {
      for (let index = 0; index < this.multiLanageCode.length; index++) {
        const element = this.multiLanageCode[index]
        if (element.key == code) {
          return element.label
        }
      }
      return 'none'
    }
  }
}
</script>

<style lang="scss" scoped>
.app-container {
  border-radius: 6px;
  .roles-table {
    margin-top: 30px;
  }
  .permission-tree {
    margin-bottom: 30px;
  }
}
</style>
