<template>
  <div class="auth-page">
    <div class="auth-card">
      <router-link to="/" class="back-arrow">
        <el-icon :size="22"><ArrowLeft /></el-icon>
      </router-link>
      <div class="auth-header">
        <span class="brand-dot"></span>
        <h2>欢迎回来</h2>
        <p>登录你的社区论坛账号</p>
      </div>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="0" @keyup.enter="login">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="登录账号" size="large" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码" size="large"
            :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" style="width:100%;height:46px;font-size:15px;font-weight:600;border-radius:12px"
            :loading="loading" @click="login">登 录</el-button>
        </el-form-item>
      </el-form>
      <div class="auth-footer">
        <router-link to="/forgot-password">忘记密码？</router-link>
        <span style="margin:0 8px;color:#ddd">|</span>
        还没有账号？<router-link to="/register">立即注册</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import { ElMessage } from 'element-plus'
import { User, Lock, ArrowRight, ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const form = reactive({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const login = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    const res = await userApi.login(form)
    const token = res.data.token
    sessionStorage.setItem('token', token)
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const jsonStr = decodeURIComponent(atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join(''))
    const payload = JSON.parse(jsonStr)
    const user = { id: Number(payload.sub), nickname: payload.nickname, role: payload.role }
    sessionStorage.setItem('user', JSON.stringify(user))
    ElMessage.success('登录成功')
    router.push('/')
  } catch (e) {
    ElMessage.error('登录失败，请检查登录账号和密码')
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(160deg, #f0ece4 0%, #e8e4f0 50%, #f5f3ef 100%);
  padding: 20px;
}
.back-arrow {
  position: absolute; top: 20px; left: 20px;
  width: 36px; height: 36px; display: flex; align-items: center; justify-content: center;
  border-radius: 10px; color: #999; transition: all .2s;
}
.back-arrow:hover { background: #f5f3ef; color: #333; }
.auth-card {
  position: relative;
  width: 420px; background: #fff; border-radius: 20px;
  padding: 48px 40px 36px;
  box-shadow: 0 4px 40px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04);
}
.auth-header { text-align: center; margin-bottom: 36px; }
.brand-dot {
  display: inline-block; width: 12px; height: 12px; border-radius: 50%;
  background: linear-gradient(135deg, #5b7fff, #8b5cf6); margin-bottom: 16px;
}
.auth-header h2 { font-size: 24px; color: #1a1a1a; margin-bottom: 6px; font-weight: 700; }
.auth-header p { font-size: 14px; color: #999; }
.auth-footer { text-align: center; margin-top: 24px; font-size: 14px; color: #999; }
.auth-footer a { color: #5b7fff; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
.auth-footer a:hover { color: #4a6aee; }
</style>
