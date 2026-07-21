<template>
  <div class="login-scene">
    <!-- ═══ 背景层：宣纸纹理 + 墨迹 ═══ -->
    <div class="bg-layer">
      <div class="paper-texture"></div>
      <div class="ink-splash ink-1"></div>
      <div class="ink-splash ink-2"></div>
      <div class="ink-splash ink-3"></div>
      <div class="mountain-silhouette"></div>
    </div>

    <!-- ═══ 主体：登录卡片 ═══ -->
    <div class="login-main">
      <!-- 左侧：装饰区 -->
      <div class="decor-panel">
        <div class="decor-content">
          <div class="seal-stamp">
            <span>学</span>
          </div>
          <h1 class="brand-title">
            <span class="char" style="animation-delay: 0.1s">学</span>
            <span class="char" style="animation-delay: 0.2s">生</span>
            <span class="char" style="animation-delay: 0.3s">综</span>
            <span class="char" style="animation-delay: 0.4s">合</span>
            <span class="char" style="animation-delay: 0.5s">事</span>
            <span class="char" style="animation-delay: 0.6s">务</span>
            <span class="char" style="animation-delay: 0.7s">中</span>
            <span class="char" style="animation-delay: 0.8s">台</span>
          </h1>
          <div class="divider-line"></div>
          <p class="subtitle">Student Affairs Platform</p>
          <div class="poem-block">
            <p>博学之</p>
            <p>审问之</p>
            <p>慎思之</p>
            <p>明辨之</p>
            <p>笃行之</p>
          </div>
        </div>
        <!-- 装饰几何 -->
        <div class="geo-pattern top-right"></div>
        <div class="geo-pattern bottom-left"></div>
      </div>

      <!-- 右侧：表单区 -->
      <div class="form-panel">
        <div class="form-content">
          <div class="form-header">
            <h2>欢迎回来</h2>
            <p>请登录您的账号</p>
          </div>

          <el-form
            ref="loginFormRef"
            :model="loginForm"
            :rules="loginRules"
            class="login-form"
            size="large"
          >
            <el-form-item prop="username">
              <div class="input-wrapper">
                <div class="input-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                    <circle cx="12" cy="7" r="4" />
                  </svg>
                </div>
                <el-input
                  v-model="loginForm.username"
                  placeholder="请输入用户名"
                  :prefix-icon="undefined"
                />
              </div>
            </el-form-item>

            <el-form-item prop="password">
              <div class="input-wrapper">
                <div class="input-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                  </svg>
                </div>
                <el-input
                  v-model="loginForm.password"
                  type="password"
                  placeholder="请输入密码"
                  show-password
                  @keyup.enter="handleLogin"
                />
              </div>
            </el-form-item>

            <el-form-item>
              <button
                class="login-btn"
                :class="{ loading: loading }"
                @click.prevent="handleLogin"
                :disabled="loading"
              >
                <span class="btn-text">{{ loading ? '登录中...' : '登 录' }}</span>
                <span class="btn-loader"></span>
              </button>
            </el-form-item>
          </el-form>

          <div class="form-footer">
            <div class="hint-accounts">
              <span class="hint-label">测试账号</span>
              <div class="account-chips">
                <span class="chip" @click="fillAccount('admin', 'admin123')">管理员</span>
                <span class="chip" @click="fillAccount('student', 'admin123')">学生</span>
                <span class="chip" @click="fillAccount('teacher', 'admin123')">教师</span>
              </div>
            </div>
          </div>
        </div>
      </div>
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
.login-scene {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: var(--ink-deep);
  position: relative;
  overflow: hidden;
}

/* ═══ 背景层 ═══ */
.bg-layer {
  position: absolute;
  inset: 0;
  z-index: 0;

  .paper-texture {
    position: absolute;
    inset: 0;
    background:
      radial-gradient(ellipse at 20% 50%, rgba(247, 243, 236, 0.03) 0%, transparent 50%),
      radial-gradient(ellipse at 80% 50%, rgba(247, 243, 236, 0.02) 0%, transparent 50%);
  }

  .ink-splash {
    position: absolute;
    border-radius: 50%;
    filter: blur(80px);
    opacity: 0.15;

    &.ink-1 {
      width: 600px;
      height: 600px;
      background: var(--jade-deep);
      top: -200px;
      left: -100px;
      animation: float 20s ease-in-out infinite;
    }
    &.ink-2 {
      width: 400px;
      height: 400px;
      background: var(--vermillion);
      bottom: -150px;
      right: -100px;
      animation: float 25s ease-in-out infinite reverse;
    }
    &.ink-3 {
      width: 300px;
      height: 300px;
      background: var(--gold-accent);
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      animation: float 30s ease-in-out infinite;
    }
  }

  .mountain-silhouette {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 200px;
    background: linear-gradient(180deg, transparent 0%, rgba(26, 31, 22, 0.5) 100%);
    clip-path: polygon(0 100%, 5% 70%, 15% 85%, 25% 60%, 35% 75%, 45% 50%, 55% 65%, 65% 45%, 75% 60%, 85% 40%, 95% 55%, 100% 100%);
  }
}

/* ═══ 主体卡片 ═══ */
.login-main {
  position: relative;
  z-index: 1;
  display: flex;
  width: 900px;
  min-height: 560px;
  border-radius: var(--radius-xl);
  overflow: hidden;
  box-shadow: 0 40px 100px rgba(0, 0, 0, 0.5);
  animation: scaleIn 0.8s var(--transition-spring) forwards;
}

