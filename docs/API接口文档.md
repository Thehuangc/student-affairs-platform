# 学生综合事务中台 - API接口文档

## 基础信息

- **基础路径**: `/api`
- **认证方式**: Bearer Token（JWT）
- **请求格式**: application/json
- **响应格式**: JSON

### 通用响应结构
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {}
}
```

### 错误码说明
| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权/Token过期 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 1. 认证模块 (/api/auth)

### 1.1 用户登录
**POST** `/api/auth/login`

**请求参数**:
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 86400,
    "userId": 1,
    "username": "admin",
    "nickname": "管理员",
    "avatar": "",
    "roles": ["admin"],
    "permissions": ["*:*:*"]
  }
}
```

### 1.2 用户注册
**POST** `/api/auth/register`

**请求参数**:
```json
{
  "username": "newuser",
  "password": "123456",
  "realName": "张三",
  "studentNo": "2024001"
}
```

### 1.3 刷新Token
**POST** `/api/auth/refresh`

**请求头**: `Authorization: Bearer {token}`

### 1.4 用户登出
**POST** `/api/auth/logout`

---

## 2. 用户模块 (/api/user)

### 2.1 获取用户信息
**GET** `/api/user/info`

**响应示例**:
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "nickname": "管理员",
    "real_name": "管理员",
    "email": "admin@sap.com",
    "roles": ["admin"]
  }
}
```

### 2.2 用户列表
**GET** `/api/user/list`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码，默认1 |
| pageSize | number | 否 | 每页数量，默认10 |
| username | string | 否 | 用户名模糊搜索 |
| status | number | 否 | 状态筛选 |

### 2.3 新增用户
**POST** `/api/user`

**请求参数**:
```json
{
  "username": "newuser",
  "password": "123456",
  "nickname": "新用户",
  "realName": "李四",
  "studentNo": "2024002",
  "email": "lisi@example.com",
  "phone": "13800138000",
  "college": "计算机学院",
  "major": "软件工程",
  "className": "软件2401",
  "roles": "student"
}
```

### 2.4 更新用户
**PUT** `/api/user`

**请求参数**:
```json
{
  "id": 2,
  "nickname": "张三",
  "realName": "张三",
  "status": 1
}
```

### 2.5 删除用户
**DELETE** `/api/user/{id}`

### 2.6 重置密码
**PUT** `/api/user/resetPwd`

**请求参数**:
```json
{
  "id": 2,
  "password": "123456"
}
```

---

## 3. 角色模块 (/api/user/role)

### 3.1 角色列表
**GET** `/api/user/role/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| roleName | string | 否 | 角色名称模糊搜索 |

### 3.2 新增角色
**POST** `/api/user/role`

**请求参数**:
```json
{
  "roleName": "普通用户",
  "roleKey": "user",
  "sort": 2,
  "remark": "普通用户角色"
}
```

### 3.3 更新角色
**PUT** `/api/user/role`

### 3.4 删除角色
**DELETE** `/api/user/role/{id}`

---

## 4. 统计模块 (/api/statistics)

### 4.1 获取统计数据
**GET** `/api/statistics`

**响应示例**:
```json
{
  "code": 200,
  "data": {
    "totalUsers": 3,
    "totalActivities": 3,
    "totalVolunteerHours": "48.5",
    "totalPositions": 3
  }
}
```

---

## 5. 志愿活动模块 (/api/volunteer/activity)

