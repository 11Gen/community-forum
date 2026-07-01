<template>
  <div class="messages-page">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>

    <div class="messages-layout">
      <!-- 左侧对话列表 -->
      <div class="conversation-panel">
        <div class="panel-header">
          <h3>私信</h3>
        </div>
        <div class="conversation-list" v-if="conversations.length > 0">
          <div
            v-for="conv in conversations"
            :key="conv.userId"
            class="conv-item"
            :class="{ active: activeUserId === conv.userId }"
            @click="selectConversation(conv.userId)"
          >
            <el-avatar :size="42" :src="conv.avatar" />
            <div class="conv-info">
              <div class="conv-top">
                <span class="conv-name">{{ conv.nickname }}</span>
                <span class="conv-time">{{ formatTime(conv.lastMessageTime) }}</span>
              </div>
              <div class="conv-preview">
                <span class="conv-text">{{ conv.lastMessage || '暂无消息' }}</span>
                <el-badge v-if="conv.unreadCount > 0" :value="conv.unreadCount" :max="99" />
              </div>
            </div>
          </div>
        </div>
        <div v-else class="empty-conv">
          <p>暂无对话</p>
          <span>去用户主页发起私信吧</span>
        </div>
      </div>

      <!-- 右侧聊天区域 -->
      <div class="chat-panel">
        <template v-if="activeUserId">
          <div class="chat-header">
            <el-avatar :size="36" :src="activeUser.avatar" />
            <div>
              <span class="chat-name">{{ activeUser.nickname }}</span>
              <span v-if="!isMutualFollow" class="limit-warning">在对方关注或者回复你之前，只能发送一条消息</span>
            </div>
          </div>

          <div class="chat-messages" ref="chatRef">
            <div v-if="messages.length === 0" class="empty-chat">
              <p>暂无消息</p>
              <span>发送一条消息开始对话吧</span>
            </div>
            <template v-for="msg in messages" :key="msg._key">
              <div v-if="!msg._local && msg.isRecalled === 1" class="recall-notice">
                <span>{{ msg.content }}</span>
              </div>
              <div v-else
                class="msg-row"
                :class="{ mine: msg._local || msg.senderId === currentUser.id }"
              >
                <el-avatar v-if="!msg._local && msg.senderId !== currentUser.id" :size="34" :src="msg.senderAvatar" />
                <div class="msg-bubble" :class="{ mine: msg._local || msg.senderId === currentUser.id }"
                  @contextmenu.prevent="showCtx($event, msg)">
                  <div class="msg-content">{{ msg.content }}</div>
                  <div class="msg-time">{{ msg._local ? formatTime(new Date().toISOString()) : formatTime(msg.createTime) }}</div>
                </div>
                <div v-if="msg._local" class="msg-status">
                  <el-tooltip v-if="msg._failed" content="发送失败：对方尚未回复，无法继续发送" placement="top">
                    <span class="fail-icon">!</span>
                  </el-tooltip>
                  <el-icon v-else class="sending-icon"><Loading /></el-icon>
                </div>
                <el-avatar v-if="!msg._local && msg.senderId === currentUser.id" :size="34" :src="msg.senderAvatar" />
              </div>
            </template>
          </div>

          <div class="ctx-menu" v-if="ctx.visible" :style="{ top: ctx.y+'px', left: ctx.x+'px' }">
            <button v-if="!ctx.msg._local" @click="recallMsg(ctx.msg); ctx.visible=false">撤回</button>
            <button @click="deleteMsg(ctx.msg); ctx.visible=false">删除</button>
          </div>

          <div class="chat-input">
            <el-input
              v-model="inputText"
              type="textarea"
              :rows="2"
              placeholder="输入消息..."
              resize="none"
              @keyup.enter.exact="sendMessage"
            />
            <el-button type="primary" :disabled="!inputText.trim()" @click="sendMessage" class="send-btn">
              发送
            </el-button>
          </div>
        </template>
        <template v-else>
          <div class="no-chat">
            <el-icon :size="48"><ChatLineSquare /></el-icon>
            <p>选择一个对话</p>
            <span>从左侧列表选择要聊天的用户</span>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { userApi, messageApi, followApi } from '../api'
import { ElMessage } from 'element-plus'
import { ChatLineSquare, ArrowLeft } from '@element-plus/icons-vue'

const route = useRoute()
const currentUser = JSON.parse(sessionStorage.getItem('user') || '{}')

const conversations = ref([])
const activeUserId = ref(null)
const activeUser = ref({})
const messages = ref([])
const inputText = ref('')
const chatRef = ref(null)
const isMutualFollow = ref(false)
const ctx = ref({ visible: false, x: 0, y: 0, msg: null })

let pollTimer = null

