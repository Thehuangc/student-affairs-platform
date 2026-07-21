<template>
  <div class="page-scene">
    <!-- ═══ 页面头部 ═══ -->
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
            <line x1="16" y1="2" x2="16" y2="6" />
            <line x1="8" y1="2" x2="8" y2="6" />
            <line x1="3" y1="10" x2="21" y2="10" />
          </svg>
        </div>
        <div>
          <h1>活动管理</h1>
          <p>管理和监督志愿活动的全流程</p>
        </div>
      </div>
      <div class="header-stats">
        <div class="stat-badge">
          <span class="stat-num">{{ total }}</span>
          <span class="stat-label">活动总数</span>
        </div>
      </div>
    </div>

    <!-- ═══ 搜索区域 ═══ -->
    <div class="filter-card">
      <div class="filter-row">
        <div class="filter-fields">
          <div class="field-group">
            <label>活动标题</label>
            <el-input
              v-model="queryParams.title"
              placeholder="输入关键词搜索"
              clearable
              @keyup.enter="handleQuery"
            >
              <template #prefix>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="16" height="16">
                  <circle cx="11" cy="11" r="8" />
                  <path d="M21 21l-4.35-4.35" />
                </svg>
              </template>
            </el-input>
          </div>
          <div class="field-group">
            <label>活动状态</label>
            <el-select v-model="queryParams.status" placeholder="全部状态" clearable>
              <el-option label="未开始" :value="0" />
              <el-option label="进行中" :value="1" />
              <el-option label="已结束" :value="2" />
              <el-option label="已取消" :value="3" />
            </el-select>
          </div>
        </div>
        <div class="filter-actions">
          <button class="btn-primary" @click="handleQuery">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="16" height="16">
              <circle cx="11" cy="11" r="8" />
              <path d="M21 21l-4.35-4.35" />
            </svg>
            查询
          </button>
          <button class="btn-ghost" @click="resetQuery">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="16" height="16">
              <polyline points="1 4 1 10 7 10" />
              <path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10" />
            </svg>
            重置
          </button>
        </div>
      </div>
    </div>

    <!-- ═══ 表格区域 ═══ -->
    <div class="table-card">
      <div class="table-header">
        <h3>活动列表</h3>
        <button v-if="isAdmin" class="btn-primary" @click="handleAdd">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
          新增活动
        </button>
      </div>

      <el-table :data="activityList" v-loading="loading" class="custom-table">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="title" label="活动标题" min-width="200">
          <template #default="{ row }">
            <div class="activity-title-cell">
              <span class="title-text">{{ row.title }}</span>
              <span class="title-type">{{ row.activity_type }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="location" label="地点" width="140" show-overflow-tooltip />
        <el-table-column label="时间" width="180">
          <template #default="{ row }">
            <div class="time-cell">
              <span>{{ formatDateTime(row.start_time) }}</span>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="12" height="12">
                <path d="M5 12h14" />
                <path d="M12 5l7 7-7 7" />
              </svg>
              <span>{{ formatDateTime(row.end_time) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="参与" width="100" align="center">
          <template #default="{ row }">
            <div class="participants-cell">
              <div class="progress-ring">
                <svg viewBox="0 0 36 36">
                  <path
                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    fill="none"
                    stroke="var(--paper-warm)"
                    stroke-width="3"
                  />
                  <path
                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    fill="none"
                    stroke="var(--jade-deep)"
                    stroke-width="3"
                    :stroke-dasharray="`${(row.current_participants / row.max_participants) * 100}, 100`"
                  />
                </svg>
              </div>
              <span>{{ row.current_participants }}/{{ row.max_participants }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <span class="status-badge" :class="getStatusClass(row.status)">
              {{ getStatusText(row.status) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column v-if="isAdmin" label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <div class="action-cell">
              <button class="action-btn edit" @click="handleEdit(row)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="14" height="14">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                </svg>
                编辑
              </button>
              <button
                v-if="row.status === 0"
                class="action-btn cancel"
                @click="handleCancel(row)"
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="14" height="14">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="15" y1="9" x2="9" y2="15" />
                  <line x1="9" y1="9" x2="15" y2="15" />
                </svg>
                取消
              </button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <div class="table-footer">
        <span class="total-info">共 {{ total }} 条记录</span>
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="sizes, prev, pager, next"
          @size-change="handleQuery"
          @current-change="handleQuery"
        />
      </div>
    </div>

    <!-- ═══ 新增/编辑对话框 ═══ -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      class="custom-dialog"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        class="dialog-form"
      >
        <el-form-item label="活动标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入活动标题" />
        </el-form-item>
        <el-form-item label="活动类型" prop="activityType">
          <el-select v-model="form.activityType" placeholder="请选择活动类型" style="width: 100%">
            <el-option label="环保公益" value="环保公益" />
            <el-option label="社区服务" value="社区服务" />
            <el-option label="教育支教" value="教育支教" />
            <el-option label="文化传承" value="文化传承" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="活动地点" prop="location">
          <el-input v-model="form.location" placeholder="请输入活动地点" />
        </el-form-item>
        <div class="form-row">
          <el-form-item label="开始时间" prop="startTime" class="form-col">
            <el-date-picker
              v-model="form.startTime"
              type="datetime"
              placeholder="选择开始时间"
              value-format="YYYY-MM-DD HH:mm:ss"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="结束时间" prop="endTime" class="form-col">
            <el-date-picker
              v-model="form.endTime"
              type="datetime"
              placeholder="选择结束时间"
              value-format="YYYY-MM-DD HH:mm:ss"
              style="width: 100%"
            />
          </el-form-item>
        </div>
        <el-form-item label="最大人数" prop="maxParticipants">
          <el-input-number v-model="form.maxParticipants" :min="1" :max="1000" style="width: 100%" />
        </el-form-item>
        <div class="form-row">
          <el-form-item label="组织者" class="form-col">
            <el-input v-model="form.organizer" placeholder="请输入组织者" />
          </el-form-item>
          <el-form-item label="联系人" class="form-col">
            <el-input v-model="form.contactPerson" placeholder="请输入联系人" />
          </el-form-item>
        </div>
        <div class="form-row">
          <el-form-item label="联系电话" class="form-col">
            <el-input v-model="form.contactPhone" placeholder="请输入联系电话" />
          </el-form-item>
          <el-form-item label="签到码" class="form-col">
            <el-input v-model="form.checkInCode" placeholder="签到码（可选）" />
          </el-form-item>
        </div>
        <el-form-item label="活动内容">
          <el-input v-model="form.content" type="textarea" :rows="4" placeholder="请输入活动内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <button class="btn-ghost" @click="dialogVisible = false">取 消</button>
        <button class="btn-primary" @click="handleSubmit" :disabled="submitLoading">
          {{ submitLoading ? '提交中...' : '确 定' }}
        </button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { getActivityPage, createActivity, updateActivity, cancelActivity } from '@/api/volunteer'
import { usePermission } from '@/utils/permission'

const { isAdmin, canEdit, canDelete } = usePermission()

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('')
const total = ref(0)
const formRef = ref<FormInstance>()

const queryParams = reactive({
  title: '',
  status: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const activityList = ref<any[]>([])

const form = reactive({
  id: undefined as number | undefined,
  title: '',
  activityType: '',
  location: '',
  startTime: '',
  endTime: '',
  maxParticipants: 50,
  organizer: '',
  contactPerson: '',
  contactPhone: '',
  checkInCode: '',
  content: ''
})

const rules: FormRules = {
  title: [{ required: true, message: '请输入活动标题', trigger: 'blur' }],
  activityType: [{ required: true, message: '请选择活动类型', trigger: 'change' }],
  location: [{ required: true, message: '请输入活动地点', trigger: 'blur' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  maxParticipants: [{ required: true, message: '请输入最大参与人数', trigger: 'blur' }]
}

// 格式化日期时间
function formatDateTime(dateTime: string) {
  if (!dateTime) return ''
  const date = new Date(dateTime)
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${month}-${day} ${hours}:${minutes}`
}

// 获取状态样式类
function getStatusClass(status: number) {
  const map: Record<number, string> = {
    0: 'pending',
    1: 'active',
    2: 'ended',
    3: 'cancelled'
  }
  return map[status] || ''
}

// 获取状态文本
function getStatusText(status: number) {
  const map: Record<number, string> = {
    0: '未开始',
    1: '进行中',
    2: '已结束',
    3: '已取消'
  }
  return map[status] || '未知'
}

// 查询列表
async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getActivityPage(queryParams)
    activityList.value = res.data.rows
    total.value = res.data.total
  } catch (error) {
    console.error('查询失败:', error)
  } finally {
    loading.value = false
  }
}

// 重置查询
function resetQuery() {
  queryParams.title = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  handleQuery()
}

// 新增
function handleAdd() {
  dialogTitle.value = '新增活动'
  form.id = undefined
  form.title = ''
  form.activityType = ''
  form.location = ''
  form.startTime = ''
  form.endTime = ''
  form.maxParticipants = 50
  form.organizer = ''
  form.contactPerson = ''
  form.contactPhone = ''
  form.checkInCode = ''
  form.content = ''
  dialogVisible.value = true
}

// 编辑
function handleEdit(row: any) {
  dialogTitle.value = '编辑活动'
  Object.assign(form, {
    id: row.id,
    title: row.title,
    activityType: row.activity_type || '',
    location: row.location,
    startTime: row.start_time,
    endTime: row.end_time,
    maxParticipants: row.max_participants,
    organizer: row.organizer || '',
    contactPerson: row.contact_person || '',
    contactPhone: row.contact_phone || '',
    checkInCode: row.check_in_code || '',
    content: row.content || ''
  })
  dialogVisible.value = true
}

// 取消活动
async function handleCancel(row: any) {
  try {
    await ElMessageBox.confirm('确认取消该活动吗？取消后无法恢复。', '提示', {
      type: 'warning',
      confirmButtonText: '确认取消',
      cancelButtonText: '再想想'
    })
    await cancelActivity(row.id)
    ElMessage.success('取消成功')
    handleQuery()
  } catch (error) {
    console.error('取消失败:', error)
  }
}

// 提交表单
async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitLoading.value = true
  try {
    if (form.id) {
      await updateActivity(form)
      ElMessage.success('更新成功')
    } else {
      await createActivity(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    handleQuery()
  } catch (error) {
    console.error('提交失败:', error)
  } finally {
    submitLoading.value = false
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped lang="scss">
.page-scene {
  padding: 24px;
  animation: fadeIn 0.5s ease;
}

/* ═══ 页面头部 ═══ */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 28px 32px;
  background: linear-gradient(135deg, var(--jade-deep) 0%, var(--jade-medium) 100%);
  border-radius: var(--radius-xl);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    inset: 0;
    background:
      url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
  }

  .header-info {
    display: flex;
    align-items: center;
    gap: 16px;
    position: relative;
    z-index: 1;

    .header-icon {
      width: 52px;
      height: 52px;
      background: rgba(255, 255, 255, 0.15);
      border-radius: var(--radius-md);
      display: flex;
      align-items: center;
      justify-content: center;
      backdrop-filter: blur(10px);

      svg {
        width: 24px;
        height: 24px;
        color: white;
      }
    }

    h1 {
      font-size: 24px;
      font-weight: 700;
      color: white;
      margin-bottom: 4px;
      font-family: 'Noto Serif SC', serif;
    }

    p {
      font-size: 14px;
      color: rgba(255, 255, 255, 0.7);
    }
  }

  .header-stats {
    position: relative;
    z-index: 1;
  }

  .stat-badge {
    text-align: center;
    padding: 12px 24px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: var(--radius-md);
    backdrop-filter: blur(10px);

    .stat-num {
      display: block;
      font-size: 28px;
      font-weight: 700;
      color: white;
    }

    .stat-label {
      display: block;
      font-size: 12px;
      color: rgba(255, 255, 255, 0.7);
      margin-top: 4px;
    }
  }
}

/* ═══ 筛选卡片 ═══ */
.filter-card {
  background: var(--paper-white);
  border-radius: var(--radius-lg);
  padding: 20px 24px;
  margin-bottom: 20px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(26, 31, 22, 0.04);

  .filter-row {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: 20px;
  }

  .filter-fields {
    display: flex;
    gap: 20px;
    flex: 1;
  }

  .field-group {
    flex: 1;
    max-width: 280px;

    label {
      display: block;
      font-size: 13px;
      color: var(--text-secondary);
      margin-bottom: 8px;
      font-weight: 500;
    }
  }

  .filter-actions {
    display: flex;
    gap: 10px;
  }
}

/* ═══ 按钮样式 ═══ */
.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 10px 20px;
  background: var(--jade-deep);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);

  &:hover:not(:disabled) {
    background: var(--jade-medium);
    transform: translateY(-1px);
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
}

.btn-ghost {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 10px 20px;
  background: transparent;
  color: var(--text-secondary);
  border: 1px solid var(--paper-warm);
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);

  &:hover {
    border-color: var(--jade-light);
    color: var(--jade-deep);
    background: var(--jade-soft);
  }
}

/* ═══ 表格卡片 ═══ */
.table-card {
  background: var(--paper-white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(26, 31, 22, 0.04);
  overflow: hidden;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid var(--paper-warm);

  h3 {
    font-size: 16px;
    font-weight: 600;
    color: var(--ink-deep);
    font-family: 'Noto Serif SC', serif;
  }
}

.custom-table {
  :deep(.el-table__header th) {
    background: var(--paper-cream);
    color: var(--text-secondary);
    font-weight: 600;
    font-size: 13px;
  }

  :deep(.el-table__row) {
    &:hover {
      background: var(--jade-soft) !important;
    }
  }

  :deep(.el-table__cell) {
    padding: 16px 12px;
  }
}

/* ═══ 表格单元格样式 ═══ */
.activity-title-cell {
  .title-text {
    display: block;
    font-weight: 500;
    color: var(--ink-deep);
  }

  .title-type {
    display: inline-block;
    margin-top: 4px;
    font-size: 11px;
    padding: 2px 8px;
    background: var(--jade-soft);
    color: var(--jade-deep);
    border-radius: 10px;
  }
}

.time-cell {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: var(--text-secondary);
}

.participants-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;

  .progress-ring {
    width: 36px;
    height: 36px;

    svg {
      width: 100%;
      height: 100%;
      transform: rotate(-90deg);
    }
  }

  span {
    font-size: 12px;
    color: var(--text-secondary);
  }
}

.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;

  &.pending {
    background: var(--gold-soft);
    color: var(--gold-accent);
  }

  &.active {
    background: var(--jade-soft);
    color: var(--jade-deep);
  }

  &.ended {
    background: rgba(107, 117, 96, 0.08);
    color: var(--ink-muted);
  }

  &.cancelled {
    background: var(--vermillion-soft);
    color: var(--vermillion);
  }
}

.action-cell {
  display: flex;
  gap: 8px;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition-fast);

  &.edit {
    background: var(--jade-soft);
    color: var(--jade-deep);

    &:hover {
      background: var(--jade-deep);
      color: white;
    }
  }

  &.cancel {
    background: var(--vermillion-soft);
    color: var(--vermillion);

    &:hover {
      background: var(--vermillion);
      color: white;
    }
  }
}

.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-top: 1px solid var(--paper-warm);

  .total-info {
    font-size: 13px;
    color: var(--text-tertiary);
  }
}

/* ═══ 对话框样式 ═══ */
.custom-dialog {
  :deep(.el-dialog__header) {
    padding: 20px 24px;
    border-bottom: 1px solid var(--paper-warm);
    margin: 0;
  }

  :deep(.el-dialog__body) {
    padding: 24px;
  }

  :deep(.el-dialog__footer) {
    padding: 16px 24px;
    border-top: 1px solid var(--paper-warm);
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
}

.dialog-form {
  .form-row {
    display: flex;
    gap: 20px;

    .form-col {
      flex: 1;
    }
  }
}

/* ═══ 响应式 ═══ */
@media (max-width: 1200px) {
  .filter-row {
    flex-direction: column;
    align-items: stretch;
  }

  .filter-fields {
    flex-direction: column;
  }

  .field-group {
    max-width: 100%;
  }
}
</style>
