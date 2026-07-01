<template>
  <div class="post-detail" v-loading="loading">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>
    <div class="detail-layout">
      <div class="detail-main">
        <div class="content-card" v-if="post">
          <!-- 置顶/精华标记 -->
          <div class="top-badges">
            <span v-if="post.isPinned" class="badge pin">置顶</span>
            <span v-if="post.isEssence" class="badge essence">精华</span>
          </div>

          <h1 class="post-title">{{ post.title }}</h1>

          <div class="post-author-bar">
            <router-link :to="`/user/${post.userId}`">
              <el-avatar :size="42" :src="post.avatar" />
            </router-link>
            <div class="author-detail">
              <router-link :to="`/user/${post.userId}`" class="name">{{ post.nickname }}</router-link>
              <div class="time">{{ post.createTime }}</div>
            </div>
            <div class="actions" v-if="isOwner">
              <el-button size="small" text @click="$router.push(`/edit-post/${post.id}`)">编辑</el-button>
              <el-button size="small" text type="danger" @click="deletePost">删除</el-button>
            </div>
          </div>

          <div class="post-body" v-html="post.content"></div>

          <div class="post-engagement">
            <div class="engage-btns">
              <button class="engage-btn" :class="{ active: liked }" @click="toggleLike">
                <span class="heart-icon" :class="{ liked: liked }">&#9829;</span>
                <span>{{ post.likeCount }} 赞</span>
              </button>
              <button class="engage-btn fav-btn" :class="{ active: favorited }" @click="toggleFav">
                <el-icon :size="18"><StarFilled v-if="favorited" /><Star v-else /></el-icon>
                <span>收藏 {{ post.favCount || 0 }}</span>
              </button>
            </div>
            <div class="engage-info">
              <span class="info-item"><el-icon><View /></el-icon> {{ post.viewCount }} 浏览</span>
              <span class="info-item"><el-icon><ChatDotRound /></el-icon> {{ post.commentCount }} 评论</span>
            </div>
          </div>
        </div>

        <!-- 评论区 -->
        <div class="comment-card">
          <h3 class="section-title">评论 {{ comments.length > 0 ? '(' + commentCount + ')' : '' }}</h3>

          <div class="comment-input-box" v-if="token">
            <el-input v-model="commentText" type="textarea" :rows="3" placeholder="写下你的想法..." resize="none" />
            <div class="input-footer">
              <span class="input-hint">支持 Markdown 风格排版</span>
              <el-button type="primary" :disabled="!commentText.trim()" @click="submitComment(null)">发表评论</el-button>
            </div>
          </div>
          <div v-else class="login-prompt">
            <router-link to="/login">登录</router-link> 后参与评论
          </div>

          <div class="comment-list" v-if="comments.length > 0">
            <div v-for="(c, idx) in comments" :key="c.id" class="comment-item" :class="{ pinned: c.isPinned === 1 }">
              <router-link :to="`/user/${c.userId}`">
                <el-avatar :size="36" :src="c.avatar" />
              </router-link>
              <div class="comment-main">
                <div class="comment-top">
                  <span v-if="c.isPinned === 1" class="pin-badge">置顶</span>
                  <router-link :to="`/user/${c.userId}`" class="comment-name">{{ c.nickname }}</router-link>
                  <span class="comment-floor">#{{ getFloor(c.id) }}楼</span>
                  <span class="comment-time">{{ formatTime(c.createTime) }}</span>
                </div>
                <div class="comment-content">{{ c.content }}</div>
                <div class="comment-actions-row">
                  <button class="like-btn" :class="{ liked: c.isLiked }" @click="toggleCommentLike(c)">
                    <span class="heart-icon" :class="{ liked: c.isLiked }">&#9829;</span> {{ c.likeCount || 0 }}
                  </button>
                  <button @click="replyTo = replyTo === c.id ? null : c.id">回复</button>
                  <button v-if="isOwner && c.parentId === null" @click="togglePinComment(c)">置顶</button>
                  <button v-if="isCommentOwner(c)" class="danger" @click="deleteComment(c.id)">删除</button>
                </div>
                <div v-if="replyTo === c.id" class="reply-box">
                  <el-input v-model="replyText" :placeholder="'回复 ' + c.nickname" size="small" />
                  <div class="reply-actions">
                    <el-button size="small" @click="replyTo = null">取消</el-button>
                    <el-button size="small" type="primary" :disabled="!replyText.trim()" @click="submitComment(c.id)">回复</el-button>
                  </div>
                </div>
                <!-- 子评论 -->
                <div v-if="c.children && c.children.length" class="sub-comments">
                  <div v-for="sub in visibleChildren(c)" :key="sub.id" class="sub-comment">
                    <router-link :to="`/user/${sub.userId}`">
                      <el-avatar :size="28" :src="sub.avatar" />
                    </router-link>
                    <div class="comment-main">
                      <div class="comment-top">
                        <router-link :to="`/user/${sub.userId}`" class="comment-name">{{ sub.nickname }}</router-link>
                        <span class="comment-time">{{ formatTime(sub.createTime) }}</span>
                      </div>
                      <div class="comment-content">{{ sub.content }}</div>
                      <div class="comment-actions-row">
                        <button @click="replyTo = replyTo === sub.id ? null : sub.id">回复</button>
                        <button v-if="isCommentOwner(sub)" class="danger" @click="deleteComment(sub.id)">删除</button>
                      </div>
                    </div>
                    <div v-if="replyTo === sub.id" class="reply-box">
                      <el-input v-model="replyText" :placeholder="'回复 ' + sub.nickname" size="small" />
                      <div class="reply-actions">
                        <el-button size="small" @click="replyTo = null">取消</el-button>
                        <el-button size="small" type="primary" :disabled="!replyText.trim()" @click="submitComment(sub.id)">回复</el-button>
                      </div>
                    </div>
                  </div>
                  <div class="expand-row" v-if="c.children.length > 3">
                    <button v-if="getVisibleCount(c.id) < c.children.length" @click="showMore(c.id)">展开更多 ({{ c.children.length - getVisibleCount(c.id) }}条)</button>
                    <button v-if="getVisibleCount(c.id) > 3" @click="showLess(c.id)">收起</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 侧边栏 -->
      <aside class="detail-sidebar">
        <div class="side-card author-profile">
          <router-link :to="`/user/${post.userId}`">
            <el-avatar :size="64" :src="post.avatar" />
          </router-link>
          <router-link :to="`/user/${post.userId}`" class="author-name-link">
            <h4>{{ post.nickname }}</h4>
          </router-link>
          <p>发布了 {{ post.viewCount || 0 }} 次浏览的帖子</p>
        </div>
        <div class="side-card">
          <h4>相关帖子</h4>
          <p class="placeholder-text">同类帖子推荐功能开发中...</p>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { postApi, commentApi, likeApi, favoriteApi } from '../api'
