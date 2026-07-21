<template>
  <div class="dashboard-scene">
    <!-- ═══ 顶部欢迎区 ═══ -->
    <div class="welcome-section">
      <div class="welcome-content">
        <div class="greeting">
          <h1>{{ greetingText }}，{{ userStore.userInfo?.nickname || '管理员' }}</h1>
          <p>{{ currentDate }} · {{ weekDay }}</p>
        </div>
        <div class="welcome-poem">
          <span>业精于勤，荒于嬉</span>
        </div>
      </div>
      <div class="welcome-decoration">
        <div class="ink-circle"></div>
        <div class="ink-circle small"></div>
      </div>
    </div>

    <!-- ═══ 数据概览卡片 ═══ -->
    <div class="stats-grid">
      <div
        v-for="(stat, index) in statsCards"
        :key="stat.title"
        class="stat-card"
        :style="{ animationDelay: `${index * 0.1}s` }"
      >
        <div class="stat-icon" :style="{ background: stat.iconBg }">
          <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5" v-html="stat.icon"></svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stat.value }}</span>
          <span class="stat-title">{{ stat.title }}</span>
        </div>
        <div class="stat-trend" :class="stat.trend">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14">
            <path v-if="stat.trend === 'up'" d="M23 6l-9.5 9.5-5-5L1 18" />
            <path v-else d="M23 18l-9.5-9.5-5 5L1 6" />
          </svg>
          <span>{{ stat.trendValue }}</span>
        </div>
      </div>
    </div>

    <!-- ═══ 图表和内容区 ═══ -->
    <div class="content-grid">
      <!-- 左侧：活动趋势 -->
      <div class="chart-card main-chart">
        <div class="card-header">
          <div class="header-title">
            <div class="title-accent"></div>
            <h3>近7日活动趋势</h3>
          </div>
          <div class="header-actions">
            <button
              v-for="period in ['周', '月', '年']"
              :key="period"
              class="period-btn"
              :class="{ active: activePeriod === period }"
              @click="activePeriod = period"
            >
              {{ period }}
            </button>
          </div>
        </div>
        <div ref="lineChartRef" class="chart-area"></div>
      </div>

      <!-- 右侧：活动类型分布 -->
      <div class="chart-card">
        <div class="card-header">
          <div class="header-title">
            <div class="title-accent vermillion"></div>
            <h3>活动类型分布</h3>
          </div>
        </div>
        <div ref="pieChartRef" class="chart-area"></div>
      </div>
    </div>

    <!-- ═══ 底部内容区 ═══ -->
    <div class="bottom-grid">
      <!-- 待办事项 -->
      <div class="todo-card">
        <div class="card-header">
          <div class="header-title">
            <div class="title-accent gold"></div>
            <h3>待办事项</h3>
          </div>
          <span class="header-link">查看全部</span>
        </div>
        <div class="todo-list">
          <div
            v-for="(todo, index) in todoList"
            :key="todo.id"
            class="todo-item"
            :style="{ animationDelay: `${index * 0.05}s` }"
          >
            <div class="todo-status" :class="todo.type"></div>
            <div class="todo-content">
              <span class="todo-title">{{ todo.title }}</span>
              <span class="todo-time">{{ todo.time }}</span>
            </div>
            <span class="todo-tag" :class="todo.type">{{ todo.tag }}</span>
          </div>
        </div>
      </div>

      <!-- 快捷入口 -->
      <div class="shortcuts-card">
        <div class="card-header">
          <div class="header-title">
            <div class="title-accent jade"></div>
            <h3>快捷入口</h3>
          </div>
        </div>
        <div class="shortcuts-grid">
          <div
            v-for="shortcut in shortcuts"
            :key="shortcut.name"
            class="shortcut-item"
            @click="$router.push(shortcut.path)"
          >
            <div class="shortcut-icon" :style="{ background: shortcut.bg }">
              <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5" v-html="shortcut.icon"></svg>
            </div>
            <span class="shortcut-name">{{ shortcut.name }}</span>
          </div>
        </div>
      </div>

      <!-- 最近活动 -->
      <div class="recent-card">
        <div class="card-header">
          <div class="header-title">
            <div class="title-accent"></div>
            <h3>最近活动</h3>
          </div>
        </div>
        <div class="activity-timeline">
          <div
            v-for="(activity, index) in recentActivities"
            :key="activity.id"
            class="timeline-item"
            :style="{ animationDelay: `${index * 0.08}s` }"
          >
            <div class="timeline-dot" :class="activity.type"></div>
            <div class="timeline-content">
              <span class="timeline-title">{{ activity.title }}</span>
              <span class="timeline-desc">{{ activity.desc }}</span>
            </div>
            <span class="timeline-time">{{ activity.time }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue'
import { useUserStore } from '@/stores/user'
import { getStatistics } from '@/api/dashboard'

const userStore = useUserStore()

const lineChartRef = ref<HTMLElement>()
const pieChartRef = ref<HTMLElement>()
const activePeriod = ref('周')

// 统计数据（从API加载）
const stats = reactive({
  totalUsers: 0,
  totalActivities: 0,
  totalVolunteerHours: 0,
  totalPositions: 0
})

// 问候语
const greetingText = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '夜深了'
  if (hour < 9) return '早上好'
  if (hour < 12) return '上午好'
  if (hour < 14) return '中午好'
  if (hour < 17) return '下午好'
  if (hour < 19) return '傍晚好'
  return '晚上好'
})

