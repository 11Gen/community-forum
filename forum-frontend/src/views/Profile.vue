<template>
  <div class="profile" v-loading="loading">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>

    <div class="profile-header-card">
      <div class="profile-bg"></div>
      <div class="profile-info">
        <el-avatar :size="80" :src="profile.avatar" class="avatar" />
        <div class="info-text">
          <h2>{{ profile.nickname }}</h2>
          <p class="sig">{{ profile.signature || '这个用户还没有写签名...' }}</p>
        </div>
        <div class="follow-stats">
          <div class="stat-item" @click="showFollowers = true;fetchFollowers()">
            <strong>{{ stats.followerCount ?? 0 }}</strong>
            <span>关注者</span>
          </div>
          <div class="stat-item" @click="showFollowing = true;fetchFollowing()">
            <strong>{{ stats.followingCount ?? 0 }}</strong>
            <span>正在关注</span>
          </div>
        </div>
        <div class="header-actions">
          <el-button round @click="editMode = true">编辑资料</el-button>
          <el-button round @click="openSecurityQuestions">
            <el-icon><Lock /></el-icon> 密保问题
          </el-button>
          <el-button round @click="$router.push('/messages')">
            <el-icon><ChatLineSquare /></el-icon> 私信
          </el-button>
        </div>
      </div>
    </div>

    <el-tabs v-model="activeTab" class="profile-tabs">
      <el-tab-pane label="我的帖子" name="posts">
        <div class="my-list">
          <div v-if="myPosts.length === 0" class="empty">还没有发布过帖子</div>
          <div v-for="p in myPosts" :key="p.id" class="my-post-card" @click="$router.push(`/post/${p.id}`)">
            <div>
              <div class="my-post-title">{{ p.title }}</div>
              <div class="my-post-meta">{{ p.viewCount }} 浏览 &middot; {{ p.likeCount }} 赞 &middot; {{ p.commentCount }} 评论</div>
            </div>
            <span class="my-post-date">{{ formatDate(p.createTime) }}</span>
          </div>
        </div>
      </el-tab-pane>
      <el-tab-pane label="我的关注" name="following" @tab-click="fetchFollowing">
        <div class="my-list">
          <div v-if="followingList.length === 0" class="empty">暂未关注任何人</div>
          <div v-for="f in followingList" :key="f.userId" class="follow-card" @click="$router.push(`/user/${f.followUserId}`)">
            <el-avatar :size="44" :src="f.avatar" />
            <div class="follow-info">
              <span class="follow-nick">{{ f.nickname }}</span>
              <button class="unfollow-btn" @click.stop="unfollowUser(f.userId)">取消关注</button>
            </div>
          </div>
        </div>
      </el-tab-pane>
      <el-tab-pane label="我的粉丝" name="followers" @tab-click="fetchFollowers">
        <div class="my-list">
          <div v-if="followersList.length === 0" class="empty">暂无粉丝</div>
          <div v-for="f in followersList" :key="f.userId" class="follow-card" @click="$router.push(`/user/${f.userId}`)">
            <el-avatar :size="44" :src="f.avatar" />
            <span class="follow-nick">{{ f.nickname }}</span>
          </div>
        </div>
          </el-tab-pane>
      <el-tab-pane label="收藏" name="favs" @tab-click="fetchFavorites">
        <div class="my-list">
          <div v-if="favPosts.length === 0" class="empty">还没有收藏过帖子</div>
          <div v-for="p in favPosts" :key="p.id" class="my-post-card"
            :class="{ deleted: p.title === '该帖子内容已失效' }"
            @click="p.title !== '该帖子内容已失效' && $router.push('/post/' + p.id)">
            <div>
              <div class="my-post-title">{{ p.title }}</div>
              <div class="my-post-meta">{{ p.nickname || '未知' }} &middot; {{ p.viewCount || 0 }} 浏览 &middot; {{ p.likeCount || 0 }} 赞</div>
            </div>
            <span class="my-post-date">{{ formatDate(p.createTime) }}</span>
          </div>
        </div>
      </el-tab-pane>
      <el-tab-pane label="浏览历史" name="history" @tab-click="fetchHistory">
        <div class="my-list">
          <div v-if="historyList.length === 0" class="empty">还没有浏览记录</div>
          <div v-for="h in historyList" :key="h.id" class="my-post-card"
            :class="{ deleted: h.postStatus === 1 }"
            @click="h.postStatus !== 1 && $router.push('/post/'+h.postId)">
            <div>
              <div class="my-post-title">{{ h.postTitle }}</div>
              <div class="my-post-meta">{{ formatDate(h.createTime) }}</div>
            </div>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="showSecurity" title="设置密保问题" width="480px" :close-on-click-modal="false">
      <p style="font-size:13px;color:#999;margin-bottom:16px">设置3个密保问题，用于找回密码。请牢记你的答案。</p>
      <div v-for="(q, idx) in sqList" :key="idx" style="margin-bottom:14px">
        <p style="font-size:13px;font-weight:600;color:#333;margin-bottom:4px">问题{{ idx+1 }}</p>
        <el-input v-model="q.question" placeholder="请输入密保问题" size="default" style="margin-bottom:6px" />
        <el-input v-model="q.answer" placeholder="请输入答案" size="default" />
      </div>
      <template #footer>
        <el-button @click="showSecurity = false">取消</el-button>
        <el-button type="primary" :loading="savingSq" @click="saveSecurityQuestions">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showFollowers" title="关注者" width="380px">
      <div v-if="followersList.length === 0" class="empty-dialog">暂无关注者</div>
      <div v-for="f in followersList" :key="f.userId" class="follow-row" @click="$router.push(`/user/${f.userId}`);showFollowers=false">
        <el-avatar :size="36" :src="f.avatar" />
        <span class="follow-name">{{ f.nickname }}</span>
      </div>
    </el-dialog>

    <el-dialog v-model="showFollowing" title="正在关注" width="380px">
      <div v-if="followingList.length === 0" class="empty-dialog">暂未关注任何人</div>
      <div v-for="f in followingList" :key="f.userId" class="follow-row" @click="$router.push(`/user/${f.followUserId}`);showFollowing=false">
        <el-avatar :size="36" :src="f.avatar" />
        <span class="follow-name">{{ f.nickname }}</span>
      </div>
    </el-dialog>

    <el-dialog v-model="editMode" title="编辑个人资料" width="440px" :close-on-click-modal="false">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="昵称">
          <el-input v-model="editForm.nickname" placeholder="2-20个字符" maxlength="20" />
        </el-form-item>
        <el-form-item label="个性签名">
          <el-input v-model="editForm.signature" type="textarea" :rows="3" maxlength="200" show-word-limit />
        </el-form-item>
        <el-form-item label="手机">
          <el-input v-model="editForm.phone" placeholder="手机号（可选）" maxlength="11" />
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="editForm.gender" placeholder="请选择" style="width:100%">
            <el-option label="男" :value="0" />
            <el-option label="女" :value="1" />
            <el-option label="私密" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" disabled placeholder="邮箱地址" />
        </el-form-item>
        <el-form-item label="头像">
          <div style="display:flex;align-items:center;gap:16px">
            <el-avatar :size="60" :src="avatarPreview" />
            <el-upload :auto-upload="false" :show-file-list="false" :on-change="handleAvatarChange" accept="image/*">
              <el-button size="small">选择新头像</el-button>
            </el-upload>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editMode = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="saveProfile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { userApi, postApi, followApi, favoriteApi, historyApi } from '../api'