### 5.1 活动列表
**GET** `/api/volunteer/activity/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| title | string | 否 | 标题模糊搜索 |
| status | number | 否 | 状态筛选（0未开始，1进行中，2已结束，3已取消） |

### 5.2 活动详情
**GET** `/api/volunteer/activity/{id}`

### 5.3 创建活动
**POST** `/api/volunteer/activity`

**请求参数**:
```json
{
  "title": "校园清洁志愿活动",
  "content": "组织志愿者清理校园环境",
  "activityType": "环保公益",
  "location": "校园主干道",
  "startTime": "2026-07-20 09:00:00",
  "endTime": "2026-07-20 12:00:00",
  "maxParticipants": 50,
  "organizer": "校团委",
  "contactPerson": "王老师",
  "contactPhone": "13800000001"
}
```

### 5.4 更新活动
**PUT** `/api/volunteer/activity`

### 5.5 取消活动
**DELETE** `/api/volunteer/activity/{id}`

### 5.6 活动报名
**POST** `/api/volunteer/activity/{id}/enroll`

**查询参数**: `userId` (可选，默认当前用户)

### 5.7 取消报名
**DELETE** `/api/volunteer/activity/{id}/enroll`

### 5.8 签到
**POST** `/api/volunteer/activity/check-in`

**请求参数**:
```json
{
  "activityId": 1,
  "userId": 2,
  "realName": "张三",
  "checkInCode": "abc123",
  "location": "校园主干道",
  "lat": 39.9042,
  "lng": 116.4074
}
```

### 5.9 签退
**POST** `/api/volunteer/activity/{id}/check-out`

**查询参数**: `userId` (可选)

### 5.10 获取用户参与的活动
**GET** `/api/volunteer/activity/user/{userId}`

### 5.11 获取活动报名列表
**GET** `/api/volunteer/activity/{id}/enrolls`

### 5.12 获取活动签到列表
**GET** `/api/volunteer/activity/{id}/checkins`

---

## 6. 志愿者模块 (/api/volunteer)

### 6.1 志愿者列表
**GET** `/api/volunteer/list`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| realName | string | 否 | 姓名模糊搜索 |
| status | number | 否 | 状态筛选 |

### 6.2 签到记录列表
**GET** `/api/volunteer/checkin/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| activityId | number | 否 | 活动ID |
| userId | number | 否 | 用户ID |

### 6.3 时长记录列表
**GET** `/api/volunteer/hours/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| userId | number | 否 | 用户ID |
| statMonth | string | 否 | 统计月份（如2026-07） |

---

## 7. 团员发展模块 (/api/league)

### 7.1 入团申请列表
**GET** `/api/league/application/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| realName | string | 否 | 姓名模糊搜索 |
| status | number | 否 | 状态（0待审核，1通过，2驳回） |

### 7.2 申请详情
**GET** `/api/league/application/{id}`

### 7.3 提交入团申请
**POST** `/api/league/application`

**请求参数**:
```json
{
  "realName": "张三",
  "studentNo": "2024001",
  "college": "计算机学院",
  "major": "软件工程",
  "className": "软件2401",
  "phone": "13800138001",
  "applyReason": "我志愿加入中国共产主义青年团..."
}
```

### 7.4 审核入团申请
**PUT** `/api/league/application/review`

**请求参数**:
```json
{
  "id": 1,
  "status": 1,
  "reviewRemark": "审核通过"
}
```

### 7.5 政审备案列表
**GET** `/api/league/review/page`

### 7.6 新增政审备案
**POST** `/api/league/review`

**请求参数**:
```json
{
  "applicationId": 1,
  "userId": 2,
  "reviewType": "政治面貌审查",
  "reviewContent": "该生政治立场坚定..."
}
```

### 7.7 审核政审
**PUT** `/api/league/review/audit`

**请求参数**:
```json
{
  "id": 1,
  "reviewResult": 1
}
```

### 7.8 电子档案列表
**GET** `/api/league/archive/page`

### 7.9 生成电子档案
**POST** `/api/league/archive`

**请求参数**:
```json
{
  "applicationId": 1,
  "userId": 2,
  "archiveName": "张三入团档案"
}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "生成成功",
  "data": {
    "archiveNo": "ARCH1721539200000"
  }
}
```

---

## 8. 勤工助学模块 (/api/workstudy)