const fetchConversations = async () => {
  try {
    const res = await messageApi.getConversations()
    conversations.value = res.data || []
  } catch (e) { /* */ }
}

const fetchMessages = async () => {
  if (!activeUserId.value) return
  try {
    const res = await messageApi.getConversation(activeUserId.value)
    // Preserve local failed messages (not sent to server)
    const key = 'failed_msgs_' + activeUserId.value
    const saved = JSON.parse(sessionStorage.getItem(key) || '[]')
    const failedMsgs = [...saved, ...messages.value.filter(m => m._failed)]
    // Deduplicate by _key
    const seen = new Set()
    const unique = failedMsgs.filter(m => { if (seen.has(m._key)) return false; seen.add(m._key); return true })
    sessionStorage.setItem(key, JSON.stringify(unique))
    const all = [...(res.data || []), ...unique]
    all.sort((a, b) => {
      const ta = a._local ? Number(a._key.replace('local_', '')) : new Date(a.createTime).getTime()
      const tb = b._local ? Number(b._key.replace('local_', '')) : new Date(b.createTime).getTime()
      return ta - tb
    })
    messages.value = all
    for (const msg of messages.value) {
      if (msg.isRead === 0 && !msg._local && msg.senderId !== currentUser.id) {
        try { await messageApi.markRead(msg.id) } catch (e) { /* */ }
      }
    }
    await nextTick()
    scrollToBottom()
  } catch (e) { /* */ }
}

const checkMutual = async () => {
  if (!activeUserId.value) return
  try {
    const res = await followApi.check(activeUserId.value)
    isMutualFollow.value = res.data.mutual || false
  } catch (e) { /* */ }
}

const selectConversation = async (userId) => {
  activeUserId.value = userId
  const conv = conversations.value.find(c => c.userId === userId)
  if (conv) {
    activeUser.value = { nickname: conv.nickname, avatar: conv.avatar }
  } else {
    try {
      const res = await userApi.getUser(userId)
      activeUser.value = { nickname: res.data.nickname, avatar: res.data.avatar }
    } catch (e) { /* */ }
  }
  fetchMessages()
  checkMutual()
}

const showCtx = (e, msg) => {
  if (msg.content === '你撤回了一条消息') return
  if (msg._local) {
    if (msg._failed) { ctx.value = { visible: true, x: e.clientX, y: e.clientY, msg } }
    return
  }
  if (msg.senderId !== currentUser.id) return
  ctx.value = { visible: true, x: e.clientX, y: e.clientY, msg }
}
const hideCtx = () => { ctx.value.visible = false }

const deleteMsg = async (msg) => {
  if (msg._local) {
    messages.value = messages.value.filter(m => m._key !== msg._key)
    const key = 'failed_msgs_' + activeUserId.value
    const saved = JSON.parse(sessionStorage.getItem(key) || '[]')
    sessionStorage.setItem(key, JSON.stringify(saved.filter(m => m._key !== msg._key)))
    ctx.value.visible = false
    return
  }
  try { await messageApi.delete(msg.id); fetchMessages(); fetchConversations() } catch (e) { /* */ }
  ctx.value.visible = false
}
const recallMsg = async (msg) => {
  try { await messageApi.recall(msg.id); fetchMessages(); fetchConversations() } catch (e) { /* */ }
}

const sendMessage = async () => {
  if (!inputText.value.trim() || !activeUserId.value) return
  const text = inputText.value.trim()
  const tempId = 'local_' + Date.now()
  const localMsg = { _key: tempId, _local: true, content: text, senderId: currentUser.id, _failed: false }
  messages.value.push(localMsg)
  inputText.value = ''
  await nextTick()
  scrollToBottom()
  try {
    await messageApi.send({ toUserId: activeUserId.value, content: text })
    const idx = messages.value.findIndex(m => m._key === tempId)
    if (idx >= 0) messages.value.splice(idx, 1)
    fetchMessages()
    fetchConversations()
  } catch (e) {
    localMsg._failed = true
    ElMessage({ message: '消息发送失败，请等待对方回复', type: 'warning', duration: 2000 })
    const key = 'failed_msgs_' + activeUserId.value
    const saved = JSON.parse(sessionStorage.getItem(key) || '[]')
    saved.push(localMsg)
    sessionStorage.setItem(key, JSON.stringify(saved))
  }
}