/* ═══ 左侧装饰面板 ═══ */
.decor-panel {
  position: relative;
  width: 380px;
  background: linear-gradient(135deg, var(--jade-deep) 0%, var(--ink-medium) 100%);
  padding: 60px 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    inset: 0;
    background:
      url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.03'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
  }

  .decor-content {
    position: relative;
    z-index: 1;
    text-align: center;
    color: var(--text-inverse);
  }

  .seal-stamp {
    width: 72px;
    height: 72px;
    border: 2px solid var(--vermillion);
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 30px;
    transform: rotate(-5deg);
    animation: fadeIn 1s ease forwards;

    span {
      font-size: 36px;
      font-weight: 700;
      color: var(--vermillion);
      font-family: 'STKaiti', 'KaiTi', serif;
    }
  }

  .brand-title {
    font-size: 36px;
    font-weight: 700;
    letter-spacing: 8px;
    margin-bottom: 16px;
    font-family: 'STKaiti', 'KaiTi', 'Noto Serif SC', serif;

    .char {
      display: inline-block;
      opacity: 0;
      animation: fadeInUp 0.6s ease forwards;
    }
  }

  .divider-line {
    width: 60px;
    height: 2px;
    background: var(--gold-accent);
    margin: 0 auto 16px;
    animation: brushStroke 1s ease 0.5s forwards;
    clip-path: inset(0 100% 0 0);
  }

  .subtitle {
    font-size: 13px;
    letter-spacing: 3px;
    text-transform: uppercase;
    opacity: 0.6;
    margin-bottom: 40px;
    font-family: 'Georgia', serif;
  }

  .poem-block {
    p {
      font-size: 16px;
      letter-spacing: 6px;
      line-height: 2.2;
      opacity: 0.5;
      font-family: 'STKaiti', 'KaiTi', serif;
    }
  }

  .geo-pattern {
    position: absolute;
    width: 120px;
    height: 120px;
    border: 1px solid rgba(201, 169, 78, 0.15);
    border-radius: 50%;

    &.top-right {
      top: -40px;
      right: -40px;
    }
    &.bottom-left {
      bottom: -40px;
      left: -40px;
    }
  }
}

/* ═══ 右侧表单面板 ═══ */
.form-panel {
  flex: 1;
  background: var(--paper-white);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 50px;

  .form-content {
    width: 100%;
    max-width: 340px;
    animation: fadeInUp 0.8s ease 0.3s forwards;
    opacity: 0;
  }

  .form-header {
    margin-bottom: 40px;

    h2 {
      font-size: 28px;
      font-weight: 700;
      color: var(--ink-deep);
      margin-bottom: 8px;
      font-family: 'Noto Serif SC', serif;
    }
    p {
      font-size: 14px;
      color: var(--text-tertiary);
    }
  }
}

/* ═══ 输入框样式 ═══ */
.input-wrapper {
  position: relative;
  width: 100%;

  .input-icon {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    width: 18px;
    height: 18px;
    color: var(--ink-muted);
    z-index: 1;
    transition: color var(--transition-fast);

    svg {
      width: 100%;
      height: 100%;
    }
  }

  :deep(.el-input__wrapper) {
    padding-left: 42px;
    background: var(--paper-cream);
    border: 1.5px solid transparent;
    border-radius: var(--radius-md);
    box-shadow: none;
    transition: all var(--transition-smooth);

    &:hover {
      border-color: var(--jade-light);
      background: var(--paper-white);
    }

    &.is-focus {
      border-color: var(--jade-deep);
      background: var(--paper-white);
      box-shadow: 0 0 0 3px var(--jade-soft);
    }
  }
}

.input-wrapper:focus-within .input-icon {
  color: var(--jade-deep);
}

/* ═══ 登录按钮 ═══ */
.login-btn {
  width: 100%;
  height: 48px;
  background: linear-gradient(135deg, var(--jade-deep) 0%, var(--jade-medium) 100%);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 8px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: all var(--transition-smooth);
  font-family: 'Noto Serif SC', serif;

  &::before {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, var(--vermillion) 0%, var(--vermillion-glow) 100%);
    opacity: 0;
    transition: opacity var(--transition-smooth);
  }

  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(42, 107, 94, 0.4);

    &::before {
      opacity: 1;
    }
  }

  &:active:not(:disabled) {
    transform: translateY(0);
  }

  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }

  .btn-text {
    position: relative;
    z-index: 1;
  }

  .btn-loader {
    display: none;
  }

  &.loading {
    .btn-text {
      opacity: 0;
    }
    .btn-loader {
      display: block;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 24px;
      height: 24px;
      border: 2px solid rgba(255, 255, 255, 0.3);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
  }
}

@keyframes spin {
  to { transform: translate(-50%, -50%) rotate(360deg); }
}

/* ═══ 底部提示 ═══ */
.form-footer {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid var(--paper-warm);

  .hint-accounts {
    text-align: center;

    .hint-label {
      display: block;
      font-size: 12px;
      color: var(--text-tertiary);
      margin-bottom: 10px;
    }

    .account-chips {
      display: flex;
      justify-content: center;
      gap: 8px;
    }

    .chip {
      padding: 6px 16px;
      background: var(--paper-cream);
      border: 1px solid var(--paper-warm);
      border-radius: 20px;
      font-size: 12px;
      color: var(--text-secondary);
      cursor: pointer;
      transition: all var(--transition-fast);

      &:hover {
        background: var(--jade-soft);
        border-color: var(--jade-light);
        color: var(--jade-deep);
        transform: translateY(-1px);
      }
    }
  }
}

/* ═══ 响应式 ═══ */
@media (max-width: 768px) {
  .login-main {
    flex-direction: column;
    width: 92%;
    min-height: auto;
    margin: 20px;
  }

  .decor-panel {
    width: 100%;
    padding: 40px 30px;

    .brand-title {
      font-size: 28px;
      letter-spacing: 4px;
    }

    .poem-block {
      display: none;
    }
  }

  .form-panel {
    padding: 40px 30px;
  }
}
</style>
