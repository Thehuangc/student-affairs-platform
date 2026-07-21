import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import NProgress from 'nprogress'
import { useUserStore } from '@/stores/user'

// 路由配置
const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/layouts/index.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '首页', icon: 'HomeFilled' }
      }
    ]
  },
  {
    path: '/system',
    component: () => import('@/layouts/index.vue'),
    redirect: '/system/user',
    meta: { title: '系统管理', icon: 'Setting' },
    children: [
      {
        path: 'user',
        name: 'User',
        component: () => import('@/views/system/user/index.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: 'role',
        name: 'Role',
        component: () => import('@/views/system/role/index.vue'),
        meta: { title: '角色管理', icon: 'UserFilled' }
      }
    ]
  },
  {
    path: '/league',
    component: () => import('@/layouts/index.vue'),
    redirect: '/league/application',
    meta: { title: '团员发展', icon: 'StarFilled' },
    children: [
      {
        path: 'application',
        name: 'LeagueApplication',
        component: () => import('@/views/league/application.vue'),
        meta: { title: '入团申请', icon: 'Document' }
      },
      {
        path: 'review',
        name: 'LeagueReview',
        component: () => import('@/views/league/review.vue'),
        meta: { title: '政审备案', icon: 'Checked' }
      },
      {
        path: 'archive',
        name: 'LeagueArchive',
        component: () => import('@/views/league/archive.vue'),
        meta: { title: '电子档案', icon: 'Files' }
      }
    ]
  },
  {
    path: '/volunteer',
    component: () => import('@/layouts/index.vue'),
    redirect: '/volunteer/activity',
    meta: { title: '志愿服务', icon: 'HelpFilled' },
    children: [
      {
        path: 'activity',
        name: 'VolActivity',
        component: () => import('@/views/volunteer/activity/index.vue'),
        meta: { title: '活动管理', icon: 'Calendar' }
      },
      {
        path: 'checkin',
        name: 'VolCheckin',
        component: () => import('@/views/volunteer/checkin/index.vue'),
        meta: { title: '签到记录', icon: 'Location' }
      },
      {
        path: 'hours',
        name: 'VolHours',
        component: () => import('@/views/volunteer/hours/index.vue'),
        meta: { title: '时长统计', icon: 'Timer' }
      }
    ]
  },
  {
    path: '/workstudy',
    component: () => import('@/layouts/index.vue'),
    redirect: '/workstudy/position',
    meta: { title: '勤工助学', icon: 'Briefcase' },
    children: [
      {
        path: 'position',
        name: 'Position',
        component: () => import('@/views/workstudy/position.vue'),
        meta: { title: '岗位管理', icon: 'Postcard' }
      },
      {
        path: 'attendance',
        name: 'Attendance',
        component: () => import('@/views/workstudy/attendance.vue'),
        meta: { title: '考勤管理', icon: 'Clock' }
      },
      {
        path: 'salary',
        name: 'Salary',
        component: () => import('@/views/workstudy/salary.vue'),
        meta: { title: '薪资管理', icon: 'Money' }
      }
    ]
  },
  {
    path: '/404',
    name: '404',
    component: () => import('@/views/404.vue'),
    meta: { title: '404' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/404'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 白名单路由
const whiteList = ['/login', '/register']

// 路由守卫
router.beforeEach(async (to, from, next) => {
  NProgress.start()

  const userStore = useUserStore()
  const hasToken = userStore.token

  if (hasToken) {
    if (to.path === '/login') {
      next({ path: '/' })
      NProgress.done()
    } else {
      if (userStore.userInfo) {
        next()
      } else {
        try {
          await userStore.getUserInfo()
          next({ ...to, replace: true })
        } catch (error) {
          userStore.clearToken()
          next(`/login?redirect=${to.path}`)
          NProgress.done()
        }
      }
    }
  } else {
    if (whiteList.includes(to.path)) {
      next()
    } else {
      next(`/login?redirect=${to.path}`)
      NProgress.done()
    }
  }
})

router.afterEach(() => {
  NProgress.done()
})

export default router