const scrollToBottom = () => {
  if (chatRef.value) {
    chatRef.value.scrollTop = chatRef.value.scrollHeight
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

// Init: load conversations, then if route has :userId, select that conversation
onMounted(async () => {
  document.addEventListener('click', hideCtx)
  await fetchConversations()
  const routeUserId = route.params.userId
  if (routeUserId) {
    selectConversation(Number(routeUserId))
  }
  // Poll for new messages
  pollTimer = setInterval(() => {
    if (activeUserId.value) fetchMessages()
    fetchConversations()
  }, 5000)
})
</script>

<style scoped>
.messages-page { height: calc(100vh - 136px); }
.messages-layout { display: flex; height: 100%; gap: 0; border-radius: 16px; overflow: hidden; border: 1px solid #eee9e0; background: #fff; }

.conversation-panel { width: 300px; flex-shrink: 0; border-right: 1px solid #eee9e0; display: flex; flex-direction: column; }
.panel-header { padding: 18px 20px; border-bottom: 1px solid #eee9e0; }
.panel-header h3 { font-size: 17px; font-weight: 700; color: #1a1a1a; margin: 0; }
.conversation-list { flex: 1; overflow-y: auto; }
.conv-item {
  display: flex; align-items: center; gap: 12px; padding: 14px 20px;
  cursor: pointer; transition: all .15s; border-bottom: 1px solid #f5f1ea;
}
.conv-item:hover { background: #faf9f6; }
.conv-item.active { background: #f0edf8; border-left: 3px solid #5b7fff; padding-left: 17px; }
.conv-info { flex: 1; min-width: 0; }
.conv-top { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 4px; }
.conv-name { font-size: 14px; font-weight: 600; color: #333; }
.conv-time { font-size: 11px; color: #ccc; }
.conv-preview { display: flex; align-items: center; justify-content: space-between; }
.conv-text { font-size: 12px; color: #aaa; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 150px; }
.empty-conv { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #ccc; }
.empty-conv p { font-size: 15px; margin-bottom: 4px; }
.empty-conv span { font-size: 12px; color: #ddd; }

.chat-panel { flex: 1; display: flex; flex-direction: column; min-width: 0; }
.chat-header {
  display: flex; align-items: center; gap: 12px; padding: 14px 20px;
  border-bottom: 1px solid #eee9e0; flex-shrink: 0;
}
.chat-name { font-size: 15px; font-weight: 600; color: #333; display: block; }
.limit-warning { font-size: 12px; color: #f0a050; }
.chat-messages {
  flex: 1; overflow-y: auto; padding: 20px;
  display: flex; flex-direction: column; gap: 14px;
  background: #faf9f6;
}
.empty-chat { text-align: center; margin-top: 100px; color: #ccc; }
.empty-chat p { font-size: 15px; margin-bottom: 4px; }
.empty-chat span { font-size: 12px; color: #ddd; }
.recall-notice { text-align: center; padding: 8px 0; }
.recall-notice span { font-size: 12px; color: #5b7fff; background: #f0f0f5; padding: 3px 12px; border-radius: 6px; }
.msg-row { display: flex; gap: 10px; align-items: flex-start; }
.msg-row.mine { flex-direction: row-reverse; }
.msg-bubble {
  max-width: 60%; padding: 10px 14px; border-radius: 16px;
  background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.msg-bubble.mine { background: linear-gradient(135deg, #5b7fff, #7c6ff7); }
.msg-content { font-size: 14px; color: #333; line-height: 1.5; word-break: break-word; }
.msg-bubble.mine .msg-content { color: #fff; }
.msg-time { font-size: 11px; color: #ccc; margin-top: 4px; text-align: right; }
.msg-bubble.mine .msg-time { color: rgba(255,255,255,0.7); }
.ctx-menu {
  position: fixed; z-index: 9999; background: #fff; border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15); overflow: hidden;
  display: flex; flex-direction: column; min-width: 80px;
}
.ctx-menu button {
  border: none; background: #fff; padding: 10px 20px; font-size: 13px;
  cursor: pointer; text-align: left; font-family: inherit; transition: background .15s;
}
.ctx-menu button:hover { background: #f5f3ef; }
.ctx-menu button:last-child { color: #e86060; }
.ctx-menu button:last-child:hover { background: #fff0f0; }

.msg-status { display: flex; align-items: center; align-self: center; }
.fail-icon {
  display: flex; align-items: center; justify-content: center;
  width: 20px; height: 20px; border-radius: 50%;
  background: #ff6b6b; color: #fff; font-size: 12px; font-weight: 700;
  cursor: pointer;
}
.sending-icon { color: #ccc; font-size: 16px; animation: spin 1s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.chat-input {
  display: flex; gap: 10px; padding: 14px 20px; border-top: 1px solid #eee9e0;
  align-items: flex-end; flex-shrink: 0;
}
.chat-input :deep(.el-textarea__inner) { border-radius: 12px; }
.send-btn { flex-shrink: 0; height: 40px; border-radius: 12px; font-weight: 600; }

.no-chat { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #ddd; }
.no-chat p { margin-top: 12px; font-size: 16px; color: #ccc; }
.no-chat span { font-size: 13px; color: #ddd; }

@media (max-width: 768px) {
  .conversation-panel { width: 260px; }
}

.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
</style>
