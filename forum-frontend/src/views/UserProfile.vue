<template>
  <div class="user-profile" v-loading="loading">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>

    <div class="profile-card">
      <div class="profile-bg"></div>
      <div class="profile-body">
        <div class="avatar-area">
          <el-avatar :size="96" :src="userInfo.avatar" class="avatar" />
        </div>
        <div class="info-area">
          <h2 class="nickname">{{ userInfo.nickname }}</h2>
          <p class="signature">{{ userInfo.signature || '这个用户还没有写签名...' }}</p>
          <p class="gender" v-if="userInfo.gender !== undefined && userInfo.gender !== 2">
            <span class="gender-tag">{{ userInfo.gender === 0 ? '男' : '女' }}</span>
          </p>
        </div>
        <div class="follow-stats">
          <div class="stat-item" @click="showFollowers = true">
            <strong>{{ stats.followerCount ?? 0 }}</strong>
            <span>关注者</span>
          </div>
          <div class="stat-item" @click="showFollowing = true">
            <strong>{{ stats.followingCount ?? 0 }}</strong>
            <span>正在关注</span>
          </div>
        </div>
        <div class="action-buttons">
          <el-button
            v-if="!isSelf"
            :type="isFollowing ? 'default' : 'primary'"
            round
            @click="toggleFollow"
            :loading="followLoading"
          >
            {{ isFollowing ? '已关注' : '关注' }}
          </el-button>
          <el-button
            v-if="!isSelf"
            type="default"
            round
            @click="goToMessages"
          >
            发私信
          </el-button>
        </div>
      </div>
    </div>

    <div class="posts-section">
      <h3>{{ isSelf ? '我的' : 'TA的' }}帖子</h3>
      <div v-if="userPosts.length === 0" class="empty">还没有发布过帖子</div>
      <div v-for="p in userPosts" :key="p.id" class="post-card" @click="$router.push(`/post/${p.id}`)">
        <div>
          <div class="post-title">{{ p.title }}</div>
          <div class="post-meta">{{ p.viewCount }} 浏览 &middot; {{ p.likeCount }} 赞 &middot; {{ p.commentCount }} 评论</div>
        </div>
        <span class="post-date">{{ formatDate(p.createTime) }}</span>
      </div>
    </div>

    <!-- Followers Dialog -->
    <el-dialog v-model="showFollowers" title="关注者" width="380px">
      <div v-if="followersList.length === 0" class="empty-dialog">暂无关注者</div>
      <div v-for="f in followersList" :key="f.id" class="follow-row" @click="$router.push(`/user/${f.id}`); showFollowers=false">
        <el-avatar :size="36" :src="f.avatar" />
        <span class="follow-name">{{ f.nickname }}</span>
      </div>
    </el-dialog>

    <!-- Following Dialog -->
    <el-dialog v-model="showFollowing" title="正在关注" width="380px">
      <div v-if="followingList.length === 0" class="empty-dialog">暂未关注任何人</div>
      <div v-for="f in followingList" :key="f.id" class="follow-row" @click="$router.push(`/user/${f.id}`); showFollowing=false">
        <el-avatar :size="36" :src="f.avatar" />
        <span class="follow-name">{{ f.nickname }}</span>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { userApi, followApi, postApi } from '../api'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userId = Number(route.params.id)
const currentUser = JSON.parse(sessionStorage.getItem('user') || '{}')
const isSelf = currentUser.id === userId

const loading = ref(true)
const userInfo = ref({})
const stats = ref({})
const isFollowing = ref(false)
const isMutualFollow = ref(false)
const followLoading = ref(false)
const userPosts = ref([])

const showFollowers = ref(false)
const showFollowing = ref(false)
const followersList = ref([])
const followingList = ref([])

const fetchUserProfile = async () => {
  loading.value = true
  try {
    const res = await userApi.getUser(userId)
    userInfo.value = res.data
  } catch (e) { /* */ }
  loading.value = false
}

const fetchStats = async () => {
  try {
    const res = await followApi.stats(userId)
    stats.value = res.data
  } catch (e) { /* */ }
}

const fetchFollowStatus = async () => {
  if (isSelf) return
  try {
    const res = await followApi.check(userId)
    isFollowing.value = res.data.following || false
    isMutualFollow.value = res.data.mutual || false
  } catch (e) { /* */ }
}

