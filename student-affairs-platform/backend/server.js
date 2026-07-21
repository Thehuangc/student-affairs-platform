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
    const totalPositions = await query('SELECT COUNT(*) as c FROM activities WHERE activity_type!=""');
    const stats = {
      totalUsers,
      totalActivities: totalActivities,
      totalVolunteerHours: 0,
      totalPositions: 0
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
