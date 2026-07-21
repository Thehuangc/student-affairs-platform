import request from '@/utils/request'

/**
 * 分页查询入团申请
 */
export function getApplicationPage(params: {
  pageNum?: number
  pageSize?: number
  realName?: string
  status?: number
}) {
  return request({
    url: '/league/application/page',
    method: 'get',
    params
  })
}

/**
 * 获取入团申请详情
 */
export function getApplicationDetail(id: number) {
  return request({
    url: `/league/application/${id}`,
    method: 'get'
  })
}

/**
 * 提交入团申请
 */
export function submitApplication(data: {
  realName: string
  studentNo: string
  college?: string
  major?: string
  className?: string
  phone?: string
  applyReason: string
}) {
  return request({
    url: '/league/application',
    method: 'post',
    data
  })
}

/**
 * 审核入团申请
 */
export function reviewApplication(data: {
  id: number
  status: number
  reviewRemark?: string
}) {
  return request({
    url: '/league/application/review',
    method: 'put',
    data
  })
}

/**
 * 分页查询政审备案
 */
export function getReviewPage(params: {
  pageNum?: number
  pageSize?: number
  userId?: number
}) {
  return request({
    url: '/league/review/page',
    method: 'get',
    params
  })
}

/**
 * 新增政审备案
 */
export function addReview(data: {
  applicationId: number
  userId: number
  reviewType: string
  reviewContent?: string
  attachment?: string
}) {
  return request({
    url: '/league/review',
    method: 'post',
    data
  })
}

/**
 * 审核政审
 */
export function auditReview(data: {
  id: number
  reviewResult: number
}) {
  return request({
    url: '/league/review/audit',
    method: 'put',
    data
  })
}

/**
 * 分页查询电子档案
 */
export function getArchivePage(params: {
  pageNum?: number
  pageSize?: number
  userId?: number
}) {
  return request({
    url: '/league/archive/page',
    method: 'get',
    params
  })
}

/**
 * 生成电子档案
 */
export function createArchive(data: {
  applicationId: number
  userId: number
  archiveName: string
}) {
  return request({
    url: '/league/archive',
    method: 'post',
    data
  })
}
