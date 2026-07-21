import request from '@/utils/request'

/**
 * 分页查询志愿活动
 */
export function getActivityPage(params: {
  title?: string
  activityType?: string
  status?: number
  pageNum?: number
  pageSize?: number
}) {
  return request({
    url: '/volunteer/activity/page',
    method: 'get',
    params
  })
}

/**
 * 获取活动详情
 */
export function getActivityDetail(id: number) {
  return request({
    url: `/volunteer/activity/${id}`,
    method: 'get'
  })
}

/**
 * 创建活动
 */
export function createActivity(data: {
  title: string
  content?: string
  activityType?: string
  location?: string
  startTime: string
  endTime: string
  maxParticipants: number
  organizer?: string
  contactPerson?: string
  contactPhone?: string
}) {
  return request({
    url: '/volunteer/activity',
    method: 'post',
    data
  })
}

/**
 * 更新活动
 */
export function updateActivity(data: {
  id: number
  title?: string
  content?: string
  location?: string
  startTime?: string
  endTime?: string
  maxParticipants?: number
}) {
  return request({
    url: '/volunteer/activity',
    method: 'put',
    data
  })
}

/**
 * 取消活动
 */
export function cancelActivity(id: number) {
  return request({
    url: `/volunteer/activity/${id}`,
    method: 'delete'
  })
}

/**
 * 报名活动
 */
export function enrollActivity(activityId: number, userId: number) {
  return request({
    url: `/volunteer/activity/${activityId}/enroll`,
    method: 'post',
    params: { userId }
  })
}

/**
 * 取消报名
 */
export function cancelEnroll(activityId: number, userId: number) {
  return request({
    url: `/volunteer/activity/${activityId}/enroll`,
    method: 'delete',
    params: { userId }
  })
}

/**
 * 签到
 */
export function checkIn(data: {
  activityId: number
  userId: number
  realName?: string
  checkInCode: string
  location?: string
  lat?: number
  lng?: number
}) {
  return request({
    url: '/volunteer/activity/check-in',
    method: 'post',
    data
  })
}

/**
 * 签退
 */
export function checkOut(activityId: number, userId: number) {
  return request({
    url: `/volunteer/activity/${activityId}/check-out`,
    method: 'post',
    params: { userId }
  })
}

/**
 * 获取用户参与的活动
 */
export function getUserActivities(userId: number) {
  return request({
    url: `/volunteer/activity/user/${userId}`,
    method: 'get'
  })
}

/**
 * 获取活动报名列表
 */
export function getActivityEnrolls(activityId: number) {
  return request({
    url: `/volunteer/activity/${activityId}/enrolls`,
    method: 'get'
  })
}

/**
 * 获取活动签到列表
 */
export function getActivityCheckins(activityId: number) {
  return request({
    url: `/volunteer/activity/${activityId}/checkins`,
    method: 'get'
  })
}

/**
 * 分页查询志愿者列表
 */
export function getVolunteerList(params: {
  pageNum?: number
  pageSize?: number
  realName?: string
  status?: number
}) {
  return request({
    url: '/volunteer/list',
    method: 'get',
    params
  })
}

/**
 * 分页查询时长记录
 */
export function getHoursPage(params: {
  pageNum?: number
  pageSize?: number
  userId?: number
  statMonth?: string
}) {
  return request({
    url: '/volunteer/hours/page',
    method: 'get',
    params
  })
}