// 当前日期
const currentDate = computed(() => {
  const now = new Date()
  return `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日`
})

// 星期
const weekDay = computed(() => {
  const days = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
  return days[new Date().getDay()]
})

// 统计卡片（实时数据）
const statsCards = computed(() => [
  {
    title: '用户总数',
    value: stats.totalUsers.toLocaleString(),
    icon: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
    iconBg: 'linear-gradient(135deg, var(--jade-deep), var(--jade-medium))',
    trend: 'up',
    trendValue: '实时'
  },
  {
    title: '志愿活动',
    value: String(stats.totalActivities),
    icon: '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
    iconBg: 'linear-gradient(135deg, var(--vermillion), var(--vermillion-glow))',
    trend: 'up',
    trendValue: '实时'
  },
  {
    title: '志愿总时长',
    value: `${stats.totalVolunteerHours.toLocaleString()}h`,
    icon: '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>',
    iconBg: 'linear-gradient(135deg, var(--jade-medium), var(--jade-light))',
    trend: 'up',
    trendValue: '实时'
  },
  {
    title: '勤工岗位',
    value: String(stats.totalPositions),
    icon: '<rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>',
    iconBg: 'linear-gradient(135deg, var(--gold-accent), var(--gold-light))',
    trend: 'up',
    trendValue: '实时'
  }
])

// 待办事项
const todoList = ref([
  { id: 1, tag: '审核', type: 'warning', title: '张三的入团申请待审核', time: '10分钟前' },
  { id: 2, tag: '薪资', type: 'success', title: '12月勤工助学工资待确认', time: '1小时前' },
  { id: 3, tag: '活动', type: 'primary', title: '校园清洁志愿活动即将开始', time: '2小时前' },
  { id: 4, tag: '政审', type: 'danger', title: '李四的政审材料待备案', time: '3小时前' },
  { id: 5, tag: '考勤', type: 'info', title: '本周考勤异常待处理', time: '5小时前' }
])

// 快捷入口
const shortcuts = ref([
  {
    name: '用户管理',
    icon: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
    bg: 'linear-gradient(135deg, var(--jade-deep), var(--jade-medium))',
    path: '/system/user'
  },
  {
    name: '活动管理',
    icon: '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
    bg: 'linear-gradient(135deg, var(--vermillion), var(--vermillion-glow))',
    path: '/volunteer/activity'
  },
  {
    name: '岗位管理',
    icon: '<rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>',
    bg: 'linear-gradient(135deg, var(--gold-accent), var(--gold-light))',
    path: '/workstudy/position'
  },
  {
    name: '入团申请',
    icon: '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>',
    bg: 'linear-gradient(135deg, var(--jade-medium), var(--jade-light))',
    path: '/league/application'
  },
  {
    name: '时长统计',
    icon: '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>',
    bg: 'linear-gradient(135deg, var(--ink-light), var(--ink-muted))',
    path: '/volunteer/hours'
  },
  {
    name: '薪资管理',
    icon: '<line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>',
    bg: 'linear-gradient(135deg, #e67e22, #f39c12)',
    path: '/workstudy/salary'
  }
])

