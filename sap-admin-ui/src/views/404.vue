<template>
  <div class="error-scene">
    <div class="error-content">
      <!-- 装饰墨迹 -->
      <div class="ink-decoration">
        <div class="ink-circle large"></div>
        <div class="ink-circle medium"></div>
        <div class="ink-circle small"></div>
      </div>

      <!-- 错误代码 -->
      <div class="error-code">
        <span class="digit" style="animation-delay: 0.1s">4</span>
        <span class="digit" style="animation-delay: 0.2s">0</span>
        <span class="digit" style="animation-delay: 0.3s">4</span>
      </div>

      <!-- 分割线 -->
      <div class="divider">
        <span class="divider-line"></span>
        <span class="divider-text">迷路了</span>
        <span class="divider-line"></span>
      </div>

      <!-- 提示信息 -->
      <p class="error-message">抱歉，您访问的页面不存在或已被移除</p>

      <!-- 返回按钮 -->
      <div class="error-actions">
        <button class="btn-home" @click="$router.push('/')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
            <polyline points="9 22 9 12 15 12 15 22" />
          </svg>
          返回首页
        </button>
        <button class="btn-back" @click="$router.back()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18">
            <line x1="19" y1="12" x2="5" y2="12" />
            <polyline points="12 19 5 12 12 5" />
          </svg>
          返回上页
        </button>
      </div>

      <!-- 诗意提示 -->
      <div class="poem-hint">
        <p>山重水复疑无路</p>
        <p>柳暗花明又一村</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped lang="scss">
.error-scene {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: var(--paper-cream);
  position: relative;
  overflow: hidden;
}

.error-content {
  text-align: center;
  position: relative;
  z-index: 1;
  padding: 40px;
}

/* ═══ 装饰墨迹 ═══ */
.ink-decoration {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 400px;
  height: 400px;
  z-index: 0;

  .ink-circle {
    position: absolute;
    border-radius: 50%;
    opacity: 0.06;

    &.large {
      width: 400px;
      height: 400px;
      background: var(--jade-deep);
      top: 0;
      left: 0;
      animation: float 8s ease-in-out infinite;
    }

    &.medium {
      width: 250px;
      height: 250px;
      background: var(--vermillion);
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      animation: float 6s ease-in-out infinite reverse;
    }

    &.small {
      width: 150px;
      height: 150px;
      background: var(--gold-accent);
      bottom: 0;
      right: 0;
      animation: float 10s ease-in-out infinite;
    }
  }
}

/* ═══ 错误代码 ═══ */
.error-code {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: 32px;
  position: relative;
  z-index: 1;

  .digit {
    font-size: 120px;
    font-weight: 800;
    color: var(--ink-deep);
    line-height: 1;
    font-family: 'Georgia', serif;
    opacity: 0;
    animation: fadeInUp 0.6s ease forwards;
    text-shadow: 4px 4px 0 rgba(42, 107, 94, 0.1);
  }
}

/* ═══ 分割线 ═══ */
.divider {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  margin-bottom: 24px;
  position: relative;
  z-index: 1;

  .divider-line {
    width: 80px;
    height: 1px;
    background: linear-gradient(90deg, transparent, var(--ink-muted), transparent);
  }

  .divider-text {
    font-size: 18px;
    color: var(--text-secondary);
    font-family: 'STKaiti', 'KaiTi', serif;
    letter-spacing: 4px;
  }
}

/* ═══ 错误信息 ═══ */
.error-message {
  font-size: 16px;
  color: var(--text-tertiary);
  margin-bottom: 40px;
  position: relative;
  z-index: 1;
}

/* ═══ 操作按钮 ═══ */
.error-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: 48px;
  position: relative;
  z-index: 1;

  button {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 14px 28px;
    border-radius: var(--radius-md);
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    transition: all var(--transition-smooth);
  }

  .btn-home {
    background: var(--jade-deep);
    color: white;
    border: none;

    &:hover {
      background: var(--jade-medium);
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(42, 107, 94, 0.3);
    }
  }

  .btn-back {
    background: transparent;
    color: var(--text-secondary);
    border: 1.5px solid var(--paper-warm);

    &:hover {
      border-color: var(--jade-light);
      color: var(--jade-deep);
      background: var(--jade-soft);
    }
  }
}

/* ═══ 诗意提示 ═══ */
.poem-hint {
  position: relative;
  z-index: 1;

  p {
    font-size: 14px;
    color: var(--text-tertiary);
    font-family: 'STKaiti', 'KaiTi', serif;
    letter-spacing: 2px;
    line-height: 2;
    opacity: 0.6;
  }
}

/* ═══ 响应式 ═══ */
@media (max-width: 768px) {
  .error-code .digit {
    font-size: 80px;
  }

  .error-actions {
    flex-direction: column;
    align-items: center;
  }
}
</style>
