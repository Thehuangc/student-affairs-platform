import request from '@/utils/request'

/**
 * 获取统计数据
 */
export function getStatistics() {
  return request({
    url: '/statistics',
    method: 'get'
  })
}
