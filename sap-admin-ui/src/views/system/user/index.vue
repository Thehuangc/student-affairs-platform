<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
            <circle cx="12" cy="7" r="4" />
          </svg>
        </div>
        <div>
          <h1>用户管理</h1>
          <p>管理系统用户信息和权限</p>
        </div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.username" placeholder="搜索用户名" clearable @keyup.enter="handleQuery" />
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </div>

      <el-table :data="userList" v-loading="loading" border>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="nickname" label="昵称" width="120" />
        <el-table-column prop="real_name" label="真实姓名" width="120" />
        <el-table-column prop="student_no" label="学号" width="120" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="handleQuery"
          @current-change="handleQuery"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUserList } from '@/api/user'

const loading = ref(false)
const total = ref(0)
const userList = ref<any[]>([])

const queryParams = reactive({
  username: '',
  status: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getUserList(queryParams)
    if (res.code === 200) {
      userList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.username = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  handleQuery()
}

async function handleDelete(row: any) {
  try {
    await ElMessageBox.confirm(`确认删除用户 ${row.username} 吗？`, '提示', {
      type: 'warning'
    })
    ElMessage.success('删除成功')
    handleQuery()
  } catch (e) {
    // 取消
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header {
  padding: 28px 32px;
  background: linear-gradient(135deg, var(--jade-deep) 0%, var(--jade-medium) 100%);
  border-radius: var(--radius-xl);
  position: relative;
  overflow: hidden;
}
.page-header .header-info {
  display: flex;
  align-items: center;
  gap: 16px;
  position: relative;
  z-index: 1;
}
.page-header .header-icon {
  width: 52px;
  height: 52px;
  background: rgba(255,255,255,0.15);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
}
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
</style>
