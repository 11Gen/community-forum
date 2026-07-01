<template>
  <div class="home">
    <div class="home-layout">
      <div class="main-area">
        <!-- 搜索栏 -->
        <div class="search-bar" ref="searchRef">
          <el-input v-model="keyword" placeholder="搜索你感兴趣的话题..." size="large"
            clearable @focus="showDropdown = true" @keyup.enter="doSearch" @clear="doSearch"
            :prefix-icon="Search" class="search-input" />
          <div class="search-dropdown" v-if="showDropdown">
            <div class="dropdown-section" v-if="searchHistory.length > 0">
              <div class="dropdown-header">
                <span>搜索历史</span>
                <button @click="clearHistory">清除</button>
              </div>
              <span class="history-tag" v-for="h in searchHistory" :key="h" @click="keyword=h;doSearch()">{{ h }}</span>
            </div>
            <div class="dropdown-section">
              <div class="dropdown-header"><span>热门搜索</span></div>
              <div class="hot-item" v-for="(item, idx) in hotKeywords" :key="item.keyword" @click="keyword=item.keyword;doSearch()">
                <span class="hot-rank" :class="'rank-'+(idx+1)">{{ idx+1 }}</span>
                <span>{{ item.keyword }}</span>
                <span class="hot-count">{{ item.count }}次</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 分类 + 排序 -->
        <div class="toolbar">
          <div class="categories">
            <button
              v-for="cat in [{id:null,name:'全部'}, ...categories]"
              :key="cat.id ?? 'all'"
              :class="{ active: activeCategory === cat.id }"
              @click="changeCategory(cat.id)"
            >{{ cat.name }}</button>
          </div>
          <div class="sort-group">
            <button v-for="s in sorts" :key="s.value"
              :class="{ active: sort === s.value }"
              @click="sort = s.value; fetchPosts()"
            >{{ s.label }}</button>
          </div>
        </div>

        <!-- 帖子列表 -->
        <div v-loading="loading" class="post-list">
          <div v-if="posts.length === 0 && !loading" class="empty-state">
            <div class="empty-icon"><el-icon :size="48"><Document /></el-icon></div>
            <p>暂无帖子</p>
            <span>成为第一个发帖的人吧</span>
          </div>
          <article v-for="post in posts" :key="post.id" class="post-card"
            @click="$router.push(`/post/${post.id}`)">
            <div class="card-badges">
              <span v-if="post.isPinned" class="badge pin">置顶</span>
              <span v-if="post.isEssence" class="badge essence">精华</span>
            </div>
            <div class="card-body">
              <div class="card-left">
                <h3 class="card-title">{{ post.title }}</h3>
                <div class="card-meta">
                  <div class="author-chip">
                    <el-avatar :size="22" :src="post.avatar" />
                    <span>{{ post.nickname }}</span>
                  </div>
                  <span class="dot">&middot;</span>
                  <span class="time">{{ formatTime(post.createTime) }}</span>
                  <span class="dot">&middot;</span>
                  <span class="category-tag" :class="catColor(post.categoryName)">{{ post.categoryName || '未分类' }}</span>
                </div>
              </div>
              <div class="card-stats">
                <span class="stat"><el-icon><View /></el-icon> {{ formatNum(post.viewCount) }}</span>
                <span class="stat"><el-icon><ChatDotRound /></el-icon> {{ formatNum(post.commentCount) }}</span>
                <span class="stat like" :class="{ liked: post.isLiked }">
                  <span class="heart-icon" :class="{ liked: post.isLiked }">&#9829;</span> {{ formatNum(post.likeCount) }}
                </span>
                <span class="stat fav"
                  :class="{ faved: post.isFavorited, 'has-other': !post.isFavorited && post.favCount > 0 }"
                  @click.stop="toggleFav(post)">
                  <el-icon><StarFilled v-if="post.isFavorited || post.favCount > 0" /><Star v-else /></el-icon> {{ post.favCount || 0 }}
                </span>
              </div>
            </div>
          </article>
        </div>

        <!-- 分页 -->
        <div class="pagination" v-if="total > pageSize">
          <el-pagination background layout="prev, pager, next" :total="total"
            :page-size="pageSize" v-model:current-page="page"
            @current-change="fetchPosts" />
        </div>
      </div>

      <!-- 侧边栏 -->
      <aside class="sidebar">
        <div class="side-card">
          <h4 class="side-title">热门帖子</h4>
          <div class="hot-list">
            <div v-for="(p, idx) in hotPosts" :key="p.id" class="hot-item"
              @click="$router.push(`/post/${p.id}`)">
              <span class="hot-rank" :class="'rank-' + (idx + 1)">{{ idx + 1 }}</span>
              <div class="hot-info">
                <div class="hot-title">{{ p.title }}</div>
                <div class="hot-meta">{{ p.likeCount }} 赞 &middot; {{ p.commentCount }} 评论</div>
              </div>
            </div>
          </div>
        </div>
        <div class="side-card">
          <h4 class="side-title">关于社区</h4>
          <p class="about-text">这是一个开放、友好的技术交流与生活分享社区。欢迎大家在这里畅所欲言，分享知识与见解。</p>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { postApi, categoryApi, searchApi, favoriteApi } from '../api'