### 8.1 岗位列表
**GET** `/api/workstudy/position/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| title | string | 否 | 岗位名称模糊搜索 |
| status | number | 否 | 状态（0关闭，1招聘中） |

### 8.2 岗位详情
**GET** `/api/workstudy/position/{id}`

### 8.3 新增岗位
**POST** `/api/workstudy/position`

**请求参数**:
```json
{
  "title": "图书馆管理员",
  "department": "图书馆",
  "positionType": "管理类",
  "description": "负责图书整理、借还书登记等工作",
  "requirements": "工作认真负责，有责任心",
  "salaryPerHour": 15.00,
  "maxWorkers": 5,
  "workHoursPerWeek": 10,
  "workLocation": "图书馆一楼",
  "contactPerson": "王老师",
  "contactPhone": "13800000001"
}
```

### 8.4 更新岗位
**PUT** `/api/workstudy/position`

### 8.5 删除岗位
**DELETE** `/api/workstudy/position/{id}`

### 8.6 应聘申请列表
**GET** `/api/workstudy/application/page`

### 8.7 提交应聘申请
**POST** `/api/workstudy/application`

**请求参数**:
```json
{
  "positionId": 1,
  "realName": "张三",
  "studentNo": "2024001",
  "college": "计算机学院",
  "major": "软件工程",
  "className": "软件2401",
  "phone": "13800138001",
  "applyReason": "我对图书馆工作很感兴趣...",
  "relatedExperience": "曾担任班级图书委员",
  "availableHours": 10
}
```

### 8.8 审核应聘申请
**PUT** `/api/workstudy/application/review`

### 8.9 考勤记录列表
**GET** `/api/workstudy/attendance/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| userId | number | 否 | 用户ID |
| positionId | number | 否 | 岗位ID |
| checkDate | string | 否 | 日期（YYYY-MM-DD） |

### 8.10 新增考勤
**POST** `/api/workstudy/attendance`

**请求参数**:
```json
{
  "userId": 2,
  "positionId": 1,
  "realName": "张三",
  "checkDate": "2026-07-21",
  "checkInTime": "2026-07-21 08:00:00",
  "checkOutTime": "2026-07-21 12:00:00",
  "remark": "正常出勤"
}
```

### 8.11 审核考勤
**PUT** `/api/workstudy/attendance/audit`

**请求参数**:
```json
{
  "id": 1,
  "status": 1
}
```

### 8.12 薪资记录列表
**GET** `/api/workstudy/salary/page`

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 页码 |
| pageSize | number | 否 | 每页数量 |
| userId | number | 否 | 用户ID |
| salaryMonth | string | 否 | 月份（如2026-07） |

### 8.13 生成薪资
**POST** `/api/workstudy/salary`

**请求参数**:
```json
{
  "userId": 2,
  "positionId": 1,
  "realName": "张三",
  "studentNo": "2024001",
  "salaryMonth": "2026-07",
  "salaryPerHour": 15.00
}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "生成成功",
  "data": {
    "totalHours": 40,
    "baseSalary": 600.00
  }
}
```

### 8.14 确认/发放薪资
**PUT** `/api/workstudy/salary/pay`

**请求参数**:
```json
{
  "id": 1,
  "status": 2
}
```

**状态说明**: 1=确认，2=发放

---

## 9. 待办事项

### 9.1 获取待办列表
**GET** `/api/todos`

**响应示例**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "tag": "审核",
      "type": "warning",
      "title": "张三的入团申请待审核",
      "time": "10分钟前"
    }
  ]
}
```

---

## 10. 健康检查

### 10.1 服务健康检查
**GET** `/api/health`

**响应示例**:
```json
{
  "status": "UP",
  "timestamp": "2026-07-21T07:32:04.387Z"
}
```

---

## 附录：前端API文件对应表

| 前端文件 | 后端模块 |
|----------|----------|
| `api/auth.ts` | 认证模块 |
| `api/user.ts` | 用户模块 |
| `api/dashboard.ts` | 统计模块 |
| `api/volunteer.ts` | 志愿活动/志愿者模块 |
| `api/league.ts` | 团员发展模块 |
| `api/workstudy.ts` | 勤工助学模块 |
