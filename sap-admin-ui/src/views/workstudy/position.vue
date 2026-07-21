<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg></div>
        <div><h1>岗位管理</h1><p>管理勤工助学岗位</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.title" placeholder="岗位名称" clearable style="width:180px" @keyup.enter="handleQuery" />
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width:120px">
          <el-option label="招聘中" :value="1" />
          <el-option label="已关闭" :value="0" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
        <div style="flex:1" />
        <el-button type="primary" @click="handleAdd">新增岗位</el-button>
      </div>

      <el-table :data="positionList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="title" label="岗位名称" min-width="160" />
        <el-table-column prop="department" label="部门" width="120" />
        <el-table-column prop="position_type" label="岗位类型" width="100" />
        <el-table-column label="时薪" width="90" align="center">
          <template #default="{ row }">¥{{ row.salary_per_hour }}</template>
        </el-table-column>
        <el-table-column label="人数" width="80" align="center">
          <template #default="{ row }">{{ row.current_workers }}/{{ row.max_workers }}</template>
        </el-table-column>
        <el-table-column prop="work_location" label="工作地点" width="130" show-overflow-tooltip />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '招聘中' : '已关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="650px" @close="resetForm">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="110px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="岗位名称" prop="title">
              <el-input v-model="formData.title" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属部门" prop="department">
              <el-input v-model="formData.department" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="岗位类型" prop="positionType">
              <el-select v-model="formData.positionType" style="width:100%">
                <el-option label="管理类" value="管理类" />
                <el-option label="技术类" value="技术类" />
                <el-option label="文职类" value="文职类" />
                <el-option label="服务类" value="服务类" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="时薪(元)" prop="salaryPerHour">
              <el-input-number v-model="formData.salaryPerHour" :min="0" :step="0.5" :precision="2" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="招聘人数" prop="maxWorkers">
              <el-input-number v-model="formData.maxWorkers" :min="1" :max="100" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="周工时" prop="workHoursPerWeek">
              <el-input-number v-model="formData.workHoursPerWeek" :min="1" :max="40" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="工作地点" prop="workLocation">
              <el-input v-model="formData.workLocation" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系人" prop="contactPerson">
              <el-input v-model="formData.contactPerson" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话" prop="contactPhone">
              <el-input v-model="formData.contactPhone" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="isEdit">
            <el-form-item label="状态">
              <el-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="岗位描述" prop="description">
              <el-input v-model="formData.description" type="textarea" :rows="2" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="任职要求" prop="requirements">
              <el-input v-model="formData.requirements" type="textarea" :rows="2" />
            </el-form-item>
          </el-col>
        </el-row>
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPositionPage, createPosition, updatePosition, deletePosition } from '@/api/workstudy'

const loading = ref(false)
const total = ref(0)
const positionList = ref<any[]>([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const formRef = ref()

const queryParams = reactive({
  title: '',
  status: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const formData = reactive<any>({
  id: undefined, title: '', department: '', positionType: '',
  description: '', requirements: '', salaryPerHour: 15,
  maxWorkers: 1, workHoursPerWeek: 10, workLocation: '',
  contactPerson: '', contactPhone: '', status: 1
})

const formRules = {
  title: [{ required: true, message: '请输入岗位名称', trigger: 'blur' }],
  department: [{ required: true, message: '请输入所属部门', trigger: 'blur' }],
  salaryPerHour: [{ required: true, message: '请输入时薪', trigger: 'blur' }]
}

const dialogTitle = ref('新增岗位')

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getPositionPage(queryParams)
    if (res.code === 200) {
      positionList.value = res.data.rows
      total.value = res.data.total
    } else { ElMessage.error(res.msg) }
  } catch (e) { console.error('查询失败:', e) } finally { loading.value = false }
}

function resetQuery() {
  queryParams.title = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  handleQuery()
}

function handleAdd() {
  isEdit.value = false; dialogTitle.value = '新增岗位'
  Object.assign(formData, {
    id: undefined, title: '', department: '', positionType: '',
    description: '', requirements: '', salaryPerHour: 15,
    maxWorkers: 1, workHoursPerWeek: 10, workLocation: '',
    contactPerson: '', contactPhone: '', status: 1
  })
  dialogVisible.value = true
}

function handleEdit(row: any) {
  isEdit.value = true; dialogTitle.value = '编辑岗位'
  Object.assign(formData, {
    id: row.id, title: row.title, department: row.department,
    positionType: row.position_type || '', description: row.description || '',
    requirements: row.requirements || '', salaryPerHour: row.salary_per_hour,
    maxWorkers: row.max_workers, workHoursPerWeek: row.work_hours_per_week,
    workLocation: row.work_location || '',
    contactPerson: row.contact_person || '', contactPhone: row.contact_phone || '',
    status: row.status
  })
  dialogVisible.value = true
}

function resetForm() { if (formRef.value) formRef.value.resetFields() }

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    const res: any = isEdit.value ? await updatePosition(formData) : await createPosition(formData)
    if (res.code === 200) {
      ElMessage.success(isEdit.value ? '更新成功' : '新增成功')
      dialogVisible.value = false; handleQuery()
    } else { ElMessage.error(res.msg) }
  } catch (e) { ElMessage.error('操作失败') } finally { submitLoading.value = false }
}

async function handleDelete(row: any) {
  try {
    await ElMessageBox.confirm(`确认删除岗位「${row.title}」吗？`, '提示', { type: 'warning' })
    const res: any = await deletePosition(row.id)
    if (res.code === 200) { ElMessage.success('删除成功'); handleQuery() }
    else { ElMessage.error(res.msg) }
  } catch (e) { /* 取消 */ }
}

onMounted(() => handleQuery())
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, var(--gold-accent) 0%, #e8b84b 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.card-container { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
