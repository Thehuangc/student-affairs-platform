<template>
  <div class="layout-scene">
    <!-- ═══ 侧边栏 ═══ -->
    <aside class="sidebar" :class="{ collapsed: isCollapse }">
      <!-- Logo区域 -->
      <div class="sidebar-brand">
        <div class="brand-icon">
          <svg viewBox="0 0 40 40" fill="none">
            <rect x="2" y="2" width="36" height="36" rx="8" fill="var(--jade-deep)" />
            <text x="20" y="26" text-anchor="middle" fill="white" font-size="16" font-weight="bold" font-family="STKaiti, KaiTi, serif">学</text>
          </svg>
        </div>
        <transition name="fade">
          <span v-show="!isCollapse" class="brand-text">事务中台</span>
        </transition>
      </div>

      <!-- 导航菜单 -->
      <nav class="sidebar-nav">
        <el-scrollbar>
          <el-menu
            :default-active="currentRoute"
            :collapse="isCollapse"
            :unique-opened="true"
            router
            background-color="transparent"
            text-color="rgba(247, 243, 236, 0.65)"
            active-text-color="var(--paper-white)"
          >
            <!-- 首页 -->
            <el-menu-item index="/dashboard">
              <el-icon class="nav-icon"><HomeFilled /></el-icon>
              <template #title>首页概览</template>
            </el-menu-item>

            <!-- 系统管理 -->
            <el-sub-menu v-if="isAdmin" index="/system">
              <template #title>
                <el-icon class="nav-icon"><Setting /></el-icon>
                <span>系统管理</span>
              </template>
              <el-menu-item index="/system/user">
                <span class="menu-dot"></span>用户管理
              </el-menu-item>
              <el-menu-item index="/system/role">
                <span class="menu-dot"></span>角色管理
              </el-menu-item>
            </el-sub-menu>

            <!-- 团员发展 -->
            <el-sub-menu index="/league">
              <template #title>
                <el-icon class="nav-icon"><StarFilled /></el-icon>
                <span>团员发展</span>
              </template>
              <el-menu-item index="/league/application">
                <span class="menu-dot"></span>入团申请
              </el-menu-item>
              <el-menu-item index="/league/review">
                <span class="menu-dot"></span>政审备案
              </el-menu-item>
              <el-menu-item index="/league/archive">
                <span class="menu-dot"></span>电子档案
              </el-menu-item>
            </el-sub-menu>

            <!-- 志愿服务 -->
            <el-sub-menu index="/volunteer">
              <template #title>
                <el-icon class="nav-icon"><HelpFilled /></el-icon>
                <span>志愿服务</span>
              </template>
              <el-menu-item index="/volunteer/activity">
                <span class="menu-dot"></span>活动管理
              </el-menu-item>
              <el-menu-item index="/volunteer/checkin">
                <span class="menu-dot"></span>签到记录
              </el-menu-item>
              <el-menu-item index="/volunteer/hours">
                <span class="menu-dot"></span>时长统计
              </el-menu-item>
            </el-sub-menu>

            <!-- 勤工助学 -->
            <el-sub-menu index="/workstudy">
              <template #title>
                <el-icon class="nav-icon"><Briefcase /></el-icon>
                <span>勤工助学</span>
              </template>
              <el-menu-item index="/workstudy/position">
                <span class="menu-dot"></span>岗位管理
              </el-menu-item>
              <el-menu-item index="/workstudy/attendance">
                <span class="menu-dot"></span>考勤管理
              </el-menu-item>
              <el-menu-item index="/workstudy/salary">
                <span class="menu-dot"></span>薪资管理
              </el-menu-item>
            </el-sub-menu>
          </el-menu>
        </el-scrollbar>
      </nav>

      <!-- 底部折叠按钮 -->
      <div class="sidebar-footer">
        <button class="collapse-btn" @click="toggleCollapse">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" :style="{ transform: isCollapse ? 'rotate(180deg)' : '' }">
            <path d="M15 19l-7-7 7-7" />
          </svg>
        </button>
      </div>
    </aside>

    <!-- ═══ 主内容区 ═══ -->
    <div class="main-wrapper">
      <!-- 顶部栏 -->
      <header class="topbar">
        <div class="topbar-left">
          <div class="breadcrumb-area">
            <span class="page-title">{{ currentPageTitle }}</span>
            <div class="breadcrumb-path">
              <span class="path-item" @click="$router.push('/')">首页</span>
              <span v-for="item in breadcrumbs" :key="item.path" class="path-sep">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="12" height="12">
                  <path d="M9 5l7 7-7 7" />
                </svg>
                <span class="path-item">{{ item.meta?.title }}</span>
              </span>
            </div>
          </div>
        </div>

        <div class="topbar-right">
          <!-- 通知铃铛 -->
          <div class="topbar-action notification-bell">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
              <path d="M13.73 21a2 2 0 0 1-3.46 0" />
            </svg>
            <span class="notification-badge">3</span>
          </div>

          <!-- 用户头像 -->
          <div class="user-dropdown">
            <el-dropdown @command="handleCommand" trigger="click">
              <div class="user-info">
                <div class="user-avatar">
                  <span>{{ userInitial }}</span>
                </div>
                <span class="user-name">{{ userStore.userInfo?.nickname || '管理员' }}</span>
                <svg class="user-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M6 9l6 6 6-6" />
                </svg>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="16" height="16" style="margin-right: 8px;">
                      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                      <circle cx="12" cy="7" r="4" />
                    </svg>
                    个人中心
                  </el-dropdown-item>
                  <el-dropdown-item divided command="logout">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="16" height="16" style="margin-right: 8px;">
                      <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                      <polyline points="16 17 21 12 16 7" />
                      <line x1="21" y1="12" x2="9" y2="12" />
                    </svg>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </header>

      <!-- 内容区域 -->
      <main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="page-fade" mode="out-in">
            <keep-alive>
              <component :is="Component" />
            </keep-alive>
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { usePermission } from '@/utils/permission'
import {
  HomeFilled, Setting, User, UserFilled, StarFilled, Document,
  Checked, Files, HelpFilled, Calendar, Location, Timer,
  Briefcase, Postcard, Clock, Money, Fold, Expand
} from '@element-plus/icons-vue'

