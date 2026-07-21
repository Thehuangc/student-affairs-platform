import request from '@/utils/request'

/**
 * 用户登录
 */
export function login(data: { username: string; password: string }) {
  return request({
    url: '/auth/login',
    method: 'post',
    data
  })
}

/**
 * 用户注册
 */
export function register(data: {
  username: string
  password: string
  confirmPassword: string
  realName: string
  studentNo?: string
  phone?: string
  email?: string
}) {
  return request({
    url: '/auth/register',
    method: 'post',
    data
  })
}

/**
 * 退出登录
 */
export function logout() {
  return request({
    url: '/auth/logout',
    method: 'post'
  })
}

/**
 * 刷新Token
 */
export function refreshToken() {
  return request({
    url: '/auth/refresh',
    method: 'post'
  })
}