import { Search, Document, View, ChatDotRound, StarFilled, Star } from '@element-plus/icons-vue'

const posts = ref([])
const hotPosts = ref([])
const categories = ref([])
const loading = ref(false)
const keyword = ref('')
const sort = ref('recommended')
const activeCategory = ref(null)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const showDropdown = ref(false)
const hotKeywords = ref([])
const searchHistory = ref([])
const searchRef = ref(null)

const sorts = [
  { label: '推荐', value: 'recommended' },
  { label: '最新', value: 'latest' },
  { label: '最热', value: 'hot' },
  { label: '最多浏览', value: 'views' },
]

const fetchPosts = async () => {
  loading.value = true
  try {
    const api = sort.value === 'recommended' ? postApi.getRecommended : postApi.getList
    const res = await api({ page: page.value, size: pageSize.value, categoryId: activeCategory.value, sort: sort.value })
    posts.value = res.data.records
    total.value = res.data.total
  } catch (e) { /* */ }
  loading.value = false
}

const fetchHotPosts = async () => {
  try {
    const res = await postApi.getList({ page: 1, size: 5, sort: 'hot' })
    hotPosts.value = res.data.records
  } catch (e) { /* */ }
}

const doSearch = async () => {
  showDropdown.value = false
  if (!keyword.value.trim()) { fetchPosts(); return }
  loading.value = true
  try {
    const res = await postApi.search({ keyword: keyword.value, page: page.value, size: pageSize.value })
    posts.value = res.data.records; total.value = res.data.total
    if (sessionStorage.getItem('token')) {
      try {
        await searchApi.record(keyword.value)
        const historyRes = await searchApi.getHistory()
        searchHistory.value = (historyRes.data || []).map(h => h.keyword || h)
      } catch (e) { /* */ }
    }
  } catch (e) { /* */ }
  loading.value = false
}

const fetchSearchData = async () => {
  try {
    const hotRes = await searchApi.getHot()
    hotKeywords.value = hotRes.data || []
  } catch (e) { /* */ }
  if (sessionStorage.getItem('token')) {
    try {
      const histRes = await searchApi.getHistory()
      searchHistory.value = (histRes.data || []).map(h => h.keyword || h)
    } catch (e) { /* */ }
  }
}

const clearHistory = async () => {
  try {
    await searchApi.clearHistory()
    searchHistory.value = []
  } catch (e) { /* */ }
}

const toggleFav = async (post) => {
  if (!sessionStorage.getItem('token')) return
  try {
    const res = await favoriteApi.toggle(post.id)
    post.isFavorited = res.data.favorited
    post.favCount = (post.favCount || 0) + (res.data.favorited ? 1 : -1)
  } catch (e) { /* */ }
}