const { isAdmin } = usePermission()

// 图标映射（替代全局注册）
const iconMap: Record<string, any> = {
  HomeFilled, Setting, User, UserFilled, StarFilled, Document,
  Checked, Files, HelpFilled, Calendar, Location, Timer,
  Briefcase, Postcard, Clock, Money, Fold, Expand
}

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const isCollapse = ref(false)

// 当前路由
const currentRoute = computed(() => route.path)

// 用户首字母
const userInitial = computed(() => {
  const name = userStore.userInfo?.nickname || 'A'
  return name.charAt(0).toUpperCase()
})

// 当前页面标题
const currentPageTitle = computed(() => {
  return (route.meta?.title as string) || '首页'
})

// 面包屑
const breadcrumbs = computed(() => {
  return route.matched.filter((item) => item.meta?.title && item.meta?.title !== '首页')
})

// 切换折叠
function toggleCollapse() {
  isCollapse.value = !isCollapse.value
}

// 下拉命令
function handleCommand(command: string) {
  if (command === 'profile') {
    router.push('/profile')
  } else if (command === 'logout') {
    userStore.logout()
    router.push('/login')
  }
}
</script>

<style scoped lang="scss">
.layout-scene {
  display: flex;
  min-height: 100vh;
  background: var(--paper-cream);
}

/* ═══ 侧边栏 ═══ */
.sidebar {
  width: 240px;
  background: linear-gradient(180deg, var(--ink-deep) 0%, var(--ink-medium) 100%);
  display: flex;
  flex-direction: column;
  transition: width var(--transition-smooth);
  position: relative;
  z-index: 10;

  &::after {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    width: 1px;
    background: linear-gradient(180deg, var(--jade-deep) 0%, transparent 100%);
  }

  &.collapsed {
    width: 72px;
  }
}

.sidebar-brand {
  display: flex;
  align-items: center;
  padding: 20px;
  height: 64px;
  gap: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);

  .brand-icon {
    flex-shrink: 0;
    width: 36px;
    height: 36px;

    svg {
      width: 100%;
      height: 100%;
    }
  }

  .brand-text {
    font-size: 16px;
    font-weight: 600;
    color: var(--paper-cream);
    letter-spacing: 2px;
    white-space: nowrap;
    font-family: 'STKaiti', 'KaiTi', serif;
  }
}

