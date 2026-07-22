<template>
  <div class="login-scene">
    <!-- 动态渐变背景 -->
    <div class="bg-canvas">
      <div class="gradient-orb orb-1"></div>
      <div class="gradient-orb orb-2"></div>
      <div class="gradient-orb orb-3"></div>
      <div class="gradient-orb orb-4"></div>
      <div class="grid-pattern"></div>
    </div>

    <!-- 主体卡片 -->
    <div class="login-card">
      <!-- 左侧品牌面板 -->
      <div class="brand-panel">
        <div class="brand-glow"></div>
        <div class="brand-content">
          <div class="logo-badge">
            <svg viewBox="0 0 48 48" fill="none" class="logo-svg">
              <rect x="4" y="4" width="40" height="40" rx="10" stroke="currentColor" stroke-width="2" opacity="0.3" />
              <path d="M24 12 L30 22 L42 22 L32 30 L36 42 L24 36 L12 42 L16 30 L6 22 L18 22 Z" fill="currentColor" opacity="0.9" />
            </svg>
          </div>
          <h1 class="brand-name">学生综合事务中台</h1>
          <div class="brand-divider">
            <span class="divider-dot"></span>
            <span class="divider-line"></span>
            <span class="divider-dot"></span>
          </div>
          <p class="brand-desc">一站式学生事务 · 数字化管理平台</p>
          <div class="feature-list">
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12" /></svg>
              </div>
              <span>团员发展全流程管理</span>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12" /></svg>
              </div>
              <span>志愿服务时长智能核算</span>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12" /></svg>
              </div>
              <span>勤工助学薪资自动结算</span>
            </div>
          </div>
        </div>
        <!-- 品牌面板装饰圆环 -->
        <div class="brand-rings">
          <div class="ring ring-1"></div>
          <div class="ring ring-2"></div>
        </div>
      </div>

      <!-- 右侧表单面板 -->
      <div class="form-panel">
        <div class="form-inner">
          <!-- 欢迎区 -->
          <div class="welcome-section">
            <div class="avatar-placeholder">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                <circle cx="12" cy="7" r="4" />
              </svg>
            </div>
            <h2>欢迎回来</h2>
            <p>请输入您的账号信息以继续</p>
          </div>

          <!-- 表单 -->
          <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form" @submit.prevent="handleLogin">
            <!-- 用户名 -->
            <div class="field-block">
              <label class="field-label">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="label-icon">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                  <circle cx="12" cy="7" r="4" />
                </svg>
                用户名
              </label>
              <el-form-item prop="username">
                <el-input
                  v-model="loginForm.username"
                  placeholder="请输入用户名"
                  size="large"
                  clearable
                />
              </el-form-item>
            </div>

            <!-- 密码 -->
            <div class="field-block">
              <label class="field-label">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="label-icon">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                  <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                </svg>
                密码
              </label>
              <el-form-item prop="password">
                <el-input
                  v-model="loginForm.password"
                  type="password"
                  placeholder="请输入密码"
                  size="large"
                  show-password
                  @keyup.enter="handleLogin"
                />
              </el-form-item>
            </div>

            <!-- 登录按钮 -->
            <button class="submit-btn" :class="{ loading: loading }" :disabled="loading" @click.prevent="handleLogin">
              <span v-if="!loading" class="submit-btn-content">
                <span>登 录</span>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" class="submit-arrow">
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </span>
              <span v-else class="submit-spinner"></span>
            </button>
          </el-form>

          <!-- 快速登录 -->
          <div class="quick-login">
            <div class="quick-label">
              <span class="quick-line"></span>
              <span>快速选择账号</span>
              <span class="quick-line"></span>
            </div>
            <div class="quick-chips">
              <div class="quick-chip" @click="fillAccount('admin', 'admin123')">
                <span class="chip-avatar admin">管</span>
                <div class="chip-info">
                  <span class="chip-name">管理员</span>
                  <span class="chip-pwd">admin123</span>
                </div>
              </div>
              <div class="quick-chip" @click="fillAccount('student', 'admin123')">
                <span class="chip-avatar student">学</span>
                <div class="chip-info">
                  <span class="chip-name">学生</span>
                  <span class="chip-pwd">admin123</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部提示 -->
    <div class="footer-hint">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="14" height="14">
        <circle cx="12" cy="12" r="10" />
        <line x1="12" y1="16" x2="12" y2="12" />
        <line x1="12" y1="8" x2="12.01" y2="8" />
      </svg>
      <span>学生综合事务中台 v1.0 · 微服务架构</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loginFormRef = ref<FormInstance>()
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