const fetchUserPosts = async () => {
  try {
    const res = await postApi.search({ keyword: '', page: 1, size: 50 })
    userPosts.value = res.data.records.filter(p => p.userId == userId)
  } catch (e) { /* */ }
}

const fetchFollowers = async () => {
  try {
    const res = await followApi.followers(userId)
    followersList.value = res.data || []
  } catch (e) { /* */ }
}

const fetchFollowing = async () => {
  try {
    const res = await followApi.following(userId)
    followingList.value = res.data || []
  } catch (e) { /* */ }
}

const toggleFollow = async () => {
  if (!sessionStorage.getItem('token')) { router.push('/login'); return }
  followLoading.value = true
  try {
    if (isFollowing.value) {
      await followApi.unfollow(userId)
      isFollowing.value = false
      isMutualFollow.value = false
      stats.value.followerCount = Math.max(0, (stats.value.followerCount || 1) - 1)
      ElMessage.success('已取消关注')
    } else {
      await followApi.follow(userId)
      isFollowing.value = true
      stats.value.followerCount = (stats.value.followerCount || 0) + 1
      ElMessage.success('关注成功')
    }
  } catch (e) { /* */ }
  followLoading.value = false
}

const goToMessages = () => {
  router.push(`/messages/${userId}`)
}

const formatDate = (t) => t ? t.substring(0, 10) : ''

onMounted(() => {
  fetchUserProfile()
  fetchStats()
  fetchFollowStatus()
  fetchUserPosts()
  fetchFollowers()
  fetchFollowing()
})
</script>

<style scoped>
.user-profile { max-width: 800px; margin: 0 auto; }
.profile-card { background: #fff; border-radius: 16px; overflow: hidden; border: 1px solid #eee9e0; }
.profile-bg { height: 100px; background: linear-gradient(135deg, #e8e4f0, #d5cef4, #c4b8f0); }
.profile-body { padding: 0 32px 28px; display: flex; flex-wrap: wrap; align-items: flex-end; gap: 24px; margin-top: -48px; }
.avatar-area { flex-shrink: 0; }
.avatar { border: 5px solid #fff; box-shadow: 0 4px 16px rgba(0,0,0,0.1); }
.info-area { flex: 1; min-width: 200px; padding-bottom: 4px; }
.nickname { font-size: 24px; font-weight: 700; color: #1a1a1a; margin-bottom: 4px; }
.signature { font-size: 14px; color: #888; font-style: italic; margin-bottom: 6px; }
.gender-tag { font-size: 12px; padding: 2px 10px; border-radius: 10px; background: #f0edf8; color: #7c6ff7; font-weight: 500; }
.follow-stats { display: flex; gap: 24px; padding-bottom: 4px; }
.stat-item { text-align: center; cursor: pointer; transition: all .15s; }
.stat-item:hover strong { color: #5b7fff; }
.stat-item strong { display: block; font-size: 18px; font-weight: 700; color: #333; transition: color .15s; }
.stat-item span { font-size: 12px; color: #aaa; }
.action-buttons { display: flex; gap: 10px; align-items: flex-end; }

.posts-section { margin-top: 24px; }
.posts-section h3 { font-size: 17px; font-weight: 700; color: #1a1a1a; margin-bottom: 14px; }
.post-card { background: #fff; border-radius: 12px; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; cursor: pointer; border: 1px solid #eee9e0; transition: all .2s; margin-bottom: 8px; }
.post-card:hover { border-color: #d5cef4; transform: translateX(4px); }
.post-title { font-size: 15px; font-weight: 600; color: #333; margin-bottom: 4px; }
.post-meta { font-size: 12px; color: #bbb; }
.post-date { font-size: 12px; color: #ccc; flex-shrink: 0; }
.empty { text-align: center; padding: 60px 20px; color: #ccc; font-size: 14px; }
.empty-dialog { text-align: center; padding: 40px 20px; color: #ccc; font-size: 14px; }

.follow-row {
  display: flex; align-items: center; gap: 12px; padding: 10px 4px;
  cursor: pointer; border-radius: 10px; transition: all .15s;
}
.follow-row:hover { background: #faf9f6; }
.follow-row + .follow-row { border-top: 1px solid #f5f1ea; }
.follow-name { font-size: 14px; font-weight: 500; color: #333; }

@media (max-width: 640px) {
  .profile-body { flex-direction: column; align-items: flex-start; }
  .action-buttons { width: 100%; }
}

.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
</style>
