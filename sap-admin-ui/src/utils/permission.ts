import { computed } from 'vue'
import { useUserStore } from '@/stores/user'

/**
 * 权限控制组合式函数
 * 管理员拥有全部权限，普通用户只能进行申请和查看操作
 */
export function usePermission() {
  const userStore = useUserStore()

  /** 是否是管理员 */
  const isAdmin = computed(() => {
    return userStore.userInfo?.roles?.includes('admin') || false
  })

  /** 是否有编辑权限（仅管理员） */
  const canEdit = computed(() => isAdmin.value)

  /** 是否有删除权限（仅管理员） */
  const canDelete = computed(() => isAdmin.value)

  /** 是否有审核权限（仅管理员） */
  const canReview = computed(() => isAdmin.value)

  /** 是否可以查看管理菜单 */
  const canManage = computed(() => isAdmin.value)

  return {
    isAdmin,
    canEdit,
    canDelete,
    canReview,
    canManage
  }
}
