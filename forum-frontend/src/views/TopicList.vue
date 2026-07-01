<template>
  <div class="topic-page">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>
    <h3 class="page-title">{{ title }}</h3>

    <div v-loading="loading" class="post-list">
      <div v-if="posts.length === 0 && !loading" class="empty-state">
        <p>暂无内容</p>
      </div>
      <article v-for="post in posts" :key="post.id" class="post-card" @click="$router.push(`/post/${post.id}`)">
        <div class="card-badges">
          <span v-if="post.isPinned" class="badge pin">置顶</span>
          <span v-if="post.isEssence" class="badge essence">精华</span>
        </div>
        <div class="card-body">
          <div class="card-left">
            <h3 class="card-title">{{ post.title }}</h3>
            <div class="card-meta">
              <el-avatar :size="22" :src="post.avatar" />
              <span>{{ post.nickname }}</span>
              <span class="dot">&middot;</span>
              <span class="time">{{ formatTime(post.createTime) }}</span>
              <span class="dot">&middot;</span>
              <span class="category-tag">{{ post.categoryName || '未分类' }}</span>
            </div>
          </div>
          <div class="card-stats">
            <span class="stat"><el-icon><View /></el-icon> {{ post.viewCount }}</span>
            <span class="stat"><el-icon><ChatDotRound /></el-icon> {{ post.commentCount }}</span>
            <span class="stat like" :class="{ liked: post.isLiked }">
              <span class="heart-icon" :class="{ liked: post.isLiked }">&#9829;</span> {{ post.likeCount }}
            </span>
          </div>
        </div>
      </article>
    </div>

    <div class="pagination" v-if="total > pageSize">
      <el-pagination background layout="prev, pager, next" :total="total"
        :page-size="pageSize" v-model:current-page="page" @current-change="fetchPosts" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { postApi } from '../api'
import { ArrowLeft, View, ChatDotRound, StarFilled, Star } from '@element-plus/icons-vue'

const props = defineProps({ mode: String })

const title = computed(() => ({ essence: '精华帖', hot: '热门帖', qa: '问答求助' }[props.mode]))
const posts = ref([]); const loading = ref(true)
const page = ref(1); const pageSize = ref(10); const total = ref(0)

const fetchPosts = async () => {
  loading.value = true
  try {
    let res
    if (props.mode === 'essence') {
      res = await postApi.getEssence({ page: page.value, size: pageSize.value })
    } else if (props.mode === 'hot') {
      res = await postApi.getList({ page: page.value, size: pageSize.value, sort: 'hot' })
    } else if (props.mode === 'qa') {
      res = await postApi.getList({ page: page.value, size: pageSize.value, categoryId: 4 })
    }
    posts.value = res.data.records || []
    total.value = res.data.total || 0
  } catch (e) { /* */ }
  loading.value = false
}

const formatTime = (t) => {
  if (!t) return ''
  const d = new Date(t); const now = new Date(); const diff = now - d
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  return t.substring(0, 10)
}

onMounted(fetchPosts)
watch(() => props.mode, () => { page.value = 1; fetchPosts() })
</script>

<style scoped>
.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
.topic-page { max-width: 800px; margin: 0 auto; }
.page-title { font-size: 20px; font-weight: 700; color: #1a1a1a; margin-bottom: 18px; }
.post-list { display: flex; flex-direction: column; gap: 12px; }
.post-card { background: #fff; border-radius: 12px; padding: 16px 20px; cursor: pointer; border: 1px solid #eee9e0; transition: all .2s; }
.post-card:hover { box-shadow: 0 2px 12px rgba(0,0,0,0.06); transform: translateY(-1px); }
.card-badges { display: flex; gap: 6px; margin-bottom: 8px; }
.badge { font-size: 11px; padding: 2px 8px; border-radius: 4px; color: #fff; font-weight: 600; }
.badge.pin { background: #f0a050; }
.badge.essence { background: #e86060; }
.card-body { display: flex; justify-content: space-between; align-items: center; }
.card-title { font-size: 16px; font-weight: 600; color: #222; margin-bottom: 6px; }
.card-meta { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #888; }
.category-tag { background: #ecf5ff; color: #5b7fff; padding: 1px 8px; border-radius: 3px; font-size: 12px; }
.card-stats { display: flex; gap: 16px; font-size: 13px; color: #aaa; }
.card-stats .stat { display: flex; align-items: center; gap: 4px; }

.heart-icon { font-size: 15px; color: #ccc; transition: color .2s; cursor: pointer; }
.heart-icon.liked { color: #e86060; }
.stat.liked { color: #e86060; }
.liked { color: #e86060; }
.empty-state { text-align: center; padding: 80px 0; color: #ccc; }
.pagination { margin-top: 20px; display: flex; justify-content: center; }
.dot { color: #ddd; }
</style>
