<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div><h1>时长统计</h1><p>统计志愿者服务时长</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <el-table :data="[]" border>
        <el-table-column prop="userName" label="姓名" />
        <el-table-column prop="totalHours" label="累计时长" />
        <el-table-column prop="thisYearHours" label="本年度时长" />
        <el-table-column prop="level" label="等级" />
      </el-table>
    </div>
  </div>
</template>
<script setup lang="ts"></script>
<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, var(--jade-deep) 0%, var(--jade-medium) 100%); border-radius: var(--radius-xl); }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
</style>
