<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg></div>
        <div><h1>薪资管理</h1><p>管理勤工助学薪资发放</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.salaryMonth" placeholder="月份(如2026-07)" clearable style="width:160px" @keyup.enter="handleQuery" />
        <el-input v-model="queryParams.userId" placeholder="用户ID" clearable style="width:110px" @keyup.enter="handleQuery" />
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
        <div style="flex:1" />
        <el-button v-if="isAdmin" type="primary" @click="handleAdd">生成薪资</el-button>
      </div>

      <el-table :data="salaryList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="real_name" label="姓名" width="100" />
        <el-table-column prop="student_no" label="学号" width="110" />
        <el-table-column prop="salary_month" label="月份" width="90" align="center" />
        <el-table-column prop="total_hours" label="总工时" width="80" align="center">
          <template #default="{ row }">{{ Number(row.total_hours).toFixed(1) }}</template>
        </el-table-column>
        <el-table-column prop="salary_per_hour" label="时薪" width="70" align="center">¥{{ row.salary_per_hour }}</el-table-column>
        <el-table-column prop="base_salary" label="基础工资" width="100" align="center">¥{{ Number(row.base_salary).toFixed(2) }}</el-table-column>
        <el-table-column prop="bonus" label="奖金" width="90" align="center">¥{{ Number(row.bonus || 0).toFixed(2) }}</el-table-column>
        <el-table-column prop="actual_salary" label="实发工资" width="110" align="center">
          <span style="font-weight:700;color:var(--jade-deep)">¥{{ Number(row.actual_salary).toFixed(2) }}</span>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 2 ? 'success' : row.status === 1 ? 'warning' : 'info'" size="small">
              {{ row.status === 0 ? '待确认' : row.status === 1 ? '已确认' : '已发放' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column v-if="isAdmin" label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="warning" link size="small" @click="handlePay(row, 1)">确认</el-button>
            <el-button v-if="row.status === 1" type="success" link size="small" @click="handlePay(row, 2)">发放</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>

    <el-dialog v-model="dialogVisible" title="生成薪资" width="450px">
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
        <el-form-item label="学号" prop="studentNo">
          <el-input v-model="formData.studentNo" />
        </el-form-item>
        <el-form-item label="月份" prop="salaryMonth">
          <el-input v-model="formData.salaryMonth" placeholder="如 2026-07" />
        </el-form-item>
        <el-form-item label="时薪" prop="salaryPerHour">
          <el-input-number v-model="formData.salaryPerHour" :min="0" :precision="2" :step="0.5" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">生成</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getSalaryPage, generateSalary, paySalary } from '@/api/workstudy'
import { usePermission } from '@/utils/permission'

const { isAdmin } = usePermission()

const loading = ref(false)
const total = ref(0)
const salaryList = ref<any[]>([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref()

const queryParams = reactive({
  salaryMonth: '',
  userId: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const formData = reactive({
  userId: 0, positionId: 0, realName: '', studentNo: '',
  salaryMonth: '', salaryPerHour: 0
})

const formRules = {
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  positionId: [{ required: true, message: '请输入岗位ID', trigger: 'blur' }],
  salaryMonth: [{ required: true, message: '请输入月份', trigger: 'blur' }],
  salaryPerHour: [{ required: true, message: '请输入时薪', trigger: 'blur' }]
}

async function handleQuery() {
  loading.value = true
  try {
    const params: any = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.salaryMonth) params.salaryMonth = queryParams.salaryMonth
    if (queryParams.userId) params.userId = queryParams.userId
    const res: any = await getSalaryPage(params)
    if (res.code === 200) {
      salaryList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) { console.error('查询失败:', e) } finally { loading.value = false }
}

function resetQuery() {
  queryParams.salaryMonth = ''
  queryParams.userId = undefined
  queryParams.pageNum = 1
  handleQuery()
}

function handleAdd() {
  Object.assign(formData, { userId: 0, positionId: 0, realName: '', studentNo: '', salaryMonth: '', salaryPerHour: 0 })
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    const res: any = await generateSalary(formData)
    if (res.code === 200) {
      ElMessage.success('薪资生成成功')
      dialogVisible.value = false
      handleQuery()
    } else { ElMessage.error(res.msg) }
  } catch (e) { ElMessage.error('操作失败') } finally { submitLoading.value = false }
}

async function handlePay(row: any, status: number) {
  try {
    const res: any = await paySalary({ id: row.id, status })
    if (res.code === 200) {
      ElMessage.success(status === 2 ? '已发放' : '已确认')
      handleQuery()
    } else { ElMessage.error(res.msg) }
  } catch (e) { ElMessage.error('操作失败') }
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
