<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div><h1>考勤管理</h1><p>管理勤工助学考勤记录</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.checkDate" placeholder="日期(如2026-07-21)" clearable style="width:160px" @keyup.enter="handleQuery" />
        <el-input v-model="queryParams.userId" placeholder="用户ID" clearable style="width:110px" @keyup.enter="handleQuery" />
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
        <div style="flex:1" />
        <el-button v-if="isAdmin" type="primary" @click="handleAdd">新增考勤</el-button>
      </div>

      <el-table :data="attendanceList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="real_name" label="姓名" width="100" />
        <el-table-column prop="user_id" label="用户ID" width="80" />
        <el-table-column prop="position_id" label="岗位ID" width="80" />
        <el-table-column prop="check_date" label="日期" width="110" />
        <el-table-column label="签到时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.check_in_time) }}</template>
        </el-table-column>
        <el-table-column label="签退时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.check_out_time) }}</template>
        </el-table-column>
        <el-table-column prop="work_hours" label="工时" width="80" align="center">
          <template #default="{ row }">{{ Number(row.work_hours).toFixed(2) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : row.status === 2 ? 'danger' : 'warning'" size="small">
              {{ row.status === 0 ? '待审' : row.status === 1 ? '通过' : '异常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column v-if="isAdmin" label="操作" width="130" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="success" link size="small" @click="handleAudit(row, 1)">通过</el-button>
            <el-button v-if="row.status === 0" type="danger" link size="small" @click="handleAudit(row, 2)">异常</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>

    <el-dialog v-model="dialogVisible" title="新增考勤记录" width="500px">
      <el-form :model="formData" :rules="formRules" label-width="100px" ref="formRef">
        <el-form-item label="用户ID" prop="userId">
          <el-input-number v-model="formData.userId" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="岗位ID" prop="positionId">
          <el-input-number v-model="formData.positionId" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="formData.realName" />
        </el-form-item>
        <el-form-item label="日期" prop="checkDate">
          <el-date-picker v-model="formData.checkDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="签到时间">
          <el-date-picker v-model="formData.checkInTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" placeholder="选填" />
        </el-form-item>
        <el-form-item label="签退时间">
          <el-date-picker v-model="formData.checkOutTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" placeholder="选填" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="formData.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAttendancePage, createAttendance, auditAttendance } from '@/api/workstudy'
import { usePermission } from '@/utils/permission'
import { formatDateTime } from '@/utils/date'

const { isAdmin } = usePermission()

const loading = ref(false)
const total = ref(0)
const attendanceList = ref<any[]>([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref()

const queryParams = reactive({
  checkDate: '',
  userId: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const formData = reactive<any>({
  userId: 0, positionId: 0, realName: '',
  checkDate: '', checkInTime: '', checkOutTime: '', remark: ''
})

const formRules = {
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  positionId: [{ required: true, message: '请输入岗位ID', trigger: 'blur' }],
  checkDate: [{ required: true, message: '请选择日期', trigger: 'change' }]
}

async function handleQuery() {
  loading.value = true
  try {
    const params: any = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.checkDate) params.checkDate = queryParams.checkDate
    if (queryParams.userId) params.userId = queryParams.userId
    const res: any = await getAttendancePage(params)
    if (res.code === 200) {
      attendanceList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) { console.error('查询失败:', e) } finally { loading.value = false }
}

function resetQuery() {
  queryParams.checkDate = ''
  queryParams.userId = undefined
  queryParams.pageNum = 1
  handleQuery()
}

function handleAdd() {
  Object.assign(formData, { userId: 0, positionId: 0, realName: '', checkDate: '', checkInTime: '', checkOutTime: '', remark: '' })
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    const res: any = await createAttendance(formData)
    if (res.code === 200) {
      ElMessage.success('记录成功')
      dialogVisible.value = false
      handleQuery()
    } else { ElMessage.error(res.msg) }
  } catch (e) { ElMessage.error('操作失败') } finally { submitLoading.value = false }
}

async function handleAudit(row: any, status: number) {
  try {
    const res: any = await auditAttendance({ id: row.id, status })
    if (res.code === 200) { ElMessage.success('审核完成'); handleQuery() }
    else { ElMessage.error(res.msg) }
  } catch (e) { ElMessage.error('审核失败') }
}

onMounted(() => handleQuery())
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.card-container { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
