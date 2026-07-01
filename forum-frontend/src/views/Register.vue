<template>
  <div class="auth-page">
    <div class="auth-card">
      <router-link to="/" class="back-arrow">
        <el-icon :size="22"><ArrowLeft /></el-icon>
      </router-link>
      <div class="auth-header">
        <span class="brand-dot"></span>
        <h2>创建账号</h2>
        <p>加入社区，开始分享与交流</p>
      </div>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="0">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="登录账号 (3-20个字符)" size="large" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="nickname">
          <el-input v-model="form.nickname" placeholder="昵称 (2-20个字符)" size="large" :prefix-icon="Edit" />
        </el-form-item>
        <el-form-item prop="email">
          <el-input v-model="form.email" placeholder="邮箱地址" size="large" :prefix-icon="Message" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码 (6-30个字符)" size="large"
            :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" placeholder="确认密码" size="large"
            :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" style="width:100%;height:46px;font-size:15px;font-weight:600;border-radius:12px"
            :loading="loading" @click="register">注 册</el-button>
        </el-form-item>
      </el-form>
      <div class="auth-footer">
        已有账号？<router-link to="/login">立即登录 <el-icon><ArrowRight /></el-icon></router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import { ElMessage } from 'element-plus'
import { User, Edit, Message, Lock, ArrowRight, ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const form = reactive({ username: '', nickname: '', email: '', password: '', confirmPassword: '' })

const validateConfirm = (rule, value, callback) => {
  if (value !== form.password) callback(new Error('两次输入密码不一致'))
  else callback()
}

const rules = {
  username: [
    { required: true, message: '请输入登录账号', trigger: 'blur' },
    { min: 3, max: 20, message: '登录账号长度3-20个字符', trigger: 'blur' }
  ],
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 20, message: '昵称长度2-20个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 30, message: '密码长度6-30个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ]
}

const register = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await userApi.register({
      username: form.username,
      nickname: form.nickname,
      email: form.email,
      password: form.password
    })
    ElMessage.success('注册成功，请登录')
    router.push('/login')
  } catch (e) { /* error handled by interceptor */ }
  loading.value = false
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
  width: 440px; background: #fff; border-radius: 20px;
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