import { ElMessage, ElMessageBox } from 'element-plus'
import { StarFilled, Star, View, ChatDotRound, ArrowLeft } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const post = ref({})
const comments = ref([])
const loading = ref(true)
const liked = ref(false)
const favorited = ref(false)
const token = ref(sessionStorage.getItem('token'))
const currentUser = ref(JSON.parse(sessionStorage.getItem('user') || '{}'))
const commentText = ref('')
const replyText = ref('')
const replyTo = ref(null)
const isOwner = ref(false)
const expandedCounts = ref({})

const getVisibleCount = (cid) => expandedCounts.value[cid] || 3
const visibleChildren = (c) => c.children ? c.children.slice(0, getVisibleCount(c.id)) : []
const showMore = (cid) => { expandedCounts.value[cid] = getVisibleCount(cid) + 10 }
const showLess = (cid) => { expandedCounts.value[cid] = Math.max(3, getVisibleCount(cid) - 10) }

const commentCount = computed(() => {
  let total = 0
  const count = (list) => {
    for (const c of list) { total++; if (c.children) count(c.children) }
  }
  count(comments.value)
  return total
})

const isCommentOwner = (c) => currentUser.value.id == c.userId

const toggleCommentLike = async (c) => {
  if (!token.value) { router.push('/login'); return }
  try {
    const res = await commentApi.toggleLike(c.id)
    c.isLiked = res.data.liked
    c.likeCount = (c.likeCount || 0) + (res.data.liked ? 1 : -1)
  } catch (e) { /* */ }
}

const floorMap = computed(() => {
  const allIds = []
  const walk = (list) => { for (const c of list) { allIds.push(c); if (c.children) walk(c.children) } }
  walk(comments.value)
  allIds.sort((a, b) => new Date(a.createTime) - new Date(b.createTime))
  const map = {}
  allIds.forEach((c, i) => { map[c.id] = i + 1 })
  return map
})
const getFloor = (id) => floorMap.value[id] || '?'

const togglePinComment = async (c) => {
  try {
    await commentApi.togglePin(c.id, post.value.id)
    c.isPinned = c.isPinned === 1 ? 0 : 1
    await fetchComments()
  } catch (e) { /* */ }
}