function fillAccount(username: string, password: string) {
  loginForm.username = username
  loginForm.password = password
}

async function handleLogin() {
  const valid = await loginFormRef.value?.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await userStore.login(loginForm.username, loginForm.password)
    ElMessage.success('登录成功')
    const redirect = route.query.redirect as string
    router.push(redirect || '/')
  } catch (error: any) {
    ElMessage.error(error.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
/* ═══════════════════════════════════════════════
   登录页 - 现代玻璃态设计
   ═══════════════════════════════════════════════ */

// 变量
$brand-start: #1a1a2e;
$brand-end: #16213e;
$accent-primary: #3b82f6;
$accent-secondary: #6366f1;
$accent-warm: #f59e0b;
$surface-glass: rgba(255, 255, 255, 0.95);
$surface-white: #ffffff;
$text-primary: #0f172a;
$text-secondary: #475569;
$text-muted: #94a3b8;
$border-subtle: #e2e8f0;

.login-scene {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  position: relative;
  overflow: hidden;
  background: #0f172a;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* ═══════ 动态渐变背景 ═══════ */
.bg-canvas {
  position: absolute;
  inset: 0;
  z-index: 0;
  background:
    radial-gradient(ellipse 80% 80% at 20% 15%, rgba(59, 130, 246, 0.25) 0%, transparent 50%),
    radial-gradient(ellipse 60% 60% at 80% 85%, rgba(99, 102, 241, 0.2) 0%, transparent 50%),
    radial-gradient(ellipse 50% 50% at 50% 50%, rgba(245, 158, 11, 0.06) 0%, transparent 70%);
}

.gradient-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(100px);
  opacity: 0.3;

  &.orb-1 {
    width: 500px;
    height: 500px;
    background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    top: -15%;
    left: -10%;
    animation: orbDrift 25s ease-in-out infinite;
  }
  &.orb-2 {
    width: 400px;
    height: 400px;
    background: linear-gradient(135deg, #6366f1, #ec4899);
    bottom: -10%;
    right: -5%;
    animation: orbDrift 30s ease-in-out infinite reverse;
  }
  &.orb-3 {
    width: 300px;
    height: 300px;
    background: linear-gradient(135deg, #06b6d4, #3b82f6);
    top: 50%;
    left: 60%;
    animation: orbDrift 20s ease-in-out infinite 5s;
  }
  &.orb-4 {
    width: 250px;
    height: 250px;
    background: linear-gradient(135deg, #f59e0b, #ef4444);
    top: 30%;
    left: 15%;
    animation: orbDrift 22s ease-in-out infinite 8s;
  }
}

@keyframes orbDrift {
  0%, 100% { transform: translate(0, 0) scale(1); }
  25% { transform: translate(30px, -40px) scale(1.08); }
  50% { transform: translate(-20px, 20px) scale(0.94); }
  75% { transform: translate(15px, 35px) scale(1.05); }
}

.grid-pattern {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
  background-size: 60px 60px;
  opacity: 0.6;
}

/* ═══════ 主体卡片 ═══════ */
.login-card {
  position: relative;
  z-index: 1;
  display: flex;
  width: 920px;
  min-height: 580px;
  border-radius: 24px;
  overflow: hidden;
  box-shadow:
    0 0 0 1px rgba(255, 255, 255, 0.08),
    0 20px 60px -10px rgba(0, 0, 0, 0.5),
    0 0 120px -20px rgba(59, 130, 246, 0.2);
  animation: cardEnter 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  backdrop-filter: blur(10px);
}

@keyframes cardEnter {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.96);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* ═══════ 左侧品牌面板 ═══════ */
.brand-panel {
  position: relative;
  width: 400px;
  flex-shrink: 0;
  background: linear-gradient(160deg, #0f172a 0%, #1e293b 40%, #1a1a2e 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;

  .brand-glow {
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background:
      radial-gradient(circle at 30% 40%, rgba(59, 130, 246, 0.15) 0%, transparent 40%),
      radial-gradient(circle at 70% 60%, rgba(99, 102, 241, 0.1) 0%, transparent 40%);
    animation: glowPulse 8s ease-in-out infinite;
  }

  @keyframes glowPulse {
    0%, 100% { opacity: 0.7; }
    50% { opacity: 1; }
  }

  .brand-content {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 40px;
    animation: contentFadeIn 0.8s ease 0.2s forwards;
    opacity: 0;
  }

  @keyframes contentFadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .logo-badge {
    width: 80px;
    height: 80px;
    margin: 0 auto 28px;
    border-radius: 20px;
    background: linear-gradient(135deg, rgba(59,130,246,0.2), rgba(99,102,241,0.2));
    border: 1px solid rgba(255,255,255,0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #60a5fa;
    backdrop-filter: blur(10px);

    .logo-svg {
      width: 40px;
      height: 40px;
      animation: logoFloat 4s ease-in-out infinite;
    }
  }

  @keyframes logoFloat {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-4px); }
  }

  .brand-name {
    font-size: 28px;
    font-weight: 700;
    color: #f1f5f9;
    letter-spacing: 4px;
    margin-bottom: 20px;
    font-family: 'Noto Serif SC', 'STKaiti', 'KaiTi', 'STSong', serif;
  }

  .brand-divider {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-bottom: 16px;

    .divider-line {
      width: 40px;
      height: 1px;
      background: linear-gradient(90deg, transparent, rgba(245,158,11,0.6), transparent);
    }
    .divider-dot {
      width: 5px;
      height: 5px;
      background: #f59e0b;
      border-radius: 50%;
    }
  }

  .brand-desc {
    font-size: 13px;
    color: rgba(241,245,249,0.5);
    letter-spacing: 2px;
    margin-bottom: 40px;
  }

  .feature-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .feature-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 16px;
    background: rgba(255,255,255,0.04);
    border-radius: 10px;
    border: 1px solid rgba(255,255,255,0.04);
    transition: all 0.3s ease;

    &:hover {
      background: rgba(255,255,255,0.07);
      border-color: rgba(255,255,255,0.08);
    }

    .feature-icon {
      width: 20px;
      height: 20px;
      color: #60a5fa;
      flex-shrink: 0;

      svg {
        width: 100%;
        height: 100%;
      }
    }

    span {
      font-size: 13px;
      color: rgba(241,245,249,0.7);
      letter-spacing: 1px;
    }
  }

  /* 装饰圆环 */
  .brand-rings {
    position: absolute;
    top: -80px;
    right: -80px;
    width: 200px;
    height: 200px;

    .ring {
      position: absolute;
      border-radius: 50%;
      border: 1px solid rgba(255,255,255,0.06);

      &.ring-1 {
        width: 200px;
        height: 200px;
        top: 0;
        left: 0;
      }
      &.ring-2 {
        width: 150px;
        height: 150px;
        top: 25px;
        left: 25px;
      }
    }
  }
}

/* ═══════ 右侧表单面板 ═══════ */
.form-panel {
  flex: 1;
  background: $surface-glass;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 50px;
  backdrop-filter: blur(20px);
}

.form-inner {
  width: 100%;
  max-width: 360px;
}

.welcome-section {
  text-align: center;
  margin-bottom: 36px;
  animation: contentFadeIn 0.8s ease 0.1s forwards;
  opacity: 0;

  .avatar-placeholder {
    width: 64px;
    height: 64px;
    margin: 0 auto 20px;
    border-radius: 18px;
    background: linear-gradient(135deg, #3b82f6, #6366f1);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    box-shadow: 0 8px 24px rgba(59, 130, 246, 0.3);

    svg {
      width: 28px;
      height: 28px;
    }
  }

  h2 {
    font-size: 26px;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: 8px;
  }
  p {
    font-size: 14px;
    color: $text-muted;
  }
}

/* ═══════ 表单字段 ═══════ */
.field-block {
  margin-bottom: 8px;

  .field-label {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    font-weight: 600;
    color: $text-secondary;
    margin-bottom: 8px;
    letter-spacing: 0.5px;

    .label-icon {
      width: 16px;
      height: 16px;
      color: $text-muted;
    }
  }

  :deep(.el-form-item) {
    margin-bottom: 0;
  }

  :deep(.el-input__wrapper) {
    background: #f8fafc;
    border: 1.5px solid $border-subtle;
    border-radius: 12px;
    box-shadow: none;
    padding: 4px 16px;
    transition: all 0.25s ease;

    &:hover {
      border-color: #93c5fd;
      background: #ffffff;
    }

    &.is-focus {
      border-color: $accent-primary;
      background: #ffffff;
      box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.08);
    }
  }

  :deep(.el-input__inner) {
    font-size: 15px;
    color: $text-primary;

    &::placeholder {
      color: #cbd5e1;
      font-size: 14px;
    }
  }
}

/* ═══════ 提交按钮 ═══════ */
.submit-btn {
  width: 100%;
  height: 50px;
  margin-top: 28px;
  background: linear-gradient(135deg, #3b82f6, #6366f1);
  border: none;
  border-radius: 14px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.3);

  .submit-btn-content {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: white;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 6px;
    position: relative;
    z-index: 1;

    .submit-arrow {
      width: 18px;
      height: 18px;
      transition: transform 0.3s ease;
    }
  }

  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 30px rgba(59, 130, 246, 0.45);

    .submit-arrow {
      transform: translateX(4px);
    }
  }

  &:active:not(:disabled) {
    transform: translateY(0);
  }

  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }

  &.loading .submit-spinner {
    display: block;
    width: 22px;
    height: 22px;
    margin: 0 auto;
    border: 2.5px solid rgba(255, 255, 255, 0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
  }

  &.loading .submit-btn-content {
    display: none;
  }
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* ═══════ 快速登录 ═══════ */
.quick-login {
  margin-top: 36px;
}

.quick-label {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;

  span {
    font-size: 12px;
    color: $text-muted;
    white-space: nowrap;
  }

  .quick-line {
    flex: 1;
    height: 1px;
    background: $border-subtle;
  }
}

.quick-chips {
  display: flex;
  gap: 10px;
}

.quick-chip {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  background: #f8fafc;
  border: 1px solid $border-subtle;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.25s ease;

  &:hover {
    background: #eff6ff;
    border-color: #93c5fd;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.1);

    .chip-avatar {
      transform: scale(1.05);
    }
  }

  .chip-avatar {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
    font-weight: 700;
    color: white;
    flex-shrink: 0;
    transition: transform 0.25s ease;

    &.admin {
      background: linear-gradient(135deg, #3b82f6, #2563eb);
    }
    &.student {
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
    }
  }

  .chip-info {
    display: flex;
    flex-direction: column;
    gap: 2px;

    .chip-name {
      font-size: 13px;
      font-weight: 600;
      color: $text-primary;
    }
    .chip-pwd {
      font-size: 11px;
      color: $text-muted;
    }
  }
}

/* ═══════ 底部提示 ═══════ */
.footer-hint {
  position: absolute;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 6px;
  color: rgba(255, 255, 255, 0.3);
  font-size: 12px;
  animation: contentFadeIn 0.8s ease 0.6s forwards;
  opacity: 0;

  svg {
    opacity: 0.6;
  }
}

/* ═══════ 响应式 ═══════ */
@media (max-width: 960px) {
  .login-card {
    flex-direction: column;
    width: 92%;
    min-height: auto;
    margin: 20px;
    border-radius: 20px;
  }

  .brand-panel {
    width: 100%;
    padding: 36px 30px;

    .brand-content {
      padding: 20px;
    }

    .feature-list {
      display: none;
    }

    .brand-rings {
      display: none;
    }

    .logo-badge {
      width: 56px;
      height: 56px;
      margin-bottom: 16px;
    }

    .brand-name {
      font-size: 22px;
      margin-bottom: 12px;
    }

    .brand-desc {
      margin-bottom: 0;
      font-size: 12px;
    }
  }

  .form-panel {
    padding: 30px 28px 36px;
  }

  .footer-hint {
    position: relative;
    bottom: auto;
    margin-top: 20px;
    color: rgba(255, 255, 255, 0.25);
  }
}

@media (max-width: 480px) {
  .login-card {
    width: 95%;
    margin: 10px;
  }

  .brand-panel {
    padding: 28px 20px;
  }

  .form-panel {
    padding: 24px 20px 30px;
  }

  .quick-chips {
    flex-direction: column;
  }

  .welcome-section h2 {
    font-size: 22px;
  }
}
</style>