.sidebar-nav {
  flex: 1;
  overflow: hidden;
  padding: 12px 0;

  :deep(.el-menu) {
    border-right: none;
    padding: 0 8px;

    .el-menu-item,
    .el-sub-menu__title {
      height: 44px;
      line-height: 44px;
      border-radius: var(--radius-sm);
      margin-bottom: 2px;
      transition: all var(--transition-fast);

      &:hover {
        background: rgba(255, 255, 255, 0.06) !important;
      }
    }

    .el-menu-item.is-active {
      background: var(--jade-deep) !important;
      color: var(--paper-white) !important;
      position: relative;

      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 3px;
        height: 20px;
        background: var(--gold-accent);
        border-radius: 0 2px 2px 0;
      }
    }

    .el-sub-menu .el-menu-item {
      padding-left: 52px !important;
      height: 40px;
      line-height: 40px;
    }

    .el-sub-menu__icon-arrow {
      color: rgba(255, 255, 255, 0.3);
    }
  }

  .nav-icon {
    font-size: 18px;
    margin-right: 8px;
  }

  .menu-dot {
    display: inline-block;
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: currentColor;
    margin-right: 10px;
    opacity: 0.5;
  }
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);

  .collapse-btn {
    width: 100%;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(255, 255, 255, 0.06);
    border: none;
    border-radius: var(--radius-sm);
    color: rgba(255, 255, 255, 0.5);
    cursor: pointer;
    transition: all var(--transition-fast);

    &:hover {
      background: rgba(255, 255, 255, 0.1);
      color: white;
    }

    svg {
      width: 18px;
      height: 18px;
      transition: transform var(--transition-smooth);
    }
  }
}

/* ═══ 主内容区 ═══ */
.main-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.topbar {
  height: 64px;
  background: var(--paper-white);
  border-bottom: 1px solid rgba(26, 31, 22, 0.06);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: var(--shadow-sm);
  position: sticky;
  top: 0;
  z-index: 5;
}

.topbar-left {
  .breadcrumb-area {
    .page-title {
      font-size: 18px;
      font-weight: 600;
      color: var(--ink-deep);
      font-family: 'Noto Serif SC', serif;
    }

    .breadcrumb-path {
      display: flex;
      align-items: center;
      gap: 4px;
      margin-top: 2px;
    }

    .path-item {
      font-size: 12px;
      color: var(--text-tertiary);
      cursor: pointer;
      transition: color var(--transition-fast);

      &:hover {
        color: var(--jade-deep);
      }
    }

    .path-sep {
      display: flex;
      align-items: center;
      gap: 4px;
      color: var(--text-tertiary);
    }
  }
}

.topbar-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-bell {
  position: relative;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  cursor: pointer;
  transition: all var(--transition-fast);

  &:hover {
    background: var(--paper-warm);
  }

  svg {
    width: 20px;
    height: 20px;
    color: var(--text-secondary);
  }

  .notification-badge {
    position: absolute;
    top: 4px;
    right: 4px;
    width: 18px;
    height: 18px;
    background: var(--vermillion);
    color: white;
    font-size: 10px;
    font-weight: 600;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid var(--paper-white);
  }
}

.user-dropdown {
  .user-info {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    padding: 6px 12px;
    border-radius: var(--radius-md);
    transition: background var(--transition-fast);

    &:hover {
      background: var(--paper-warm);
    }
  }

  .user-avatar {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, var(--jade-deep), var(--jade-medium));
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    span {
      color: white;
      font-size: 14px;
      font-weight: 600;
    }
  }

  .user-name {
    font-size: 14px;
    color: var(--text-primary);
    font-weight: 500;
  }

  .user-arrow {
    width: 16px;
    height: 16px;
    color: var(--text-tertiary);
    transition: transform var(--transition-fast);
  }
}

.main-content {
  flex: 1;
  overflow-y: auto;
}

/* ═══ 页面过渡 ═══ */
.page-fade-enter-active {
  transition: all 0.3s ease;
}

.page-fade-leave-active {
  transition: all 0.15s ease;
}

.page-fade-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.page-fade-leave-to {
  opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
