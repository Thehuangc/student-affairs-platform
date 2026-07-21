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
        <el-input v-model="queryParams.username" placeholder="用户名" clearable style="width:180px" @keyup.enter="handleQuery" />
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width:120px">
          <el-option label="正常" :value="1" />
          <el-option label="禁用" :value="0" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
        <div style="flex:1" />
        <el-button type="primary" @click="handleAdd">新增用户</el-button>
      </div>

      <el-table :data="userList" v-loading="loading" border stripe style="width:100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="username" label="用户名" width="110" />
        <el-table-column prop="real_name" label="真实姓名" width="110" />
        <el-table-column prop="student_no" label="学号" width="120" />
        <el-table-column prop="email" label="邮箱" min-width="160" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column prop="college" label="学院" width="120" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="warning" link size="small" @click="handleResetPwd(row)">重置密码</el-button>
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

    <!-- 新增/编辑用户对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="90px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="formData.username" :disabled="isEdit" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="密码" prop="password" v-if="!isEdit">
              <el-input v-model="formData.password" type="password" show-password />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="formData.nickname" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="formData.realName" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学号" prop="studentNo">
              <el-input v-model="formData.studentNo" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="formData.email" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="formData.phone" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学院" prop="college">
              <el-input v-model="formData.college" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="专业" prop="major">
              <el-input v-model="formData.major" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="班级" prop="className">
              <el-input v-model="formData.className" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="角色" prop="roles">
              <el-select v-model="formData.roles" style="width:100%">
                <el-option label="学生" value="student" />
                <el-option label="教师" value="teacher" />
                <el-option label="管理员" value="admin" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="isEdit">
            <el-form-item label="状态">
              <el-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
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
import { getUserList, addUser, updateUser, deleteUser, resetUserPwd } from '@/api/user'

const loading = ref(false)
const total = ref(0)
const userList = ref<any[]>([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const formRef = ref()

const queryParams = reactive({
  username: '',
  status: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const formData = reactive<any>({
  id: undefined,
  username: '',
  password: '',
  nickname: '',
  realName: '',
  studentNo: '',
  email: '',
  phone: '',
  college: '',
  major: '',
  className: '',
  roles: 'student',
  status: 1
})

const formRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const dialogTitle = ref('新增用户')

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getUserList(queryParams)
    if (res.code === 200) {
      userList.value = res.data.rows
      total.value = res.data.total
    } else {
      ElMessage.error(res.msg)
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

function handleAdd() {
  isEdit.value = false
  dialogTitle.value = '新增用户'
  Object.assign(formData, {
    id: undefined, username: '', password: '', nickname: '', realName: '',
    studentNo: '', email: '', phone: '', college: '', major: '',
    className: '', roles: 'student', status: 1
  })
  dialogVisible.value = true
}

function handleEdit(row: any) {
  isEdit.value = true
  dialogTitle.value = '编辑用户'
  Object.assign(formData, {
    id: row.id,
    username: row.username,
    password: '',
    nickname: row.nickname || '',
    realName: row.real_name || '',
    studentNo: row.student_no || '',
    email: row.email || '',
    phone: row.phone || '',
    college: row.college || '',
    major: row.major || '',
    className: row.class_name || '',
    roles: row.roles || 'student',
    status: row.status
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
    let res: any
    if (isEdit.value) {
      res = await updateUser(formData)
    } else {
      res = await addUser(formData)
    }
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
    await ElMessageBox.confirm(`确认删除用户「${row.username}」吗？`, '提示', { type: 'warning' })
    const res: any = await deleteUser(row.id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      handleQuery()
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) {
    // 取消
  }
}

async function handleResetPwd(row: any) {
  try {
    await ElMessageBox.confirm(`确认重置用户「${row.username}」的密码为 123456 吗？`, '提示', { type: 'warning' })
    const res: any = await resetUserPwd(row.id)
    if (res.code === 200) {
      ElMessage.success('密码已重置为 123456')
    } else {
      ElMessage.error(res.msg)
    }
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
  width: 52px; height: 52px;
  background: rgba(255,255,255,0.15);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
}
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
