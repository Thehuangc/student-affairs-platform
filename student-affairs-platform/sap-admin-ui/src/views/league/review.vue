<template>
  <div class="page-scene">
    <div class="page-header">
      <div class="header-info">
        <div class="header-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><polyline points="16 13 12 17 8 13"/></svg></div>
        <div><h1>政审备案</h1><p>管理政审材料和备案</p></div>
      </div>
    </div>
    <div class="card-container" style="margin-top: 24px;">
      <el-table :data="[]" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userName" label="申请人" />
        <el-table-column prop="reviewType" label="政审类型" />
        <el-table-column prop="status" label="状态" />
      </el-table>
    </div>
  </div>
</template>
<script setup lang="ts"></script>
<style scoped lang="scss">
.page-scene { padding: 24px; }
.page-header { padding: 28px 32px; background: linear-gradient(135deg, var(--vermillion) 0%, #e04e44 100%); border-radius: var(--radius-xl); }
.page-header .header-info { display: flex; align-items: center; gap: 16px; }
.page-header .header-icon { width: 52px; height: 52px; background: rgba(255,255,255,0.15); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; }
.page-header .header-icon svg { width: 24px; height: 24px; color: white; }
.page-header h1 { font-size: 24px; font-weight: 700; color: white; margin-bottom: 4px; }
.page-header p { font-size: 14px; color: rgba(255,255,255,0.7); }
</style>
