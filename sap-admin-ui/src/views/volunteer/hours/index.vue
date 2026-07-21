<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div><h1>时长统计</h1><p>查看志愿时长记录和统计</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.statMonth" placeholder="月份(如2026-07)" clearable style="width:160px" @keyup.enter="handleQuery" />
        <el-input v-model="queryParams.userId" placeholder="用户ID" clearable style="width:120px" @keyup.enter="handleQuery" />
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </div>

      <el-table :data="hoursList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="real_name" label="姓名" width="100" />
        <el-table-column prop="user_id" label="用户ID" width="80" />
        <el-table-column prop="activity_title" label="活动名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="activity_id" label="活动ID" width="80" />
        <el-table-column prop="hours" label="时长(小时)" width="110" align="center">
          <template #default="{ row }">{{ Number(row.hours).toFixed(2) }}</template>
        </el-table-column>
        <el-table-column prop="record_type" label="记录类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.record_type === 'auto' ? 'success' : 'warning'" size="small">
              {{ row.record_type === 'auto' ? '自动' : '手动' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="stat_month" label="统计月份" width="100" align="center" />
        <el-table-column prop="created_at" label="记录时间" width="170" />
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { getHoursPage } from '@/api/volunteer'

const loading = ref(false)
const total = ref(0)
const hoursList = ref<any[]>([])

const queryParams = reactive({
  statMonth: '',
  userId: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

async function handleQuery() {
  loading.value = true
  try {
    const params: any = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.statMonth) params.statMonth = queryParams.statMonth
    if (queryParams.userId) params.userId = queryParams.userId
    const res: any = await getHoursPage(params)
    if (res.code === 200) {
      hoursList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.statMonth = ''
  queryParams.userId = undefined
  queryParams.pageNum = 1
  handleQuery()
}

onMounted(() => handleQuery())
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.card-container { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
