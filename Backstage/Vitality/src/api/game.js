import request from '@/utils/request'


//-------------------------GET-------------------------------
export function fetchList(condition, type) {
  return getGameInfos(condition, type)
}

// 获取游戏所有数据：查询和推送
export function getGameInfos(condition, type) {
  return request({
    url: '/game',
    method: 'get',
    params: { condition: condition, type: type }
  })
}

// -------------POST-----------------
export function addGame(data, systemType) {
  data.state = 1
  data.systemType = systemType
  return request({
    url: '/game',
    method: 'post',
    data
  })
}

export function editorGame(data, systemType) {
  data.state = 2
  data.systemType = systemType
  return request({
    url: '/game',
    method: 'post',
    data
  })
}

// 参数是ID
export function deleteGame(data, systemType) {
  data.state = 3
  data.systemType = systemType

  return request({
    url: '/game',
    method: 'post',
    data
  })
}

// 推送到游戏
export function sendGame(data, systemType) {
  data.state = 5
  data.systemType = systemType
  return request({
    url: '/game',
    method: 'post',
    data
  })
}

