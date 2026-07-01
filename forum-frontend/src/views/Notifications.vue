<template>
  <div class="notifications">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>
    <div class="notif-card">
      <div class="notif-header">
        <h2>消息通知</h2>
        <span class="count-badge" v-if="unreadTotal > 0">{{ unreadTotal }} 条未读</span>
      </div>
      <div v-if="list.length === 0" class="empty">
        <el-icon :size="40"><Bell /></el-icon>
        <p>暂无通知</p>
      </div>
      <div v-for="n in list" :key="n.id" class="notif-item" :class="{ unread: n.isRead === 0 }" @click="handleClick(n)">
        <div class="notif-dot" v-if="n.isRead === 0"></div>
        <div class="notif-body">
          <div class="notif-text">{{ n.content }}</div>
          <div class="notif-meta">
            <span class="notif-type">{{ typeLabel(n.type) }}</span>
            <span>{{ formatTime(n.createTime) }}</span>
          </div>
        </div>
        <el-icon class="notif-arrow"><ArrowRight /></el-icon>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { notificationApi } from '../api'
import { Bell, ArrowRight, ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter(); const list = ref([])
const unreadTotal = computed(() => list.value.filter(n => n.isRead === 0).length)

const fetchList = async () => {
  try { const res = await notificationApi.getList(); list.value = res.data } catch (e) { /* */ }
}

const handleClick = async (n) => {
  if (n.isRead === 0) { await notificationApi.markRead(n.id); n.isRead = 1 }
  if (n.targetId) router.push(`/post/${n.targetId}`)
}

const typeLabel = (t) => ({ COMMENT: '评论', LIKE: '点赞', FOLLOW: '关注', FAVORITE: '收藏', COMMENT_LIKE: '评论点赞', SYSTEM: '系统' }[t] || t)
const formatTime = (t) => {
  if (!t) return ''; const d = new Date(t); const now = new Date(); const diff = now - d
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  return t.substring(0, 10)
}

onMounted(async () => {
  await fetchList()
  await notificationApi.markAllRead().catch(() => {})
})
</script>

<style scoped>
.notifications { max-width: 700px; margin: 0 auto; }
.notif-card { background: #fff; border-radius: 16px; padding: 24px 28px; border: 1px solid #eee9e0; }
.notif-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
.notif-header h2 { font-size: 18px; font-weight: 700; color: #1a1a1a; }
.count-badge { font-size: 12px; background: #fff0f0; color: #e86060; padding: 4px 12px; border-radius: 12px; font-weight: 600; }
.empty { text-align: center; padding: 60px 20px; color: #ddd; }
.empty p { margin-top: 8px; font-size: 14px; color: #ccc; }
.notif-item {
  display: flex; align-items: center; gap: 12px; padding: 14px 12px;
  border-radius: 10px; cursor: pointer; transition: all .15s;
}
.notif-item:hover { background: #faf9f6; }
.notif-item + .notif-item { border-top: 1px solid #f5f1ea; }
.notif-item.unread { background: #f8f7ff; }
.notif-item.unread:hover { background: #f0edf8; }
.notif-dot { width: 8px; height: 8px; border-radius: 50%; background: #5b7fff; flex-shrink: 0; }
.notif-body { flex: 1; }
.notif-text { font-size: 14px; color: #333; line-height: 1.5; margin-bottom: 4px; }
.notif-meta { display: flex; gap: 10px; font-size: 12px; color: #bbb; }
.notif-type { color: #5b7fff; font-weight: 500; }
.notif-arrow { color: #ccc; flex-shrink: 0; }

.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
</style>