const catColor = (name) => {
  const map = { '技术交流': 'tech', '生活杂谈': 'life', '资源分享': 'share', '问答求助': 'qa', '公告通知': 'notice' }
  return map[name] || ''
}

const changeCategory = (catId) => { activeCategory.value = catId; page.value = 1; fetchPosts() }

const handleClickOutside = (e) => {
  if (searchRef.value && !searchRef.value.contains(e.target)) {
    showDropdown.value = false
  }
}

const formatTime = (t) => {
  if (!t) return ''
  const d = new Date(t); const now = new Date(); const diff = now - d
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  if (diff < 604800000) return Math.floor(diff / 86400000) + '天前'
  return t.substring(0, 10)
}

const formatNum = (n) => {
  if (n >= 10000) return (n / 10000).toFixed(1) + 'w'
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k'
  return n
}

onMounted(() => {
  categoryApi.getList().then(res => categories.value = res.data)
  fetchPosts()
  fetchHotPosts()
  fetchSearchData()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.home-layout { display: flex; gap: 28px; align-items: flex-start; }
.main-area { flex: 1; min-width: 0; }
.search-input { --el-input-border-radius: 12px; }
.search-bar { margin-bottom: 20px; position: relative; }

.search-dropdown {
  position: absolute; top: 100%; left: 0; right: 0; z-index: 200;
  background: #fff; border-radius: 12px; margin-top: 6px;
  box-shadow: 0 8px 30px rgba(0,0,0,0.1), 0 1px 3px rgba(0,0,0,0.06);
  border: 1px solid #eee9e0; padding: 16px; max-height: 380px; overflow-y: auto;
}
.dropdown-section { margin-bottom: 16px; }
.dropdown-section:last-child { margin-bottom: 0; }
.dropdown-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 10px; font-size: 13px; font-weight: 600; color: #888;
}
.dropdown-header button {
  background: none; border: none; color: #aaa; font-size: 12px;
  cursor: pointer; font-family: inherit;
}
.dropdown-header button:hover { color: #e86060; }
.history-tag {
  display: inline-block; padding: 4px 12px; margin: 0 6px 6px 0;
  background: #f5f3ef; border-radius: 14px; font-size: 12px;
  color: #666; cursor: pointer; transition: all .15s;
}
.history-tag:hover { background: #e8e4f0; color: #5b7fff; }
.hot-item {
  display: flex; align-items: center; gap: 10px; padding: 8px 0;
  cursor: pointer; transition: all .15s; border-bottom: 1px solid #f5f1ea;
}
.hot-item:last-child { border-bottom: none; }
.hot-item:hover { color: #5b7fff; }
.hot-rank { width: 20px; height: 20px; border-radius: 6px; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; background: #f0ece4; color: #999; flex-shrink: 0; }
.hot-rank.rank-1 { background: linear-gradient(135deg, #ff6b6b, #ff8e53); color: #fff; }
.hot-rank.rank-2 { background: linear-gradient(135deg, #ff8e53, #ffb347); color: #fff; }
.hot-rank.rank-3 { background: linear-gradient(135deg, #ffb347, #ffcc02); color: #fff; }
.hot-count { font-size: 11px; color: #ccc; margin-left: auto; }

.toolbar { display: flex; flex-direction: column; align-items: flex-start; margin-bottom: 20px; gap: 10px; }
.categories, .sort-group { display: flex; gap: 6px; flex-wrap: wrap; }
.categories button, .sort-group button {
  padding: 6px 16px; border-radius: 20px; font-size: 13px; cursor: pointer;
  border: 1px solid #e0dcd5; background: #fff; color: #777; font-weight: 500;
  transition: all .2s; font-family: inherit;
}
.categories button:hover, .sort-group button:hover { border-color: #c4b8f0; color: #5b7fff; }
.categories button.active, .sort-group button.active {
  background: linear-gradient(135deg, #5b7fff, #7c6ff7); color: #fff; border-color: transparent;
}

.post-list { display: flex; flex-direction: column; gap: 10px; }
.post-card {
  background: #fff; border-radius: 14px; padding: 20px 24px;
  cursor: pointer; transition: all .25s ease;
  border: 1px solid #eee9e0; position: relative; overflow: hidden;
}
.post-card:hover { transform: translateY(-2px); box-shadow: 0 8px 30px rgba(0,0,0,0.08); border-color: #d5cef4; }
.card-badges { position: absolute; top: 0; right: 20px; display: flex; gap: 6px; }
.badge { font-size: 11px; padding: 3px 10px; border-radius: 0 0 6px 6px; color: #fff; font-weight: 600; }
.badge.pin { background: #f0a050; }
.badge.essence { background: #e86060; }
.card-body { display: flex; justify-content: space-between; align-items: center; gap: 20px; }
.card-left { flex: 1; min-width: 0; }
.card-title { font-size: 16px; font-weight: 600; color: #1a1a1a; margin-bottom: 10px; line-height: 1.4; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.card-meta { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #aaa; }
.author-chip { display: flex; align-items: center; gap: 6px; }
.author-chip span { color: #666; font-weight: 500; }
.dot { color: #ddd; }
.category-tag { padding: 2px 10px; border-radius: 10px; font-size: 12px; font-weight: 500; background: #f4f0ff; color: #7c6ff7; }
.category-tag.tech { background: #e3f2fd; color: #1976d2; }
.category-tag.life { background: #e8f5e9; color: #388e3c; }
.category-tag.share { background: #fff3e0; color: #f57c00; }
.category-tag.qa { background: #fce4ec; color: #c62828; }
.category-tag.notice { background: #f3e5f5; color: #7b1fa2; }
.card-stats { display: flex; gap: 18px; flex-shrink: 0; }
.stat { display: flex; align-items: center; gap: 5px; font-size: 13px; color: #bbb; }
.heart-icon { font-size: 15px; color: #ccc; transition: color .2s; cursor: pointer; }
.heart-icon.liked { color: #e86060; }
.stat.like.liked { color: #e86060; }
.stat.fav { color: #ccc; cursor: pointer; transition: color .2s; }
.stat.fav.has-other { color: #888; }
.stat.fav.faved { color: #f0a050; }

.empty-state { text-align: center; padding: 80px 20px; color: #ccc; }
.empty-icon { margin-bottom: 12px; color: #ddd; }
.empty-state p { font-size: 16px; margin-bottom: 4px; color: #aaa; }
.empty-state span { font-size: 13px; color: #ccc; }

.pagination { margin-top: 28px; display: flex; justify-content: center; }

.sidebar { width: 280px; flex-shrink: 0; position: sticky; top: 80px; display: flex; flex-direction: column; gap: 16px; }
.side-card { background: #fff; border-radius: 14px; padding: 20px; border: 1px solid #eee9e0; }
.side-title { font-size: 15px; font-weight: 700; color: #1a1a1a; margin-bottom: 14px; }
.hot-item { display: flex; gap: 10px; padding: 10px 0; border-bottom: 1px solid #f5f1ea; cursor: pointer; align-items: flex-start; transition: all .15s; }
.hot-item:last-child { border-bottom: none; }
.hot-item:hover .hot-title { color: #5b7fff; }
.hot-rank { width: 20px; height: 20px; border-radius: 6px; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; background: #f0ece4; color: #999; flex-shrink: 0; margin-top: 2px; }
.hot-rank.rank-1 { background: linear-gradient(135deg, #ff6b6b, #ff8e53); color: #fff; }
.hot-rank.rank-2 { background: linear-gradient(135deg, #ff8e53, #ffb347); color: #fff; }
.hot-rank.rank-3 { background: linear-gradient(135deg, #ffb347, #ffcc02); color: #fff; }
.hot-info { flex: 1; min-width: 0; }
.hot-title { font-size: 13px; color: #444; line-height: 1.4; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; transition: color .15s; }
.hot-meta { font-size: 11px; color: #ccc; margin-top: 3px; }
.about-text { font-size: 13px; color: #888; line-height: 1.8; }

@media (max-width: 860px) {
  .sidebar { display: none; }
  .card-stats { display: none; }
}
</style>
