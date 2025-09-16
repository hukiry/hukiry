import request from '@/utils/request'

export function getInfo(token) {
  return request({
    url: '/game',
    method: 'get',
    params: { token }
  })
}

export function login(data) {
  return request({
    url: '/login',
    method: 'post',
    data
  })
}

export function logout() {
  return request({
    url: '/login',
    method: 'post',
    params: { state:1 }
  })
}