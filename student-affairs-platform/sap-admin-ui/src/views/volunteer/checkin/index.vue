<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg></div>
        <div><h1>签到记录</h1><p>查看志愿者签到打卡记录</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <el-table :data="[]" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userName" label="姓名" />
        <el-table-column prop="activityName" label="活动" />
        <el-table-column prop="checkInTime" label="签到时间" />
        <el-table-column prop="duration" label="时长" />
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
