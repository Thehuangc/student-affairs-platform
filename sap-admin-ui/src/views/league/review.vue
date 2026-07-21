<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg></div>
        <div><h1>政审备案</h1><p>管理入团申请的政审材料备案</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div v-if="isAdmin" style="margin-bottom:16px">
        <el-button type="primary" @click="handleAdd">新增备案</el-button>
      </div>
      <el-table :data="reviewList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="application_id" label="申请ID" width="80" />
        <el-table-column prop="user_id" label="用户ID" width="80" />
        <el-table-column prop="review_type" label="审查类型" width="120" />
        <el-table-column prop="review_content" label="审查内容" min-width="200" show-overflow-tooltip />
        <el-table-column label="审查结果" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.review_result === 0 ? 'warning' : row.review_result === 1 ? 'success' : 'danger'" size="small">
              {{ row.review_result === 0 ? '待审' : row.review_result === 1 ? '通过' : '不通过' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reviewer_name" label="审核人" width="100" />
        <el-table-column label="审核时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.review_time) }}</template>
        </el-table-column>
        <el-table-column v-if="isAdmin" label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.review_result === 0" type="success" link size="small" @click="handleAudit(row, 1)">通过</el-button>
            <el-button v-if="row.review_result === 0" type="danger" link size="small" @click="handleAudit(row, 2)">不通过</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>

    <el-dialog v-model="dialogVisible" title="新增政审备案" width="500px">
      <el-form :model="formData" :rules="formRules" label-width="100px" ref="formRef">
        <el-form-item label="申请ID" prop="applicationId">
          <el-input-number v-model="formData.applicationId" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="用户ID" prop="userId">
          <el-input-number v-model="formData.userId" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="审查类型" prop="reviewType">
          <el-select v-model="formData.reviewType" style="width:100%">
            <el-option label="政治面貌审查" value="政治面貌审查" />
            <el-option label="思想品德审查" value="思想品德审查" />
            <el-option label="在校表现审查" value="在校表现审查" />
          </el-select>
        </el-form-item>
        <el-form-item label="审查内容" prop="reviewContent">
          <el-input v-model="formData.reviewContent" type="textarea" :rows="3" />
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
import { getReviewPage, addReview, auditReview } from '@/api/league'
import { usePermission } from '@/utils/permission'
import { formatDateTime } from '@/utils/date'

const { isAdmin } = usePermission()

const loading = ref(false)
const total = ref(0)
const reviewList = ref<any[]>([])
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
  reviewType: '',
  reviewContent: ''
})

const formRules = {
  applicationId: [{ required: true, message: '请输入申请ID', trigger: 'blur' }],
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  reviewType: [{ required: true, message: '请选择审查类型', trigger: 'change' }]
}

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getReviewPage(queryParams)
    if (res.code === 200) {
      reviewList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function handleAdd() {
  Object.assign(formData, { applicationId: 0, userId: 0, reviewType: '', reviewContent: '' })
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    const res: any = await addReview(formData)
    if (res.code === 200) {
      ElMessage.success('备案成功')
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

async function handleAudit(row: any, reviewResult: number) {
  try {
    const res: any = await auditReview({ id: row.id, reviewResult })
    if (res.code === 200) {
      ElMessage.success('审核完成')
      handleQuery()
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) {
    ElMessage.error('审核失败')
  }
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
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