// 最近活动
const recentActivities = ref([
  { id: 1, type: 'success', title: '新用户注册', desc: '学生王五完成注册', time: '5分钟前' },
  { id: 2, type: 'primary', title: '活动报名', desc: '10人报名参加环保活动', time: '15分钟前' },
  { id: 3, type: 'warning', title: '待审核申请', desc: '收到3份入团申请', time: '1小时前' },
  { id: 4, type: 'info', title: '时长核算', desc: '自动核算完成50条记录', time: '2小时前' },
  { id: 5, type: 'danger', title: '异常提醒', desc: '考勤系统检测到异常', time: '3小时前' }
])

// 初始化图表
async function initCharts() {
  const echarts = await import('echarts')
  // 折线图
  if (lineChartRef.value) {
    const lineChart = echarts.init(lineChartRef.value)
    lineChart.setOption({
      tooltip: {
        trigger: 'axis',
        backgroundColor: 'rgba(26, 31, 22, 0.9)',
        borderColor: 'transparent',
        textStyle: { color: '#f7f3ec' }
      },
      grid: { left: '3%', right: '4%', bottom: '3%', top: '10%', containLabel: true },
      xAxis: {
        type: 'category',
        data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
        axisLine: { lineStyle: { color: 'rgba(26, 31, 22, 0.1)' } },
        axisLabel: { color: '#6b7560' }
      },
      yAxis: {
        type: 'value',
        axisLine: { show: false },
        splitLine: { lineStyle: { color: 'rgba(26, 31, 22, 0.06)' } },
        axisLabel: { color: '#6b7560' }
      },
      series: [
        {
          name: '活动数',
          type: 'line',
          smooth: true,
          data: [5, 8, 6, 10, 12, 15, 8],
          lineStyle: { color: '#2a6b5e', width: 3 },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(42, 107, 94, 0.3)' },
              { offset: 1, color: 'rgba(42, 107, 94, 0)' }
            ])
          },
          itemStyle: { color: '#2a6b5e' },
          symbol: 'circle',
          symbolSize: 6
        },
        {
          name: '参与人数',
          type: 'line',
          smooth: true,
          data: [50, 80, 60, 100, 120, 150, 80],
          lineStyle: { color: '#c43a31', width: 3 },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(196, 58, 49, 0.2)' },
              { offset: 1, color: 'rgba(196, 58, 49, 0)' }
            ])
          },
          itemStyle: { color: '#c43a31' },
          symbol: 'circle',
          symbolSize: 6
        }
      ]
    })
  }

  // 饼图
  if (pieChartRef.value) {
    const pieChart = echarts.init(pieChartRef.value)
    pieChart.setOption({
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(26, 31, 22, 0.9)',
        borderColor: 'transparent',
        textStyle: { color: '#f7f3ec' }
      },
      series: [
        {
          name: '活动类型',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 6,
            borderColor: '#fafaf7',
            borderWidth: 2
          },
          label: {
            show: true,
            position: 'outside',
            color: '#4a5240',
            fontSize: 12
          },
          emphasis: {
            label: { show: true, fontSize: 14, fontWeight: 'bold' }
          },
          data: [
            { value: 35, name: '环保公益', itemStyle: { color: '#2a6b5e' } },
            { value: 25, name: '社区服务', itemStyle: { color: '#c43a31' } },
            { value: 20, name: '教育支教', itemStyle: { color: '#c9a94e' } },
            { value: 15, name: '文化传承', itemStyle: { color: '#4a5240' } },
            { value: 5, name: '其他', itemStyle: { color: '#6b7560' } }
          ]
        }
      ]
    })
  }
}

