import request from '@/utils/request'

/**
 * 分页查询岗位
 */
export function getPositionPage(params: {
  pageNum?: number
  pageSize?: number
  title?: string
  status?: number
}) {
  return request({
    url: '/workstudy/position/page',
    method: 'get',
    params
  })
}

/**
 * 获取岗位详情
 */
export function getPositionDetail(id: number) {
  return request({
    url: `/workstudy/position/${id}`,
    method: 'get'
  })
}

/**
 * 新增岗位
 */
export function createPosition(data: {
  title: string
  department: string
  positionType?: string
  description?: string
  requirements?: string
  salaryPerHour: number
  maxWorkers?: number
  workHoursPerWeek?: number
  workLocation?: string
  contactPerson?: string
  contactPhone?: string
}) {
  return request({
    url: '/workstudy/position',
    method: 'post',
    data
  })
}

/**
 * 更新岗位
 */
export function updatePosition(data: {
  id: number
  title?: string
  department?: string
  positionType?: string
  description?: string
  requirements?: string
  salaryPerHour?: number
  maxWorkers?: number
  workHoursPerWeek?: number
  workLocation?: string
  contactPerson?: string
  contactPhone?: string
  status?: number
}) {
  return request({
    url: '/workstudy/position',
    method: 'put',
    data
  })
}

/**
 * 删除岗位
 */
export function deletePosition(id: number) {
  return request({
    url: `/workstudy/position/${id}`,
    method: 'delete'
  })
}

/**
 * 分页查询应聘申请
 */
export function getWsApplicationPage(params: {
  pageNum?: number
  pageSize?: number
  positionId?: number
  status?: number
}) {
  return request({
    url: '/workstudy/application/page',
    method: 'get',
    params
  })
}

/**
 * 提交应聘申请
 */
export function submitWsApplication(data: {
  positionId: number
  realName: string
  studentNo: string
  college?: string
  major?: string
  className?: string
  phone?: string
  applyReason?: string
  relatedExperience?: string
  availableHours?: number
}) {
  return request({
    url: '/workstudy/application',
    method: 'post',
    data
  })
}

/**
 * 审核应聘申请
 */
export function reviewWsApplication(data: {
  id: number
  status: number
  reviewRemark?: string
}) {
  return request({
    url: '/workstudy/application/review',
    method: 'put',
    data
  })
}

/**
 * 分页查询考勤记录
 */
export function getAttendancePage(params: {
  pageNum?: number
  pageSize?: number
  userId?: number
  positionId?: number
  checkDate?: string
}) {
  return request({
    url: '/workstudy/attendance/page',
    method: 'get',
    params
  })
}

/**
 * 新增考勤记录
 */
export function createAttendance(data: {
  userId: number
  positionId: number
  realName?: string
  checkDate: string
  checkInTime?: string
  checkOutTime?: string
  remark?: string
}) {
  return request({
    url: '/workstudy/attendance',
    method: 'post',
    data
  })
}

/**
 * 审核考勤
 */
export function auditAttendance(data: {
  id: number
  status: number
}) {
  return request({
    url: '/workstudy/attendance/audit',
    method: 'put',
    data
  })
}

/**
 * 分页查询薪资
 */
export function getSalaryPage(params: {
  pageNum?: number
  pageSize?: number
  userId?: number
  salaryMonth?: string
}) {
  return request({
    url: '/workstudy/salary/page',
    method: 'get',
    params
  })
}

/**
 * 生成薪资
 */
export function generateSalary(data: {
  userId: number
  positionId: number
  realName?: string
  studentNo?: string
  salaryMonth: string
  salaryPerHour: number
}) {
  return request({
    url: '/workstudy/salary',
    method: 'post',
    data
  })
}

/**
 * 确认/发放薪资
 */
export function paySalary(data: {
  id: number
  status: number
}) {
  return request({
    url: '/workstudy/salary/pay',
    method: 'put',
    data
  })
}
