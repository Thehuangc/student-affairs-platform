import { defineStore } from 'pinia'
import { ref } from 'vue'
import Cookies from 'js-cookie'
import request from '@/utils/request'

interface UserInfo {
  userId: number
  username: string
  nickname: string
  avatar: string
  roles: string[]
  permissions: string[]
}

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(Cookies.get('token') || localStorage.getItem('token') || '')
  const userInfo = ref<UserInfo | null>(null)

  // 设置Token
  function setToken(newToken: string) {
    token.value = newToken
    Cookies.set('token', newToken, { expires: 1 })
    localStorage.setItem('token', newToken)
  }

  // 清除Token
  function clearToken() {
    token.value = ''
    userInfo.value = null
    Cookies.remove('token')
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  // 登录
  async function login(username: string, password: string) {
    const res: any = await request({
      url: '/auth/login',
      method: 'post',
      data: { username, password }
    })
    setToken(res.data.token)
    userInfo.value = {
      userId: res.data.userId,
      username: res.data.username,
      nickname: res.data.nickname,
      avatar: res.data.avatar,
      roles: res.data.roles,
      permissions: res.data.permissions
    }
    return res.data
  }

  // 获取用户信息
  async function getUserInfo() {
    if (!userInfo.value && token.value) {
      // 先从localStorage读取(login.html登录时存储)
      const saved = localStorage.getItem('user')
      if (saved) {
        try {
          userInfo.value = JSON.parse(saved)
          return userInfo.value
        } catch(e) {}
      }
      // 否则调用API获取
      // 这里可以调用 /api/user/info 接口
    }
    return userInfo.value
  }

  // 退出登录
  async function logout() {
    try {
      await request({
        url: '/auth/logout',
        method: 'post'
      })
    } catch (e) {
      console.error('退出登录失败:', e)
    } finally {
      clearToken()
    }
  }

  // 检查权限
  function hasPermission(permission: string): boolean {
    if (userInfo.value?.permissions.includes('*:*:*')) {
      return true
    }
    return userInfo.value?.permissions.includes(permission) || false
  }

  // 检查角色
  function hasRole(role: string): boolean {
    return userInfo.value?.roles.includes(role) || false
  }

  return {
    token,
    userInfo,
    setToken,
    clearToken,
    login,
    getUserInfo,
    logout,
    hasPermission,
    hasRole
  }
})