import { ElMessage } from 'element-plus'
import { ChatLineSquare, ArrowLeft, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const profile = ref({}); const myPosts = ref([]); const loading = ref(true)
const activeTab = ref('posts'); const editMode = ref(false); const saving = ref(false)
const editForm = ref({ nickname: '', signature: '', phone: '', gender: '', email: '' }); const avatarPreview = ref('')
const avatarFile = ref(null)
const stats = ref({ followerCount: 0, followingCount: 0 })
const followersList = ref([]); const followingList = ref([])
const showFollowers = ref(false); const showFollowing = ref(false)
const showSecurity = ref(false); const savingSq = ref(false)
const favPosts = ref([]); const historyList = ref([])
const sqList = ref([{ question: '', answer: '' }, { question: '', answer: '' }, { question: '', answer: '' }])

const openSecurityQuestions = async () => {
  try {
    const res = await userApi.getSecurityQuestions(profile.value.id)
    if (res.data && res.data.length > 0) {
      sqList.value = res.data.map(q => ({ question: q.question, answer: '' }))
      sqList.value.forEach(q => { q.answer = '' })
    }
  } catch (e) { /* */ }
  showSecurity.value = true
}

const saveSecurityQuestions = async () => {
  for (const q of sqList.value) {
    if (!q.question.trim() || !q.answer.trim()) {
      ElMessage.error('请完整填写3个密保问题和答案')
      return
    }
  }
  savingSq.value = true
  try {
    await userApi.saveSecurityQuestions(sqList.value)
    ElMessage.success('密保问题保存成功')
    showSecurity.value = false
  } catch (e) { /* */ }
  savingSq.value = false
}

const fetchProfile = async () => {
  try {
    const res = await userApi.getProfile(); profile.value = res.data
    editForm.value.nickname = res.data.nickname || ''
    editForm.value.signature = res.data.signature || ''
    editForm.value.phone = res.data.phone || ''
    editForm.value.gender = res.data.gender ?? 2
    editForm.value.email = res.data.email || ''
    avatarPreview.value = res.data.avatar
  } catch (e) { /* */ }
  loading.value = false
}

const fetchMyPosts = async () => {
  try {
    const res = await postApi.search({ keyword: '', page: 1, size: 50 })
    myPosts.value = res.data.records.filter(p => p.userId == profile.value.id)
  } catch (e) { /* */ }
}

const fetchStats = async () => {
  try { const res = await followApi.stats(profile.value.id); stats.value = res.data } catch (e) { /* */ }
}

const fetchFollowers = async () => {
  try {
    const res = await followApi.followers(profile.value.id)
    followersList.value = res.data || []
  } catch (e) { /* */ }
}

const fetchFollowing = async () => {
  try {
    const res = await followApi.following(profile.value.id)
    followingList.value = res.data || []
  } catch (e) { /* */ }
}

const unfollowUser = async (userId) => {
  try {
    await followApi.unfollow(userId)
    followingList.value = followingList.value.filter(f => f.userId !== userId)
    stats.value.followingCount = Math.max(0, (stats.value.followingCount || 1) - 1)
    ElMessage.success('已取消关注')
  } catch (e) { /* */ }
}

const handleAvatarChange = (file) => { avatarFile.value = file.raw; avatarPreview.value = URL.createObjectURL(file.raw) }

const saveProfile = async () => {
  saving.value = true
  try {
    await userApi.updateProfile({
      nickname: editForm.value.nickname,
      signature: editForm.value.signature,
      phone: editForm.value.phone,
      gender: editForm.value.gender
    })
    if (avatarFile.value) {
      const avatarRes = await userApi.uploadAvatar(avatarFile.value)
      profile.value.avatar = avatarRes.data.url
    }
    const user = JSON.parse(sessionStorage.getItem('user') || '{}')
    user.nickname = editForm.value.nickname
    user.avatar = profile.value.avatar
    sessionStorage.setItem('user', JSON.stringify(user))
    ElMessage.success('保存成功'); editMode.value = false; fetchProfile()
  } catch (e) { /* */ }
  saving.value = false
}

const formatDate = (t) => t ? t.substring(0, 10) : ''

const fetchFavorites = async () => {
  try {
    const res = await favoriteApi.list({ page: 1, size: 50 })
    favPosts.value = res.data.records || []
  } catch (e) { /* */ }
}

const fetchHistory = async () => {
  try {
    const res = await historyApi.list({ page: 1, size: 50 })
    historyList.value = res.data.records || []
  } catch (e) { /* */ }
}

onMounted(async () => {
  await fetchProfile()
  fetchMyPosts()
  fetchFavorites()
  fetchHistory()
  fetchStats()
  fetchFollowers()
  fetchFollowing()
})
</script>

<style scoped>
.profile { max-width: 820px; margin: 0 auto; }
.profile-header-card { background: #fff; border-radius: 16px; overflow: hidden; border: 1px solid #eee9e0; }
.profile-bg { height: 80px; background: linear-gradient(135deg, #e8e4f0, #d5cef4, #c4b8f0); }
.profile-info { padding: 0 28px 28px; display: flex; align-items: flex-end; gap: 20px; margin-top: -40px; flex-wrap: wrap; }
.avatar { border: 4px solid #fff; box-shadow: 0 4px 16px rgba(0,0,0,0.08); flex-shrink: 0; }
.info-text { flex: 1; padding-bottom: 4px; min-width: 160px; }
.info-text h2 { font-size: 22px; font-weight: 700; color: #1a1a1a; margin-bottom: 2px; }
.sig { font-size: 14px; color: #666; font-style: italic; }

.follow-stats { display: flex; gap: 24px; padding-bottom: 4px; }
.stat-item { text-align: center; cursor: pointer; transition: all .15s; }
.stat-item:hover strong { color: #5b7fff; }
.stat-item strong { display: block; font-size: 18px; font-weight: 700; color: #333; transition: color .15s; }
.stat-item span { font-size: 12px; color: #aaa; }

.header-actions { display: flex; gap: 10px; align-items: flex-end; }

.profile-tabs { margin-top: 20px; }
.my-list { display: flex; flex-direction: column; gap: 8px; }
.my-post-card { background: #fff; border-radius: 12px; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; cursor: pointer; border: 1px solid #eee9e0; transition: all .2s; }
.my-post-card:hover { border-color: #d5cef4; transform: translateX(4px); }
.my-post-title { font-size: 15px; font-weight: 600; color: #333; margin-bottom: 4px; }
.my-post-meta { font-size: 12px; color: #bbb; }
.my-post-date { font-size: 12px; color: #ccc; flex-shrink: 0; }

.follow-card {
  display: flex; align-items: center; gap: 14px; padding: 14px 16px;
  background: #fff; border-radius: 12px; border: 1px solid #eee9e0;
  cursor: pointer; transition: all .2s;
}
.follow-card:hover { border-color: #d5cef4; transform: translateX(4px); }
.follow-info { flex: 1; display: flex; align-items: center; justify-content: space-between; }
.follow-nick { font-size: 15px; font-weight: 600; color: #333; }
.unfollow-btn {
  background: none; border: 1px solid #e0dcd5; border-radius: 16px; padding: 4px 14px;
  font-size: 12px; color: #888; cursor: pointer; font-family: inherit; transition: all .15s;
}
.unfollow-btn:hover { border-color: #ff6b6b; color: #ff6b6b; }

.my-post-card.deleted { opacity: 0.5; cursor: default; }
.my-post-card.deleted:hover { transform: none; border-color: #eee9e0; }
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
  .profile-info { flex-direction: column; align-items: flex-start; }
  .header-actions { width: 100%; }
}

.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
</style>
