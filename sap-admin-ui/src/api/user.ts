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

/**
 * 新增用户
 */
export function addUser(data: {
  username: string
  password: string
  nickname?: string
  realName?: string
  studentNo?: string
  email?: string
  phone?: string
  college?: string
  major?: string
  className?: string
  roles?: string
}) {
  return request({
    url: '/user',
    method: 'post',
    data
  })
}

/**
 * 更新用户
 */
export function updateUser(data: {
  id: number
  nickname?: string
  realName?: string
  studentNo?: string
  email?: string
  phone?: string
  college?: string
  major?: string
  className?: string
  roles?: string
  status?: number
}) {
  return request({
    url: '/user',
    method: 'put',
    data
  })
}

/**
 * 删除用户
 */
export function deleteUser(id: number) {
  return request({
    url: `/user/${id}`,
    method: 'delete'
  })
}

/**
 * 重置密码
 */
export function resetUserPwd(id: number, password?: string) {
  return request({
    url: '/user/resetPwd',
    method: 'put',
    data: { id, password }
  })
}
