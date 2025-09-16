<!-- <template>
  <div class="app-container">
    <el-tabs v-model="activeName">
      <el-button type="primary" icon="el-icon-document" @click="handleCopy(inputData,$event)">copy</el-button>
      <el-input v-model="inputData" placeholder="Please input" style="width:400px;max-width:100%;" />
      <el-button v-clipboard:copy="inputData" v-clipboard:success="clipboardSuccess" type="primary" icon="el-icon-document">
        copy
      </el-button>
    </el-tabs>

    <el-card class="box-card" :gutter="20" style="margin: 20px;">
      <div slot="header" class="clearfix" style="font-weight: bold; font-size: large;">
        <span>设置白名单</span>
      </div>

      <div class="filter-container">

        <el-form :model="white" label-width="80px" label-position="left">
          <el-form-item label="已有账号:">
            <span>{{ white.account }}</span>
          </el-form-item>
          <el-form-item label="新增">
            <el-input v-model="white.ipAdress" placeholder="请填写ip地址" />
          </el-form-item>
          <el-form-item label="删除">
            <el-input v-model="white.deleteIp" placeholder="请填写ip地址" />
          </el-form-item>
        </el-form>
        <el-button type="primary" style="margin-left: 80px;" @click="ExecuteServer(1)"> 执行 </el-button>
      </div>
    </el-card>

    <el-card class="box-card" :gutter="20" style="margin: 20px;">
      <div slot="header" class="clearfix" style="font-weight: bold;font-size: large;">
        <span>踢人下线</span>
      </div>

      <div class="filter-container">
        <span>全服</span>
        <el-switch
          v-model="toggle.isFullServer"
          on-value="true"
          off-value="false"
          title="dsfds"
          style="margin-left: 10px;"
          @change="ChangeSwitch(1, 1)"
        />

        <span style="margin-left: 10px;">个服</span>
        <el-switch
          v-model="toggle.isPersonServer"
          on-value="true"
          off-value="false"
          title="dsfds"
          style="margin-left: 10px;"
          @change="ChangeSwitch(1, 2)"
        />
        <el-input v-model="roleId" type="number" placeholder="请填写账号ID" style="margin-left: 20px;width: 200px;" />
        <el-button type="primary" style="margin-left: 10px;" @click="ExecuteServer(2)">执行</el-button>
      </div>
    </el-card>

    <el-card class="box-card" :gutter="20" style="margin: 20px;">
      <div slot="header" class="clearfix" style="font-weight: bold;font-size: large;">
        <span>服务器维护</span>
      </div>

      <div class="filter-container">
        <span>正常</span>
        <el-switch
          v-model="toggle.isNormal"
          on-value="true"
          off-value="false"
          title="dsfds"
          style="margin-left: 10px;"
          @change="ChangeSwitch(2,1)"
        />

        <span style="margin-left: 10px;">维护</span>
        <el-switch
          v-model="toggle.isMaintain"
          on-value="true"
          off-value="false"
          title="dsfds"
          style="margin-left: 10px;"
          @change="ChangeSwitch(2,2)"
        />
        <el-button type="primary" style="margin-left: 20px;" @click="ExecuteServer(3)">执行</el-button>
      </div>
    </el-card>
  </div>
</template> -->

<!-- <script>
// import clip from '@/utils/clipboard'
// import clipboard from '@/directive/clipboard/index.js'
import { getServerInfo, setWhite, setDropOnline, setMaintain } from '@/api/game'
export default {
  name: 'Setting',
  directives: {
    // clipboard
  },
  data() {
    return {
      // activeName: 'directly',
      // inputData: 'https://github.com/PanJiaChen/vue-element-admin',
      roleId: 0,
      white: {
        account: '',
        ipAdress: '',
        deleteIp: ''
      },

      toggle: {
        isFullServer: false, // 全服
        isPersonServer: false, // 个服
        isNormal: false, // 正常
        isMaintain: false// 维护
      }
    }
  },

  created() {
    // 获取白名单数据
    this.GetServerInfo()
  },
  methods: {
    ChangeSwitch(group, tag) {
      if (group === 1) {
        if (tag === 1) {
          if (this.toggle.isFullServer) {
            this.toggle.isPersonServer = false
          }
        } else {
          if (this.toggle.isPersonServer) {
            this.toggle.isFullServer = false
          }
        }
      } else {
        if (tag === 1) {
          if (this.toggle.isNormal) {
            this.toggle.isMaintain = false
          }
        } else {
          if (this.toggle.isMaintain) {
            this.toggle.isNormal = false
          }
        }
      }
    },

    GetServerInfo() {
      return new Promise((resolve, reject) => {
        getServerInfo(this.white).then(response => {
          this.white.account = response.data.account
          resolve()
        }).catch(error => {
          reject(error)
          this.ShowMessage(error, false)
        })
      })
    },

    ExecuteServer(tag) {
      switch (tag) {
        case 1:// 白名单
          if (this.white.ipAdress !== '' || this.white.deleteIp !== '') {
            return new Promise((resolve, reject) => {
              setWhite({ flag: tag, ipAdress: this.white.ipAdress, deleteIp: this.white.deleteIp }).then(response => {
                if (this.white.ipAdress !== '') {
                  this.ShowMessage(`已经将${this.white.ipAdress}设置白名单`, true)
                } else {
                  this.ShowMessage(`已经将${this.white.deleteIp}移除白名单`, true)
                }
                resolve()
              }).catch(error => {
                reject(error)
                this.ShowMessage(error, false)
              })
            })
          } else {
            this.ShowMessage('ip地址不能为空', false)
          }
          break
        case 2:// 踢人下线
          if (this.toggle.isPersonServer || this.toggle.isFullServer) {
            return new Promise((resolve, reject) => {
              if (this.toggle.isPersonServer && this.roleId === 0) {
                this.ShowMessage('账号id不能为空', false)
                return
              }

              setDropOnline({ flag: tag, roleId: this.roleId, isFullServer: this.toggle.isFullServer, isPersonServer: this.toggle.isPersonServer }).then(response => {
                this.ShowMessage(`已经将${this.roleId}踢下`, true)
                resolve()
              }).catch(error => {
                reject(error)
                this.ShowMessage(error, false)
              })
            })
          } else {
            this.ShowMessage('请选择服类型', false)
          }

          break
        case 3:// 正常维护
          if (this.toggle.isNormal || this.toggle.isMaintain) {
            return new Promise((resolve, reject) => {
              setMaintain({ flag: tag, isNormal: this.toggle.isNormal, isMaintain: this.toggle.isMaintain }).then(response => {
                this.ShowMessage('服务器执行成功', true)
                resolve()
              }).catch(error => {
                reject(error)
                this.ShowMessage(error, false)
              })
            })
          } else {
            this.ShowMessage('请选择维护状态', false)
          }
          break
      }
    },
    // //拷贝函数
    // handleCopy(text, event) {
    //   clip(text, event)
    // },
    ShowMessage(msg, isSucc) {
      this.$message({
        message: msg,
        type: isSucc ? 'success' : 'error',
        duration: 1500
      })
    }
  }
}
</script>
 -->