onMounted(async () => {
  // 加载实时统计数据
  try {
    const res: any = await getStatistics()
    if (res.code === 200) {
      stats.totalUsers = res.data.totalUsers
      stats.totalActivities = res.data.totalActivities
      stats.totalVolunteerHours = res.data.totalVolunteerHours
      stats.totalPositions = res.data.totalPositions
    }
  } catch (e) {
    console.error('加载统计数据失败:', e)
  }
  initCharts()
})
</script>

<style scoped lang="scss">
.dashboard-scene {
  padding: 24px;
  animation: fadeIn 0.5s ease;
}

/* ═══ 欢迎区 ═══ */
.welcome-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32px;
  background: linear-gradient(135deg, var(--ink-deep) 0%, var(--ink-medium) 100%);
  border-radius: var(--radius-xl);
  margin-bottom: 24px;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    inset: 0;
    background:
      url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.03'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
  }

  .welcome-content {
    position: relative;
    z-index: 1;
  }

  .greeting {
    h1 {
      font-size: 28px;
      font-weight: 700;
      color: var(--paper-cream);
      margin-bottom: 8px;
      font-family: 'Noto Serif SC', serif;
    }
    p {
      font-size: 14px;
      color: rgba(247, 243, 236, 0.6);
    }
  }

  .welcome-poem {
    margin-top: 16px;
    span {
      font-size: 15px;
      color: var(--gold-accent);
      font-style: italic;
      font-family: 'STKaiti', 'KaiTi', serif;
      letter-spacing: 2px;
    }
  }

  .welcome-decoration {
    position: relative;
    width: 120px;
    height: 120px;

    .ink-circle {
      position: absolute;
      width: 100px;
      height: 100px;
      border: 1px solid rgba(201, 169, 78, 0.2);
      border-radius: 50%;
      animation: float 6s ease-in-out infinite;

      &.small {
        width: 60px;
        height: 60px;
        bottom: 0;
        right: 0;
        animation-delay: -3s;
      }
    }
  }
}

/* ═══ 统计卡片 ═══ */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--paper-white);
  border-radius: var(--radius-lg);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(26, 31, 22, 0.04);
  transition: all var(--transition-smooth);
  animation: fadeInUp 0.5s ease forwards;
  opacity: 0;

  &:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-md);
  }

  .stat-icon {
    width: 52px;
    height: 52px;
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    svg {
      width: 24px;
      height: 24px;
    }
  }

  .stat-info {
    flex: 1;
    min-width: 0;

    .stat-value {
      display: block;
      font-size: 24px;
      font-weight: 700;
      color: var(--ink-deep);
      line-height: 1.2;
    }

    .stat-title {
      display: block;
      font-size: 13px;
      color: var(--text-tertiary);
      margin-top: 4px;
    }
  }

  .stat-trend {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    font-weight: 600;
    padding: 4px 8px;
    border-radius: 20px;

    &.up {
      color: var(--jade-deep);
      background: var(--jade-soft);
    }

    &.down {
      color: var(--vermillion);
      background: var(--vermillion-soft);
    }
  }
}

/* ═══ 内容网格 ═══ */
.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
  margin-bottom: 24px;
}

.chart-card {
  background: var(--paper-white);
  border-radius: var(--radius-lg);
  padding: 24px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(26, 31, 22, 0.04);

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    .header-title {
      display: flex;
      align-items: center;
      gap: 10px;

      .title-accent {
        width: 4px;
        height: 20px;
        background: var(--jade-deep);
        border-radius: 2px;

        &.vermillion { background: var(--vermillion); }
        &.gold { background: var(--gold-accent); }
        &.jade { background: var(--jade-deep); }
      }

      h3 {
        font-size: 16px;
        font-weight: 600;
        color: var(--ink-deep);
        font-family: 'Noto Serif SC', serif;
      }
    }

    .header-actions {
      display: flex;
      gap: 4px;
    }

    .header-link {
      font-size: 13px;
      color: var(--jade-deep);
      cursor: pointer;
      transition: color var(--transition-fast);

      &:hover {
        color: var(--jade-medium);
      }
    }
  }

  .chart-area {
    height: 300px;
  }
}

.period-btn {
  padding: 6px 16px;
  border: none;
  background: var(--paper-cream);
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition-fast);

  &.active {
    background: var(--jade-deep);
    color: white;
  }

  &:hover:not(.active) {
    background: var(--paper-warm);
  }
}

