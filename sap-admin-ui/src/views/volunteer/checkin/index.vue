<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg></div>
        <div><h1>签到记录</h1><p>查看志愿活动签到打卡记录</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-select v-model="queryParams.activityId" placeholder="选择活动" clearable style="width:200px">
          <el-option v-for="a in activityOptions" :key="a.id" :label="a.title" :value="a.id" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </div>

      <el-table :data="checkinList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="real_name" label="姓名" width="100" />
        <el-table-column prop="user_id" label="用户ID" width="80" />
        <el-table-column label="签到时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.check_in_time) }}</template>
        </el-table-column>
        <el-table-column label="签退时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.check_out_time) }}</template>
        </el-table-column>
        <el-table-column label="时长(小时)" width="110" align="center">
          <template #default="{ row }">{{ row.duration ? Number(row.duration).toFixed(2) : '-' }}</template>
        </el-table-column>
        <el-table-column prop="check_in_location" label="签到位置" min-width="160" show-overflow-tooltip />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '已完成' : '已签到' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="activity_id" label="活动ID" width="80" />
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { getActivityPage } from '@/api/volunteer'
import request from '@/utils/request'
import { formatDateTime } from '@/utils/date'

const loading = ref(false)
const total = ref(0)
const checkinList = ref<any[]>([])
const activityOptions = ref<any[]>([])

const queryParams = reactive({
  activityId: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

async function getCheckinPage(params: any) {
  return request({ url: '/volunteer/checkin/page', method: 'get', params })
}

async function handleQuery() {
  loading.value = true
  try {
    const params: any = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.activityId) params.activityId = queryParams.activityId
    const res: any = await getCheckinPage(params)
    if (res.code === 200) {
      checkinList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.activityId = undefined
  queryParams.pageNum = 1
  handleQuery()
}

async function loadActivities() {
  const res: any = await getActivityPage({ pageNum: 1, pageSize: 999 })
  if (res.code === 200) activityOptions.value = res.data.rows
}

onMounted(() => {
  handleQuery()
  loadActivities()
})
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.card-container { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
