/*
*ip配置文件
*/

const env = process.env.NODE_ENV

const IP = {
  // 开发环境：内网
  development: {
    baseIP: 'http://192.168.1.9:9302/'
  },
  // 正式环境：外网
  production: {
    // 海外
    baseIP: 'http://47.88.51.16:9302/'
  },
  // 测试
  test: {
    baseIP: 'http://192.168.1.9:9302/'
  }

}
export default IP[env]