/* ═══ 底部网格 ═══ */
.bottom-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 20px;
}

.todo-card,
.shortcuts-card,
.recent-card {
  background: var(--paper-white);
  border-radius: var(--radius-lg);
  padding: 24px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(26, 31, 22, 0.04);

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    .header-title {
      display: flex;
      align-items: center;
      gap: 10px;

      .title-accent {
        width: 4px;
        height: 20px;
        background: var(--jade-deep);
        border-radius: 2px;

        &.vermillion { background: var(--vermillion); }
        &.gold { background: var(--gold-accent); }
        &.jade { background: var(--jade-deep); }
      }

      h3 {
        font-size: 16px;
        font-weight: 600;
        color: var(--ink-deep);
        font-family: 'Noto Serif SC', serif;
      }
    }
  }
}

/* ═══ 待办列表 ═══ */
.todo-list {
  .todo-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--paper-warm);
    animation: fadeInUp 0.3s ease forwards;
    opacity: 0;

    &:last-child {
      border-bottom: none;
    }

    .todo-status {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      flex-shrink: 0;

      &.warning { background: var(--gold-accent); }
      &.success { background: var(--jade-deep); }
      &.primary { background: var(--jade-medium); }
      &.danger { background: var(--vermillion); }
      &.info { background: var(--ink-muted); }
    }

    .todo-content {
      flex: 1;
      min-width: 0;

      .todo-title {
        display: block;
        font-size: 13px;
        color: var(--text-primary);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .todo-time {
        display: block;
        font-size: 11px;
        color: var(--text-tertiary);
        margin-top: 2px;
      }
    }

    .todo-tag {
      font-size: 11px;
      padding: 2px 8px;
      border-radius: 10px;
      font-weight: 500;

      &.warning {
        color: var(--gold-accent);
        background: var(--gold-soft);
      }
      &.success {
        color: var(--jade-deep);
        background: var(--jade-soft);
      }
      &.primary {
        color: var(--jade-medium);
        background: var(--jade-soft);
      }
      &.danger {
        color: var(--vermillion);
        background: var(--vermillion-soft);
      }
      &.info {
        color: var(--ink-muted);
        background: rgba(107, 117, 96, 0.08);
      }
    }
  }
}

/* ═══ 快捷入口 ═══ */
.shortcuts-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.shortcut-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 16px 8px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--transition-smooth);

  &:hover {
    background: var(--paper-cream);
    transform: translateY(-2px);

    .shortcut-icon {
      transform: scale(1.1);
    }
  }

  .shortcut-icon {
    width: 44px;
    height: 44px;
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform var(--transition-smooth);

    svg {
      width: 20px;
      height: 20px;
    }
  }

  .shortcut-name {
    font-size: 12px;
    color: var(--text-secondary);
    text-align: center;
  }
}

/* ═══ 最近活动 ═══ */
.activity-timeline {
  .timeline-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--paper-warm);
    animation: fadeInUp 0.3s ease forwards;
    opacity: 0;

    &:last-child {
      border-bottom: none;
    }

    .timeline-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-top: 6px;
      flex-shrink: 0;

      &.success { background: var(--jade-deep); }
      &.primary { background: var(--jade-medium); }
      &.warning { background: var(--gold-accent); }
      &.danger { background: var(--vermillion); }
      &.info { background: var(--ink-muted); }
    }

    .timeline-content {
      flex: 1;
      min-width: 0;

      .timeline-title {
        display: block;
        font-size: 13px;
        font-weight: 500;
        color: var(--text-primary);
      }

      .timeline-desc {
        display: block;
        font-size: 12px;
        color: var(--text-tertiary);
        margin-top: 2px;
      }
    }

    .timeline-time {
      font-size: 11px;
      color: var(--text-tertiary);
      white-space: nowrap;
    }
  }
}

/* ═══ 响应式 ═══ */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .content-grid {
    grid-template-columns: 1fr;
  }

  .bottom-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .welcome-section {
    flex-direction: column;
    text-align: center;

    .welcome-decoration {
      display: none;
    }
  }
}
</style>
