const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 8080;
const JWT_SECRET = 'sap-student-affairs-platform-jwt-secret-key-2024';
const JWT_EXPIRES_IN = '24h';

app.use(cors());
app.use(express.json());

// MySQL连接池
const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: '',
  database: 'sap_service',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// 认证中间件
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ code: 401, msg: '未授权', data: null });
  }
  const token = authHeader.substring(7);
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (error) {
    return res.status(401).json({ code: 401, msg: '令牌无效或已过期', data: null });
  }
};

// 辅助：执行SQL
async function query(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

// ==================== 认证 ====================

app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.json({ code: 400, msg: '用户名和密码不能为空', data: null });
    }

    const users = await query('SELECT * FROM users WHERE username = ? AND status = 1', [username]);
    if (users.length === 0) {
      return res.json({ code: 400, msg: '用户不存在或已被禁用', data: null });
    }

    const user = users[0];
    if (!bcrypt.compareSync(password, user.password)) {
      return res.json({ code: 400, msg: '密码错误', data: null });
    }

    const token = jwt.sign(
      { userId: user.id, username: user.username, nickname: user.nickname },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    res.json({
      code: 200, msg: '登录成功',
      data: {
        token, expiresIn: 86400,
        userId: user.id, username: user.username,
        nickname: user.nickname, avatar: user.avatar || '',
        roles: (user.roles || 'student').split(','),
        permissions: ['*:*:*']
      }
    });
  } catch (e) {
    console.error('登录错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, password, realName, studentNo } = req.body;
    if (!username || !password) {
      return res.json({ code: 400, msg: '用户名和密码不能为空', data: null });
    }

    const exists = await query('SELECT id FROM users WHERE username = ?', [username]);
    if (exists.length > 0) {
      return res.json({ code: 400, msg: '用户名已存在', data: null });
    }

    const hash = bcrypt.hashSync(password, 10);
    await query(
      'INSERT INTO users (username, password, nickname, real_name, student_no, roles) VALUES (?, ?, ?, ?, ?, ?)',
      [username, hash, realName || username, realName || '', studentNo || '', 'student']
    );

    res.json({ code: 200, msg: '注册成功', data: null });
  } catch (e) {
    console.error('注册错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.post('/api/auth/logout', (req, res) => {
  res.json({ code: 200, msg: '退出成功', data: null });
});

app.post('/api/auth/refresh', authMiddleware, async (req, res) => {
  try {
    const users = await query('SELECT * FROM users WHERE id = ?', [req.user.userId]);
    if (users.length === 0) {
      return res.json({ code: 401, msg: '用户不存在', data: null });
    }
    const user = users[0];
    const token = jwt.sign(
      { userId: user.id, username: user.username, nickname: user.nickname },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    res.json({
      code: 200, msg: '刷新成功',
      data: {
        token, expiresIn: 86400,
        userId: user.id, username: user.username,
        nickname: user.nickname, avatar: user.avatar || '',
        roles: (user.roles || 'student').split(','),
        permissions: ['*:*:*']
      }
    });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 统计 ====================

app.get('/api/statistics', authMiddleware, async (req, res) => {
  try {
    const totalUsers = (await query('SELECT COUNT(*) as c FROM users WHERE status=1'))[0].c;
    const totalActivities = (await query('SELECT COUNT(*) as c FROM activities'))[0].c;
    const totalVolunteerHours = (await query('SELECT IFNULL(SUM(total_hours),0) as c FROM volunteers'))[0].c;
    const totalPositions = (await query('SELECT COUNT(*) as c FROM ws_positions WHERE status=1'))[0].c;
    const stats = {
      totalUsers,
      totalActivities,
      totalVolunteerHours: Number(totalVolunteerHours).toFixed(1),
      totalPositions
    };
    res.json({ code: 200, msg: '操作成功', data: stats });
  } catch (e) {
    console.error('统计错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 用户 ====================

app.get('/api/user/info', authMiddleware, async (req, res) => {
  try {
    const users = await query('SELECT * FROM users WHERE id = ?', [req.user.userId]);
    if (users.length === 0) return res.json({ code: 404, msg: '用户不存在', data: null });
    const { password, ...userInfo } = users[0];
    userInfo.roles = (userInfo.roles || 'student').split(',');
    res.json({ code: 200, msg: '操作成功', data: userInfo });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.get('/api/user/list', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, username, status } = req.query;
    let where = '1=1';
    let params = [];
    if (username) { where += ' AND username LIKE ?'; params.push(`%${username}%`); }
    if (status !== undefined) { where += ' AND status = ?'; params.push(parseInt(status)); }

    const total = (await query(`SELECT COUNT(*) as c FROM users WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT id,username,nickname,real_name,student_no,email,phone,college,major,status,created_at FROM users WHERE ${where} ORDER BY id ASC LIMIT ${offset}, ${parseInt(pageSize)}`, params);

    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    console.error('用户列表错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 新增用户
app.post('/api/user', authMiddleware, async (req, res) => {
  try {
    const { username, password, nickname, realName, studentNo, email, phone, college, major, className, roles } = req.body;
    if (!username || !password) {
      return res.json({ code: 400, msg: '用户名和密码不能为空', data: null });
    }
    const exists = await query('SELECT id FROM users WHERE username = ?', [username]);
    if (exists.length > 0) {
      return res.json({ code: 400, msg: '用户名已存在', data: null });
    }
    const hash = bcrypt.hashSync(password, 10);
    await query(
      'INSERT INTO users (username, password, nickname, real_name, student_no, email, phone, college, major, class_name, roles) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [username, hash, nickname || username, realName || '', studentNo || '', email || '', phone || '', college || '', major || '', className || '', roles || 'student']
    );
    res.json({ code: 200, msg: '创建成功', data: null });
  } catch (e) {
    console.error('创建用户错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 更新用户
app.put('/api/user', authMiddleware, async (req, res) => {
  try {
    const { id, nickname, realName, studentNo, email, phone, college, major, className, roles, status } = req.body;
    if (!id) return res.json({ code: 400, msg: '用户ID不能为空', data: null });
    await query(
      'UPDATE users SET nickname=?,real_name=?,student_no=?,email=?,phone=?,college=?,major=?,class_name=?,roles=?,status=? WHERE id=?',
      [nickname, realName, studentNo, email, phone, college, major, className, roles, status, id]
    );
    res.json({ code: 200, msg: '更新成功', data: null });
  } catch (e) {
    console.error('更新用户错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 删除用户
app.delete('/api/user/:id', authMiddleware, async (req, res) => {
  try {
    await query('DELETE FROM users WHERE id=?', [req.params.id]);
    res.json({ code: 200, msg: '删除成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 重置密码
app.put('/api/user/resetPwd', authMiddleware, async (req, res) => {
  try {
    const { id, password } = req.body;
    const hash = bcrypt.hashSync(password || '123456', 10);
    await query('UPDATE users SET password=? WHERE id=?', [hash, id]);
    res.json({ code: 200, msg: '重置成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 角色管理 ====================

// 角色分页查询
app.get('/api/user/role/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, roleName } = req.query;
    let where = '1=1';
    let params = [];
    if (roleName) { where += ' AND role_name LIKE ?'; params.push(`%${roleName}%`); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM roles WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM roles WHERE ${where} ORDER BY sort ASC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 新增角色
app.post('/api/user/role', authMiddleware, async (req, res) => {
  try {
    const { roleName, roleKey, sort, remark } = req.body;
    const exists = await query('SELECT id FROM roles WHERE role_key = ?', [roleKey]);
    if (exists.length > 0) return res.json({ code: 400, msg: '权限字符已存在', data: null });
    await query(
      'INSERT INTO roles (role_name, role_key, sort, status, remark) VALUES (?,?,?,1,?)',
      [roleName, roleKey, sort || 0, remark || '']
    );
    res.json({ code: 200, msg: '创建成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 更新角色
app.put('/api/user/role', authMiddleware, async (req, res) => {
  try {
    const { id, roleName, roleKey, sort, status, remark } = req.body;
    await query('UPDATE roles SET role_name=?,role_key=?,sort=?,status=?,remark=? WHERE id=?',
      [roleName, roleKey, sort, status, remark, id]);
    res.json({ code: 200, msg: '更新成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 删除角色
app.delete('/api/user/role/:id', authMiddleware, async (req, res) => {
  try {
    await query('DELETE FROM roles WHERE id=?', [req.params.id]);
    res.json({ code: 200, msg: '删除成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 活动 ====================

app.get('/api/volunteer/activity/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, title, status } = req.query;
    let where = '1=1';
    let params = [];
    if (title) { where += ' AND title LIKE ?'; params.push(`%${title}%`); }
    if (status !== undefined) { where += ' AND status = ?'; params.push(parseInt(status)); }

    const total = (await query(`SELECT COUNT(*) as c FROM activities WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM activities WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);

    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    console.error('活动列表错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.get('/api/volunteer/activity/:id', authMiddleware, async (req, res) => {
  try {
    const rows = await query('SELECT * FROM activities WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.json({ code: 404, msg: '活动不存在', data: null });
    res.json({ code: 200, msg: '操作成功', data: rows[0] });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.post('/api/volunteer/activity', authMiddleware, async (req, res) => {
  try {
    const { title, content, activityType, location, startTime, endTime, maxParticipants, organizer, contactPerson, contactPhone } = req.body;
    const r = await query(
      'INSERT INTO activities (title, content, activity_type, location, start_time, end_time, max_participants, organizer, contact_person, contact_phone, status, creator_id) VALUES (?,?,?,?,?,?,?,?,?,?,0,?)',
      [title, content, activityType, location, startTime, endTime, maxParticipants || 50, organizer, contactPerson, contactPhone, req.user.userId]
    );
    res.json({ code: 200, msg: '创建成功', data: { id: r.insertId } });
  } catch (e) {
    console.error('创建活动错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.put('/api/volunteer/activity', authMiddleware, async (req, res) => {
  try {
    const { id, title, content, location, startTime, endTime, maxParticipants } = req.body;
    await query(
      'UPDATE activities SET title=?,content=?,location=?,start_time=?,end_time=?,max_participants=? WHERE id=?',
      [title, content, location, startTime, endTime, maxParticipants, id]
    );
    res.json({ code: 200, msg: '更新成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.delete('/api/volunteer/activity/:id', authMiddleware, async (req, res) => {
  try {
    await query('UPDATE activities SET status=3 WHERE id=?', [req.params.id]);
    res.json({ code: 200, msg: '取消成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 活动报名
app.post('/api/volunteer/activity/:id/enroll', authMiddleware, async (req, res) => {
  try {
    const activityId = req.params.id;
    const userId = req.query.userId || req.user.userId;
    
    // 检查活动状态
    const activity = await query('SELECT * FROM activities WHERE id=? AND status IN (0,1)', [activityId]);
    if (activity.length === 0) return res.json({ code: 400, msg: '活动不存在或不在报名中', data: null });
    
    // 检查人数上限
    if (activity[0].max_participants > 0 && activity[0].current_participants >= activity[0].max_participants) {
      return res.json({ code: 400, msg: '活动报名人数已满', data: null });
    }
    
    // 检查是否已报名
    const enrolled = await query('SELECT id FROM activity_enrolls WHERE activity_id=? AND user_id=?', [activityId, userId]);
    if (enrolled.length > 0) return res.json({ code: 400, msg: '已报名该活动', data: null });
    
    // 获取用户信息
    const user = await query('SELECT * FROM users WHERE id=?', [userId]);
    if (user.length === 0) return res.json({ code: 400, msg: '用户不存在', data: null });
    
    await query(
      'INSERT INTO activity_enrolls (activity_id, user_id, real_name, phone, status) VALUES (?,?,?,?,0)',
      [activityId, userId, user[0].real_name, user[0].phone]
    );
    
    // 更新报名人数
    await query('UPDATE activities SET current_participants=current_participants+1 WHERE id=?', [activityId]);
    
    res.json({ code: 200, msg: '报名成功', data: null });
  } catch (e) {
    console.error('报名错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 取消报名
app.delete('/api/volunteer/activity/:id/enroll', authMiddleware, async (req, res) => {
  try {
    const activityId = req.params.id;
    const userId = req.query.userId || req.user.userId;
    
    await query('DELETE FROM activity_enrolls WHERE activity_id=? AND user_id=?', [activityId, userId]);
    await query('UPDATE activities SET current_participants=GREATEST(current_participants-1,0) WHERE id=?', [activityId]);
    
    res.json({ code: 200, msg: '取消报名成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 签到
app.post('/api/volunteer/activity/check-in', authMiddleware, async (req, res) => {
  try {
    const { activityId, userId, realName, checkInCode, location, lat, lng } = req.body;
    
    // 验证签到码
    const activity = await query('SELECT * FROM activities WHERE id=?', [activityId]);
    if (activity.length === 0) return res.json({ code: 400, msg: '活动不存在', data: null });
    if (activity[0].check_in_code && activity[0].check_in_code !== checkInCode) {
      return res.json({ code: 400, msg: '签到码错误', data: null });
    }
    
    // 检查是否已签到
    const existing = await query('SELECT id FROM check_ins WHERE activity_id=? AND user_id=?', [activityId, userId]);
    if (existing.length > 0) return res.json({ code: 400, msg: '已签到，请勿重复签到', data: null });
    
    await query(
      'INSERT INTO check_ins (activity_id, user_id, real_name, check_in_time, check_in_location, check_in_lat, check_in_lng, status) VALUES (?,?,?,NOW(),?,?,?,0)',
      [activityId, userId, realName || '', location || '', lat || null, lng || null]
    );
    
    res.json({ code: 200, msg: '签到成功', data: null });
  } catch (e) {
    console.error('签到错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 签退
app.post('/api/volunteer/activity/:id/check-out', authMiddleware, async (req, res) => {
  try {
    const activityId = req.params.id;
    const userId = req.query.userId || req.user.userId;
    
    const checkIn = await query('SELECT * FROM check_ins WHERE activity_id=? AND user_id=? AND check_out_time IS NULL', [activityId, userId]);
    if (checkIn.length === 0) return res.json({ code: 400, msg: '未签到或已签退', data: null });
    
    // 获取活动标题
    const activity = await query('SELECT title FROM activities WHERE id=?', [activityId]);
    const activityTitle = activity.length > 0 ? activity[0].title : '';
    
    const checkInTime = new Date(checkIn[0].check_in_time);
    const now = new Date();
    const duration = (now - checkInTime) / (1000 * 60 * 60); // 小时
    
    await query(
      'UPDATE check_ins SET check_out_time=NOW(), duration=ROUND(?,2), status=1 WHERE id=?',
      [duration, checkIn[0].id]
    );
    
    // 更新志愿时长
    await query('UPDATE volunteers SET total_hours=total_hours+?, this_year_hours=this_year_hours+? WHERE user_id=?', [duration, duration, userId]);
    await query(
      'INSERT INTO hours_records (user_id, real_name, activity_id, activity_title, hours, record_type, stat_month) VALUES (?,?,?,?,?,"auto",DATE_FORMAT(NOW(),"%Y-%m"))',
      [userId, checkIn[0].real_name, activityId, activityTitle, duration]
    );
    
    res.json({ code: 200, msg: '签退成功', data: { hours: duration.toFixed(2) } });
  } catch (e) {
    console.error('签退错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 获取用户参与的活动
app.get('/api/volunteer/activity/user/:userId', authMiddleware, async (req, res) => {
  try {
    const rows = await query(
      'SELECT a.*, e.enroll_time, e.status as enroll_status FROM activities a LEFT JOIN activity_enrolls e ON a.id=e.activity_id WHERE e.user_id=? ORDER BY e.enroll_time DESC',
      [req.params.userId]
    );
    res.json({ code: 200, msg: '操作成功', data: rows });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 获取活动报名列表
app.get('/api/volunteer/activity/:id/enrolls', authMiddleware, async (req, res) => {
  try {
    const rows = await query('SELECT * FROM activity_enrolls WHERE activity_id=? ORDER BY enroll_time DESC', [req.params.id]);
    res.json({ code: 200, msg: '操作成功', data: rows });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 获取活动签到列表
app.get('/api/volunteer/activity/:id/checkins', authMiddleware, async (req, res) => {
  try {
    const rows = await query('SELECT * FROM check_ins WHERE activity_id=? ORDER BY check_in_time DESC', [req.params.id]);
    res.json({ code: 200, msg: '操作成功', data: rows });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 志愿者管理 ====================

app.get('/api/volunteer/list', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, realName, status } = req.query;
    let where = '1=1';
    let params = [];
    if (realName) { where += ' AND real_name LIKE ?'; params.push(`%${realName}%`); }
    if (status !== undefined) { where += ' AND status = ?'; params.push(parseInt(status)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM volunteers WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM volunteers WHERE ${where} ORDER BY id DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 签到记录分页
app.get('/api/volunteer/checkin/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, activityId, userId } = req.query;
    let where = '1=1';
    let params = [];
    if (activityId) { where += ' AND activity_id = ?'; params.push(parseInt(activityId)); }
    if (userId) { where += ' AND user_id = ?'; params.push(parseInt(userId)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM check_ins WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM check_ins WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 时长统计
app.get('/api/volunteer/hours/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, userId, statMonth } = req.query;
    let where = '1=1';
    let params = [];
    if (userId) { where += ' AND user_id = ?'; params.push(parseInt(userId)); }
    if (statMonth) { where += ' AND stat_month = ?'; params.push(statMonth); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM hours_records WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM hours_records WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 团员发展 ====================

// 入团申请分页查询
app.get('/api/league/application/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, realName, status } = req.query;
    let where = '1=1';
    let params = [];
    if (realName) { where += ' AND real_name LIKE ?'; params.push(`%${realName}%`); }
    if (status !== undefined) { where += ' AND status = ?'; params.push(parseInt(status)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM league_applications WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM league_applications WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    console.error('入团申请列表错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 获取入团申请详情
app.get('/api/league/application/:id', authMiddleware, async (req, res) => {
  try {
    const rows = await query('SELECT * FROM league_applications WHERE id=?', [req.params.id]);
    if (rows.length === 0) return res.json({ code: 404, msg: '申请不存在', data: null });
    res.json({ code: 200, msg: '操作成功', data: rows[0] });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 提交入团申请
app.post('/api/league/application', authMiddleware, async (req, res) => {
  try {
    const { realName, studentNo, college, major, className, phone, applyReason } = req.body;
    const userId = req.user.userId;
    
    // 检查是否已申请
    const existing = await query('SELECT id FROM league_applications WHERE user_id=? AND status IN (0,1)', [userId]);
    if (existing.length > 0) return res.json({ code: 400, msg: '已有进行中的申请', data: null });
    
    await query(
      'INSERT INTO league_applications (user_id, real_name, student_no, college, major, class_name, phone, apply_reason, current_node, status) VALUES (?,?,?,?,?,?,?,?,"apply",0)',
      [userId, realName, studentNo, college, major, className, phone, applyReason]
    );
    
    res.json({ code: 200, msg: '提交成功', data: null });
  } catch (e) {
    console.error('提交申请错误:', e);
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 审核入团申请
app.put('/api/league/application/review', authMiddleware, async (req, res) => {
  try {
    const { id, status, reviewRemark } = req.body;
    await query(
      'UPDATE league_applications SET status=?,reviewer_id=?,reviewer_name=?,review_time=NOW(),review_remark=?,current_node=? WHERE id=?',
      [status, req.user.userId, req.user.nickname, reviewRemark || '', status === 1 ? 'reviewed' : 'rejected', id]
    );
    res.json({ code: 200, msg: '审核完成', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 政审备案分页查询
app.get('/api/league/review/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, userId } = req.query;
    let where = '1=1';
    let params = [];
    if (userId) { where += ' AND user_id = ?'; params.push(parseInt(userId)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM political_reviews WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM political_reviews WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 新增政审备案
app.post('/api/league/review', authMiddleware, async (req, res) => {
  try {
    const { applicationId, userId, reviewType, reviewContent, attachment } = req.body;
    await query(
      'INSERT INTO political_reviews (application_id, user_id, review_type, review_content, attachment) VALUES (?,?,?,?,?)',
      [applicationId, userId, reviewType, reviewContent || '', attachment || '']
    );
    res.json({ code: 200, msg: '备案成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 审核政审
app.put('/api/league/review/audit', authMiddleware, async (req, res) => {
  try {
    const { id, reviewResult } = req.body;
    await query(
      'UPDATE political_reviews SET review_result=?,reviewer_id=?,reviewer_name=?,review_time=NOW() WHERE id=?',
      [reviewResult, req.user.userId, req.user.nickname, id]
    );
    res.json({ code: 200, msg: '审核完成', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 电子档案分页查询
app.get('/api/league/archive/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, userId } = req.query;
    let where = '1=1';
    let params = [];
    if (userId) { where += ' AND user_id = ?'; params.push(parseInt(userId)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM league_archives WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM league_archives WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 生成电子档案
app.post('/api/league/archive', authMiddleware, async (req, res) => {
  try {
    const { applicationId, userId, archiveName } = req.body;
    const archiveNo = 'ARCH' + Date.now();
    await query(
      'INSERT INTO league_archives (application_id, user_id, archive_no, archive_name, status, generate_time) VALUES (?,?,?,?,0,NOW())',
      [applicationId, userId, archiveNo, archiveName]
    );
    res.json({ code: 200, msg: '生成成功', data: { archiveNo } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// ==================== 勤工助学 ====================

// 岗位分页查询
app.get('/api/workstudy/position/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, title, status } = req.query;
    let where = '1=1';
    let params = [];
    if (title) { where += ' AND title LIKE ?'; params.push(`%${title}%`); }
    if (status !== undefined) { where += ' AND status = ?'; params.push(parseInt(status)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM ws_positions WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM ws_positions WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 获取岗位详情
app.get('/api/workstudy/position/:id', authMiddleware, async (req, res) => {
  try {
    const rows = await query('SELECT * FROM ws_positions WHERE id=?', [req.params.id]);
    if (rows.length === 0) return res.json({ code: 404, msg: '岗位不存在', data: null });
    res.json({ code: 200, msg: '操作成功', data: rows[0] });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 新增岗位
app.post('/api/workstudy/position', authMiddleware, async (req, res) => {
  try {
    const { title, department, positionType, description, requirements, salaryPerHour, maxWorkers, workHoursPerWeek, workLocation, contactPerson, contactPhone } = req.body;
    await query(
      'INSERT INTO ws_positions (title, department, position_type, description, requirements, salary_per_hour, max_workers, work_hours_per_week, work_location, contact_person, contact_phone, status) VALUES (?,?,?,?,?,?,?,?,?,?,?,1)',
      [title, department, positionType, description, requirements, salaryPerHour, maxWorkers || 1, workHoursPerWeek || 10, workLocation, contactPerson, contactPhone]
    );
    res.json({ code: 200, msg: '创建成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 更新岗位
app.put('/api/workstudy/position', authMiddleware, async (req, res) => {
  try {
    const { id, title, department, positionType, description, requirements, salaryPerHour, maxWorkers, workHoursPerWeek, workLocation, contactPerson, contactPhone, status } = req.body;
    await query(
      'UPDATE ws_positions SET title=?,department=?,position_type=?,description=?,requirements=?,salary_per_hour=?,max_workers=?,work_hours_per_week=?,work_location=?,contact_person=?,contact_phone=?,status=? WHERE id=?',
      [title, department, positionType, description, requirements, salaryPerHour, maxWorkers, workHoursPerWeek, workLocation, contactPerson, contactPhone, status, id]
    );
    res.json({ code: 200, msg: '更新成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 删除岗位
app.delete('/api/workstudy/position/:id', authMiddleware, async (req, res) => {
  try {
    await query('DELETE FROM ws_positions WHERE id=?', [req.params.id]);
    res.json({ code: 200, msg: '删除成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 应聘申请分页查询
app.get('/api/workstudy/application/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, positionId, status } = req.query;
    let where = '1=1';
    let params = [];
    if (positionId) { where += ' AND position_id = ?'; params.push(parseInt(positionId)); }
    if (status !== undefined) { where += ' AND status = ?'; params.push(parseInt(status)); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM ws_applications WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM ws_applications WHERE ${where} ORDER BY created_at DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 提交应聘申请
app.post('/api/workstudy/application', authMiddleware, async (req, res) => {
  try {
    const { positionId, realName, studentNo, college, major, className, phone, applyReason, relatedExperience, availableHours } = req.body;
    const userId = req.user.userId;
    
    // 检查是否已申请该岗位
    const existing = await query('SELECT id FROM ws_applications WHERE position_id=? AND user_id=? AND status IN (0,1)', [positionId, userId]);
    if (existing.length > 0) return res.json({ code: 400, msg: '已申请该岗位', data: null });
    
    await query(
      'INSERT INTO ws_applications (position_id, user_id, real_name, student_no, college, major, class_name, phone, apply_reason, related_experience, available_hours, status) VALUES (?,?,?,?,?,?,?,?,?,?,?,0)',
      [positionId, userId, realName, studentNo, college, major, className, phone, applyReason, relatedExperience, availableHours]
    );
    res.json({ code: 200, msg: '申请成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 审核应聘申请
app.put('/api/workstudy/application/review', authMiddleware, async (req, res) => {
  try {
    const { id, status, reviewRemark } = req.body;
    await query(
      'UPDATE ws_applications SET status=?,reviewer_id=?,reviewer_name=?,review_time=NOW(),review_remark=? WHERE id=?',
      [status, req.user.userId, req.user.nickname, reviewRemark || '', id]
    );
    res.json({ code: 200, msg: '审核完成', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 考勤分页查询
app.get('/api/workstudy/attendance/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, userId, positionId, checkDate } = req.query;
    let where = '1=1';
    let params = [];
    if (userId) { where += ' AND user_id = ?'; params.push(parseInt(userId)); }
    if (positionId) { where += ' AND position_id = ?'; params.push(parseInt(positionId)); }
    if (checkDate) { where += ' AND check_date = ?'; params.push(checkDate); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM ws_attendance WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM ws_attendance WHERE ${where} ORDER BY check_date DESC, check_in_time DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 新增考勤记录
app.post('/api/workstudy/attendance', authMiddleware, async (req, res) => {
  try {
    const { userId, positionId, realName, checkDate, checkInTime, checkOutTime, remark } = req.body;
    
    // 计算工时
    let workHours = 0;
    if (checkInTime && checkOutTime) {
      const start = new Date(checkInTime);
      const end = new Date(checkOutTime);
      workHours = Math.round((end - start) / (1000 * 60 * 60) * 100) / 100;
    }
    
    await query(
      'INSERT INTO ws_attendance (user_id, position_id, real_name, check_date, check_in_time, check_out_time, work_hours, status, remark) VALUES (?,?,?,?,?,?,?,?,?)',
      [userId, positionId, realName, checkDate, checkInTime, checkOutTime, workHours, 0, remark || '']
    );
    res.json({ code: 200, msg: '记录成功', data: { workHours } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 审核考勤
app.put('/api/workstudy/attendance/audit', authMiddleware, async (req, res) => {
  try {
    const { id, status } = req.body;
    await query('UPDATE ws_attendance SET status=? WHERE id=?', [status, id]);
    res.json({ code: 200, msg: '审核完成', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 薪资分页查询
app.get('/api/workstudy/salary/page', authMiddleware, async (req, res) => {
  try {
    const { pageNum = 1, pageSize = 10, userId, salaryMonth } = req.query;
    let where = '1=1';
    let params = [];
    if (userId) { where += ' AND user_id = ?'; params.push(parseInt(userId)); }
    if (salaryMonth) { where += ' AND salary_month = ?'; params.push(salaryMonth); }
    
    const total = (await query(`SELECT COUNT(*) as c FROM ws_salary WHERE ${where}`, params))[0].c;
    const offset = Math.floor((parseInt(pageNum) - 1) * parseInt(pageSize));
    const rows = await query(`SELECT * FROM ws_salary WHERE ${where} ORDER BY salary_month DESC LIMIT ${offset}, ${parseInt(pageSize)}`, params);
    
    res.json({ code: 200, msg: '操作成功', data: { total, rows, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 生成薪资
app.post('/api/workstudy/salary', authMiddleware, async (req, res) => {
  try {
    const { userId, positionId, realName, studentNo, salaryMonth, salaryPerHour } = req.body;
    
    // 计算该月总工时
    const attendance = await query(
      'SELECT SUM(work_hours) as total_hours FROM ws_attendance WHERE user_id=? AND position_id=? AND check_date LIKE ? AND status=1',
      [userId, positionId, `${salaryMonth}%`]
    );
    const totalHours = attendance[0].total_hours || 0;
    const baseSalary = Math.round(totalHours * salaryPerHour * 100) / 100;
    
    await query(
      'INSERT INTO ws_salary (user_id, position_id, real_name, student_no, salary_month, total_hours, salary_per_hour, base_salary, actual_salary, status) VALUES (?,?,?,?,?,?,?,?,?,0) ON DUPLICATE KEY UPDATE total_hours=VALUES(total_hours), base_salary=VALUES(base_salary), actual_salary=VALUES(actual_salary)',
      [userId, positionId, realName, studentNo, salaryMonth, totalHours, salaryPerHour, baseSalary, baseSalary]
    );
    
    res.json({ code: 200, msg: '生成成功', data: { totalHours, baseSalary } });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

// 确认/发放薪资
app.put('/api/workstudy/salary/pay', authMiddleware, async (req, res) => {
  try {
    const { id, status } = req.body;
    const payTime = status === 2 ? new Date() : null;
    await query('UPDATE ws_salary SET status=?,pay_time=? WHERE id=?', [status, payTime, id]);
    res.json({ code: 200, msg: '操作成功', data: null });
  } catch (e) {
    res.json({ code: 500, msg: '服务器错误', data: null });
  }
});

app.get('/api/todos', authMiddleware, (req, res) => {
  res.json({ code: 200, msg: '操作成功', data: [
    { id: 1, tag: '审核', type: 'warning', title: '张三的入团申请待审核', time: '10分钟前' },
    { id: 2, tag: '薪资', type: 'success', title: '12月勤工助学工资待确认', time: '1小时前' },
    { id: 3, tag: '活动', type: 'primary', title: '校园清洁志愿活动即将开始', time: '2小时前' },
    { id: 4, tag: '政审', type: 'danger', title: '李四的政审材料待备案', time: '3小时前' },
    { id: 5, tag: '考勤', type: 'info', title: '本周考勤异常待处理', time: '5小时前' }
  ]});
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'UP', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log('==========================================');
  console.log('  学生综合事务中台 - 后端API服务(MySQL版)');
  console.log('==========================================');
  console.log(`  服务地址: http://localhost:${PORT}`);
  console.log('  数据库: sap_service (MySQL)');
  console.log('  默认账号: admin / admin123');
  console.log('==========================================');
});
