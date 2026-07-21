<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
        <div><h1>角色管理</h1><p>管理系统角色和权限配置</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.roleName" placeholder="角色名称" clearable style="width:180px" @keyup.enter="handleQuery" />
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
        <div style="flex:1" />
        <el-button type="primary" @click="handleAdd">新增角色</el-button>
      </div>

      <el-table :data="roleList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="role_name" label="角色名称" width="150" />
        <el-table-column prop="role_key" label="权限字符" width="150" />
        <el-table-column prop="sort" label="排序" width="80" align="center" />
        <el-table-column prop="remark" label="备注" min-width="200" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="handleQuery"
          @current-change="handleQuery"
        />
      </div>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px" @close="resetForm">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="90px">
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="formData.roleName" />
        </el-form-item>
        <el-form-item label="权限字符" prop="roleKey">
          <el-input v-model="formData.roleKey" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="formData.sort" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="状态" v-if="isEdit">
          <el-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="formData.remark" type="textarea" :rows="3" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { formatDateTime } from '@/utils/date'

const loading = ref(false)
const total = ref(0)
const roleList = ref<any[]>([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const formRef = ref()

const queryParams = reactive({
  roleName: '',
  pageNum: 1,
  pageSize: 10
})

const formData = reactive<any>({
  id: undefined,
  roleName: '',
  roleKey: '',
  sort: 0,
  status: 1,
  remark: ''
})

const formRules = {
  roleName: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  roleKey: [{ required: true, message: '请输入权限字符', trigger: 'blur' }]
}

const dialogTitle = ref('新增角色')

async function getRolePage(params: any) {
  return request({ url: '/user/role/page', method: 'get', params })
}

async function addRole(data: any) {
  return request({ url: '/user/role', method: 'post', data })
}

async function updateRole(data: any) {
  return request({ url: '/user/role', method: 'put', data })
}

async function deleteRole(id: number) {
  return request({ url: `/user/role/${id}`, method: 'delete' })
}

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getRolePage(queryParams)
    if (res.code === 200) {
      roleList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.roleName = ''
  queryParams.pageNum = 1
  handleQuery()
}

function handleAdd() {
  isEdit.value = false
  dialogTitle.value = '新增角色'
  Object.assign(formData, { id: undefined, roleName: '', roleKey: '', sort: 0, status: 1, remark: '' })
  dialogVisible.value = true
}

function handleEdit(row: any) {
  isEdit.value = true
  dialogTitle.value = '编辑角色'
  Object.assign(formData, {
    id: row.id, roleName: row.role_name, roleKey: row.role_key,
    sort: row.sort ?? 0, status: row.status, remark: row.remark || ''
  })
  dialogVisible.value = true
}

function resetForm() {
  if (formRef.value) formRef.value.resetFields()
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    const res: any = isEdit.value ? await updateRole(formData) : await addRole(formData)
    if (res.code === 200) {
      ElMessage.success(isEdit.value ? '更新成功' : '新增成功')
      dialogVisible.value = false
      handleQuery()
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) {
    ElMessage.error('操作失败')
  } finally {
    submitLoading.value = false
  }
}

async function handleDelete(row: any) {
  try {
    await ElMessageBox.confirm(`确认删除角色「${row.role_name}」吗？`, '提示', { type: 'warning' })
    const res: any = await deleteRole(row.id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      handleQuery()
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) { /* 取消 */ }
}

onMounted(() => handleQuery())
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, var(--jade-deep) 0%, var(--jade-medium) 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