const toggleFav = async () => {
  if (!token.value) { router.push('/login'); return }
  try {
    const res = await favoriteApi.toggle(post.value.id)
    favorited.value = res.data.favorited
    post.value.favCount = (post.value.favCount || 0) + (res.data.favorited ? 1 : -1)
  } catch (e) { /* */ }
}

const fetchPost = async () => {
  loading.value = true
  try {
    const res = await postApi.getDetail(route.params.id)
    post.value = res.data
    isOwner.value = currentUser.value.id == post.value.userId
    liked.value = post.value.isLiked || false
    favorited.value = post.value.isFavorited || false
  } catch (e) { router.push('/') }
  loading.value = false
}

const fetchComments = async () => {
  try { const res = await commentApi.getByPost(route.params.id); comments.value = res.data } catch (e) { /* */ }
}

const toggleLike = async () => {
  if (!token.value) { router.push('/login'); return }
  try {
    const res = await likeApi.toggle(post.value.id)
    liked.value = res.data.liked
    post.value.likeCount += liked.value ? 1 : -1
  } catch (e) { /* */ }
}

const submitComment = async (parentId) => {
  const text = parentId ? replyText.value : commentText.value
  if (!text.trim()) return
  try {
    await commentApi.create({ content: text, postId: post.value.id, parentId: parentId || undefined })
    if (parentId) { replyText.value = ''; replyTo.value = null } else { commentText.value = '' }
    ElMessage.success('评论成功')
    fetchComments()
    fetchPost()
  } catch (e) { /* */ }
}

const deleteComment = async (id) => {
  try { await commentApi.delete(id); ElMessage.success('已删除'); fetchComments(); fetchPost() } catch (e) { /* */ }
}

