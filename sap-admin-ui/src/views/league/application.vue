<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
        <div><h1>入团申请</h1><p>管理入团申请流程</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <div class="search-bar">
        <el-input v-model="queryParams.realName" placeholder="姓名" clearable style="width:160px" @keyup.enter="handleQuery" />
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width:130px">
          <el-option label="待审核" :value="0" />
          <el-option label="通过" :value="1" />
          <el-option label="驳回" :value="2" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </div>

      <el-table :data="applicationList" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="real_name" label="姓名" width="100" />
        <el-table-column prop="student_no" label="学号" width="120" />
        <el-table-column prop="college" label="学院" width="130" />
        <el-table-column prop="major" label="专业" width="130" />
        <el-table-column prop="class_name" label="班级" width="100" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 0 ? 'warning' : row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 0 ? '待审核' : row.status === 1 ? '通过' : '驳回' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="申请时间" width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleDetail(row)">详情</el-button>
            <el-button v-if="row.status === 0" type="success" link size="small" @click="handleReview(row, 1)">通过</el-button>
            <el-button v-if="row.status === 0" type="danger" link size="small" @click="handleReview(row, 2)">驳回</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next" @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </div>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="申请详情" width="600px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="姓名">{{ detailData.real_name }}</el-descriptions-item>
        <el-descriptions-item label="学号">{{ detailData.student_no }}</el-descriptions-item>
        <el-descriptions-item label="学院">{{ detailData.college }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ detailData.major }}</el-descriptions-item>
        <el-descriptions-item label="班级">{{ detailData.class_name }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ detailData.phone }}</el-descriptions-item>
        <el-descriptions-item label="申请理由" :span="2">
          <p style="white-space:pre-wrap;margin:0">{{ detailData.apply_reason }}</p>
        </el-descriptions-item>
        <el-descriptions-item label="审核结果" v-if="detailData.status !== 0">
          <el-tag :type="detailData.status === 1 ? 'success' : 'danger'">
            {{ detailData.status === 1 ? '通过' : '驳回' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="审核人" v-if="detailData.reviewer_name">{{ detailData.reviewer_name }}</el-descriptions-item>
        <el-descriptions-item label="审核意见" :span="2" v-if="detailData.review_remark">{{ detailData.review_remark }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 审核对话框 -->
    <el-dialog v-model="reviewVisible" title="审核申请" width="450px">
      <el-form ref="reviewFormRef" :model="reviewForm" :rules="reviewRules" label-width="80px">
        <el-form-item label="审核结果">
          <el-tag :type="reviewForm.status === 1 ? 'success' : 'danger'">
            {{ reviewForm.status === 1 ? '通过' : '驳回' }}
          </el-tag>
        </el-form-item>
        <el-form-item label="审核意见" prop="reviewRemark">
          <el-input v-model="reviewForm.reviewRemark" type="textarea" :rows="4" placeholder="请输入审核意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reviewVisible = false">取消</el-button>
        <el-button type="primary" :loading="reviewLoading" @click="handleReviewSubmit">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getApplicationPage, getApplicationDetail, reviewApplication } from '@/api/league'

const loading = ref(false)
const total = ref(0)
const applicationList = ref<any[]>([])
const detailVisible = ref(false)
const reviewVisible = ref(false)
const reviewLoading = ref(false)
const detailData = ref<any>({})
const reviewFormRef = ref()
const currentReviewId = ref(0)

const queryParams = reactive({
  realName: '',
  status: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const reviewForm = reactive({
  status: 1,
  reviewRemark: ''
})

const reviewRules = {
  reviewRemark: [{ required: true, message: '请输入审核意见', trigger: 'blur' }]
}

async function handleQuery() {
  loading.value = true
  try {
    const res: any = await getApplicationPage(queryParams)
    if (res.code === 200) {
      applicationList.value = res.data.rows
      total.value = res.data.total
    }
  } catch (e) {
    console.error('查询失败:', e)
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.realName = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  handleQuery()
}

async function handleDetail(row: any) {
  const res: any = await getApplicationDetail(row.id)
  if (res.code === 200) {
    detailData.value = res.data
    detailVisible.value = true
  }
}

function handleReview(row: any, status: number) {
  currentReviewId.value = row.id
  reviewForm.status = status
  reviewForm.reviewRemark = ''
  reviewVisible.value = true
}

async function handleReviewSubmit() {
  const valid = await reviewFormRef.value.validate().catch(() => false)
  if (!valid) return
  reviewLoading.value = true
  try {
    const res: any = await reviewApplication({ id: currentReviewId.value, status: reviewForm.status, reviewRemark: reviewForm.reviewRemark })
    if (res.code === 200) {
      ElMessage.success('审核完成')
      reviewVisible.value = false
      handleQuery()
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) {
    ElMessage.error('审核失败')
  } finally {
    reviewLoading.value = false
  }
}

onMounted(() => handleQuery())
</script>

<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, var(--vermillion) 0%, #e04e44 100%); border-radius: var(--radius-xl); overflow: hidden; }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
.search-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.pagination-container { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
