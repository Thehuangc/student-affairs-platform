import request from '@/utils/request'

/**
 * 获取用户列表
 */
export function getUserList(params: {
  pageNum?: number
  pageSize?: number
  username?: string
  status?: number
}) {
  return request({
    url: '/user/list',
    method: 'get',
    params
  })
}

/**
 * 获取用户详情
 */
export function getUserInfo() {
  return request({
    url: '/user/info',
    method: 'get'
  })
}