const deletePost = async () => {
  try {
    await ElMessageBox.confirm('确定删除该帖子？此操作不可撤销。', '删除确认', { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' })
    await postApi.delete(post.value.id)
    ElMessage.success('删除成功')
    router.push('/')
  } catch (e) { /* */ }
}

const formatTime = (t) => {
  if (!t) return ''
  const d = new Date(t); const now = new Date(); const diff = now - d
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  return t.substring(0, 10)
}

onMounted(() => {
  if (!sessionStorage.getItem('token')) {
    ElMessage({ message: '登录后获得更好的体验', type: 'info', duration: 2000 })
  }
  fetchPost(); fetchComments()
})
</script>

<style scoped>
.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }

.detail-layout { display: flex; gap: 28px; align-items: flex-start; }
.detail-main { flex: 1; min-width: 0; }
.content-card {
  background: #fff; border-radius: 16px; padding: 28px 32px;
  border: 1px solid #eee9e0; position: relative;
}
.top-badges { display: flex; gap: 8px; margin-bottom: 12px; }
.badge { font-size: 12px; padding: 4px 12px; border-radius: 6px; color: #fff; font-weight: 600; }
.badge.pin { background: #f0a050; }
.badge.essence { background: #e86060; }
.post-title { font-size: 26px; font-weight: 800; color: #1a1a1a; line-height: 1.35; margin-bottom: 20px; }
.post-author-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #f3efe8; }
.post-author-bar a { display: flex; align-items: center; }
.author-detail { flex: 1; }
.author-detail .name { font-size: 14px; font-weight: 600; color: #5b7fff; text-decoration: none; }
.author-detail .name:hover { text-decoration: underline; color: #4a6aee; }
.author-detail .time { font-size: 12px; color: #aaa; margin-top: 2px; }
.post-body { font-size: 15px; line-height: 1.9; color: #333; }
.post-body :deep(img) { max-width: 100%; border-radius: 10px; margin: 12px 0; }
.post-body :deep(pre) { background: #f7f5f0; padding: 16px; border-radius: 10px; overflow-x: auto; font-size: 13px; line-height: 1.6; }
.post-body :deep(blockquote) { border-left: 3px solid #5b7fff; padding-left: 16px; color: #666; margin: 12px 0; }
.post-engagement {
  display: flex; align-items: center; justify-content: space-between;
  margin-top: 28px; padding-top: 20px; border-top: 1px solid #f3efe8;
}
.engage-btns { display: flex; gap: 10px; }

.heart-icon { font-size: 15px; color: #ccc; transition: color .2s; cursor: pointer; }
.heart-icon.liked { color: #e86060; }
.stat.liked { color: #e86060; }
.engage-btn {
  display: flex; align-items: center; gap: 8px; padding: 10px 24px;
  border-radius: 24px; border: 2px solid #e8e4dd; background: #fff;
  font-size: 14px; color: #888; cursor: pointer; font-weight: 600;
  transition: all .2s; font-family: inherit;
}
.engage-btn:hover { border-color: #ffb3b3; color: #e86060; }
.engage-btn.active { background: #fff0f0; border-color: #ff6b6b; color: #e86060; }
.fav-btn:hover { border-color: #e8c870; color: #c8960a; }
.fav-btn.active { background: #fffaf0; border-color: #f0c040; color: #e8a800; }
.engage-info { display: flex; gap: 20px; }
.info-item { display: flex; align-items: center; gap: 5px; font-size: 13px; color: #bbb; }

.comment-card {
  background: #fff; border-radius: 16px; padding: 24px 32px;
  margin-top: 16px; border: 1px solid #eee9e0;
}
.section-title { font-size: 17px; font-weight: 700; color: #1a1a1a; margin-bottom: 20px; }
.comment-input-box { margin-bottom: 24px; }
.input-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 10px; }
.input-hint { font-size: 12px; color: #ccc; }
.login-prompt { text-align: center; padding: 28px; color: #aaa; font-size: 14px; background: #faf9f6; border-radius: 12px; }
.login-prompt a { color: #5b7fff; font-weight: 600; }

.comment-item { display: flex; gap: 12px; padding: 16px 0; border-bottom: 1px solid #f5f1ea; }
.comment-item:last-child { border-bottom: none; }
.comment-main { flex: 1; min-width: 0; }
.comment-top { margin-bottom: 6px; }
.comment-name { font-size: 13px; font-weight: 600; color: #5b7fff; margin-right: 10px; text-decoration: none; }
.comment-floor { font-size: 12px; color: #ccc; margin-right: 10px; font-weight: 500; }
.expand-row { margin-top: 8px; display: flex; gap: 12px; }
.expand-row button { background: none; border: none; font-size: 13px; color: #5b7fff; cursor: pointer; padding: 0; font-family: inherit; font-weight: 500; }
.expand-row button:hover { color: #4a6aee; text-decoration: underline; }
.comment-item.pinned { background: #fffdf0; border-radius: 10px; padding: 10px; border: 1px solid #f0d060; }
.pin-badge { font-size: 11px; padding: 2px 8px; border-radius: 4px; background: #f0a050; color: #fff; font-weight: 600; margin-right: 8px; }
.like-btn { background: none; border: none; font-size: 13px; color: #bbb; cursor: pointer; padding: 0 5px; font-family: inherit; transition: color .2s; }
.like-btn .heart-icon { font-size: 14px; margin-right: 2px; }
.like-btn .heart-icon.liked, .like-btn.liked { color: #e86060; }
.comment-name:hover { text-decoration: underline; color: #4a6aee; }
.comment-time { font-size: 12px; color: #ccc; }
.comment-content { font-size: 14px; color: #444; line-height: 1.7; }
.comment-actions-row { margin-top: 6px; }
.comment-actions-row button { background: none; border: none; font-size: 12px; color: #aaa; cursor: pointer; padding: 0; margin-right: 14px; font-family: inherit; }
.comment-actions-row button:hover { color: #5b7fff; }
.comment-actions-row button.danger:hover { color: #e86060; }

.reply-box { margin-top: 10px; }
.reply-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 6px; }

.sub-comments { margin-top: 10px; padding: 10px 0 10px 16px; background: #faf9f6; border-radius: 10px; border-left: 2px solid #e8e4dd; }
.sub-comment { display: flex; gap: 10px; padding: 8px 0; }

.detail-sidebar { width: 260px; flex-shrink: 0; position: sticky; top: 80px; display: flex; flex-direction: column; gap: 16px; }
.author-profile { text-align: center; }
.author-name-link { text-decoration: none; }
.author-profile h4 { font-size: 16px; margin-top: 12px; margin-bottom: 4px; color: #5b7fff; }
.author-profile h4:hover { text-decoration: underline; }
.author-profile p { font-size: 13px; color: #aaa; }
.side-card { background: #fff; border-radius: 14px; padding: 20px; border: 1px solid #eee9e0; }
.side-card h4 { font-size: 14px; font-weight: 700; margin-bottom: 12px; color: #1a1a1a; }
.placeholder-text { font-size: 13px; color: #ccc; }

@media (max-width: 860px) { .detail-sidebar { display: none; } }
</style>
