<template>
  <div class="layout">
    <header class="navbar" :class="{ scrolled: scrolled }">
      <div class="navbar-inner">
        <router-link to="/" class="logo">
          <span class="logo-dot"></span>
          <span>社区论坛</span>
        </router-link>
        <nav class="nav-links">
          <router-link to="/" exact>首页</router-link>
          <router-link to="/essence">精华</router-link>
          <router-link to="/hot">热门</router-link>
          <router-link to="/qa">问答</router-link>
          <router-link to="/about">关于</router-link>
          <router-link to="/create-post" v-if="token" class="post-btn">
            <el-icon><Edit /></el-icon> 发帖
          </router-link>
        </nav>
        <div class="nav-right">
          <template v-if="token">
            <el-tooltip content="私信" placement="bottom">
              <router-link to="/messages" class="notify-btn">
                <el-badge :value="unreadMsgCount" :hidden="unreadMsgCount === 0" :max="99">
                  <el-icon :size="20"><ChatLineSquare /></el-icon>
                </el-badge>
              </router-link>
            </el-tooltip>
            <el-tooltip content="消息通知" placement="bottom">
              <router-link to="/notifications" class="notify-btn">
                <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
                  <el-icon :size="20"><Bell /></el-icon>
                </el-badge>
              </router-link>
            </el-tooltip>
            <el-dropdown @command="handleCommand" trigger="click">
              <div class="user-chip">
                <el-avatar :size="34" :src="user.avatar" />
                <span class="username">{{ user.nickname }}</span>
                <el-icon class="chevron"><ArrowDown /></el-icon>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <el-icon><User /></el-icon> 个人中心
                  </el-dropdown-item>
                  <el-dropdown-item command="admin" v-if="user.role === 'ADMIN'">
                    <el-icon><Setting /></el-icon> 后台管理
                  </el-dropdown-item>
                  <el-dropdown-item command="logout" divided>
                    <el-icon><SwitchButton /></el-icon> 退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
          <template v-else>
            <router-link to="/login" class="auth-btn">登录</router-link>
            <router-link to="/register" class="auth-btn">注册</router-link>
          </template>
        </div>
      </div>
    </header>
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="page" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
    <footer class="footer">
      <span>社区论坛 &copy; 2026</span>
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { userApi, notificationApi, messageApi } from '../api'

const router = useRouter()
const token = ref(sessionStorage.getItem('token'))
const user = ref(JSON.parse(sessionStorage.getItem('user') || '{}'))
const unreadCount = ref(0)
const unreadMsgCount = ref(0)
const scrolled = ref(false)

const fetchUnreadCount = async () => {
  if (!token.value) return
  try {
    const res = await notificationApi.getUnreadCount()
    unreadCount.value = res.data.count
  } catch (e) { /* ignore */ }
}

const fetchUnreadMsgCount = async () => {
  if (!token.value) return
  try {
    const res = await messageApi.getUnreadCount()
    unreadMsgCount.value = res.data.count
  } catch (e) { /* ignore */ }
}

const syncProfile = async () => {
  if (!token.value) return
  try {
    const res = await userApi.getProfile()
    user.value = { ...user.value, ...res.data }
    sessionStorage.setItem('user', JSON.stringify(user.value))
  } catch (e) { /* */ }
}

const handleCommand = (cmd) => {
  if (cmd === 'logout') {
    sessionStorage.clear()
    token.value = null
    user.value = {}
    router.push('/login')
  } else if (cmd === 'profile') {
    router.push('/profile')
  } else if (cmd === 'admin') {
    router.push('/admin')
  }
}

if (typeof window !== 'undefined') {
  window.addEventListener('scroll', () => { scrolled.value = window.scrollY > 10 })
}

let pollTimer = null

onMounted(() => {
  syncProfile()
  fetchUnreadCount(); fetchUnreadMsgCount()
  pollTimer = setInterval(() => { fetchUnreadCount(); fetchUnreadMsgCount() }, 10000)
})
onUnmounted(() => { if (pollTimer) clearInterval(pollTimer) })
watch(() => router.currentRoute.value, () => {
  user.value = JSON.parse(sessionStorage.getItem('user') || '{}')
  fetchUnreadCount(); fetchUnreadMsgCount()
})
</script>

<style scoped>
.layout { min-height: 100vh; display: flex; flex-direction: column; background: #f5f3ef; }
.navbar {
  position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
  height: 60px; transition: all .3s ease;
  background: rgba(255,255,255,0.85); backdrop-filter: blur(16px);
  border-bottom: 1px solid transparent;
}
.navbar.scrolled { border-bottom-color: #e8e4dd; box-shadow: 0 1px 12px rgba(0,0,0,0.04); }
.navbar-inner {
  max-width: 1120px; margin: 0 auto; padding: 0 28px;
  display: flex; align-items: center; height: 100%; gap: 32px;
}
.logo {
  display: flex; align-items: center; gap: 10px; font-size: 18px;
  font-weight: 700; color: #2c2c2c; flex-shrink: 0;
}
.logo-dot {
  width: 10px; height: 10px; border-radius: 50%;
  background: linear-gradient(135deg, #5b7fff, #8b5cf6);
}
.nav-links { display: flex; align-items: center; gap: 28px; flex: 1; }
.nav-links a {
  font-size: 14px; color: #888; font-weight: 500; transition: color .2s;
  display: flex; align-items: center; gap: 5px;
}
.nav-links a:hover { color: #5b7fff; }
.nav-links a.router-link-exact-active { color: #5b7fff; }
.nav-right { display: flex; align-items: center; gap: 18px; }
.notify-btn { color: #666; display: flex; align-items: center; padding: 4px; border-radius: 8px; transition: all .2s; position: relative; }
.notify-btn:hover { color: #5b7fff; background: #f0edf8; }
.notify-btn :deep(.el-badge__content) { font-size: 11px; font-weight: 700; }
.user-chip { display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 4px 12px 4px 4px; border-radius: 24px; transition: all .2s; }
.user-chip:hover { background: #f0edf8; }
.username { font-size: 14px; font-weight: 500; color: #333; }
.chevron { font-size: 12px; color: #999; }
.auth-btn {
  display: inline-flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 600; color: #333; background: #fff;
  border: 2px solid #e0dcd5; border-radius: 24px; padding: 6px 22px;
  transition: all .2s; min-width: 64px; text-align: center;
}
.auth-btn:hover { background: #5b7fff; border-color: #5b7fff; color: #fff; }

.main-content { flex: 1; max-width: 1120px; width: 100%; margin: 76px auto 0; padding: 0 28px 40px; }

.footer { text-align: center; padding: 24px; font-size: 12px; color: #bbb; border-top: 1px solid #ece8e0; }

.page-enter-active, .page-leave-active { transition: opacity .2s ease, transform .2s ease; }
.page-enter-from { opacity: 0; transform: translateY(6px); }
.page-leave-to { opacity: 0; transform: translateY(-6px); }

@media (max-width: 768px) {
  .navbar-inner { padding: 0 16px; gap: 16px; }
  .main-content { padding: 0 16px 40px; }
  .nav-links { gap: 16px; }
}
</style>
