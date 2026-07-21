<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></div>
        <div><h1>电子档案</h1><p>管理入团电子档案</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div v-if="isAdmin" style="margin-bottom:16px">
        <el-button type="primary" @click="handleAdd">生成档案</el-button>
      </div>
      <el-table :data="archiveList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="archive_no" label="档案编号" width="150" />
        <el-table-column prop="archive_name" label="档案名称" min-width="200" />
        <el-table-column prop="user_id" label="用户ID" width="80" />
        <el-table-column prop="file_type" label="文件类型" width="100" />
        <el-table-column label="生成时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.generate_time) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '已生成' : '待生成' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small">下载</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>

    <el-dialog v-model="dialogVisible" title="生成电子档案" width="450px">
      <el-form :model="formData" :rules="formRules" label-width="100px" ref="formRef">
        <el-form-item label="申请ID" prop="applicationId">
          <el-input-number v-model="formData.applicationId" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="用户ID" prop="userId">
          <el-input-number v-model="formData.userId" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="档案名称" prop="archiveName">
          <el-input v-model="formData.archiveName" placeholder="如：张三入团档案" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确认生成</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getArchivePage, createArchive } from '@/api/league'
import { usePermission } from '@/utils/permission'
import { formatDateTime } from '@/utils/date'

const { isAdmin } = usePermission()

const loading = ref(false)
const total = ref(0)
const archiveList = ref<any[]>([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10
})

const formData = reactive({
  applicationId: 0,
  userId: 0,
  archiveName: ''
})

const formRules = {
  applicationId: [{ required: true, message: '请输入申请ID', trigger: 'blur' }],
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  archiveName: [{ required: true, message: '请输入档案名称', trigger: 'blur' }]
}

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getArchivePage(queryParams)
    if (res.code === 200) {
      archiveList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function handleAdd() {
  Object.assign(formData, { applicationId: 0, userId: 0, archiveName: '' })
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    const res: any = await createArchive(formData)
    if (res.code === 200) {
      ElMessage.success('档案生成成功')
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

onMounted(() => handleQuery())
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
