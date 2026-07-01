<template>
  <div class="auth-page">
    <div class="auth-card">
      <router-link to="/login" class="back-arrow">
        <el-icon :size="22"><ArrowLeft /></el-icon>
      </router-link>
      <div class="auth-header">
        <span class="brand-dot"></span>
        <h2>{{ step === 1 ? '找回密码' : step === 2 ? '验证密保' : '重置密码' }}</h2>
        <p>{{ step === 1 ? '请输入你的登录账号' : step === 2 ? '请回答密保问题' : '请设置新密码' }}</p>
      </div>

      <!-- Step 1: 输入账号 -->
      <el-form v-if="step === 1" :model="form1" ref="form1Ref" label-width="0" @keyup.enter="nextStep1">
        <el-form-item prop="username">
          <el-input v-model="form1.username" placeholder="登录账号" size="large" :prefix-icon="User" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" :loading="loading" @click="nextStep1"
            style="width:100%;height:46px;font-size:15px;font-weight:600;border-radius:12px">下一步</el-button>
        </el-form-item>
      </el-form>

      <!-- Step 2: 回答密保问题 -->
      <div v-if="step === 2">
        <div v-if="questions.length === 0" style="text-align:center;color:#aaa;padding:20px">
          该用户未设置密保问题，请联系管理员重置密码
        </div>
        <div v-else>
          <div v-for="(q, idx) in questions" :key="idx" style="margin-bottom:16px">
            <p style="font-size:14px;font-weight:600;color:#333;margin-bottom:6px">问题{{ idx+1 }}：{{ q.question }}</p>
            <el-input v-model="answers[idx]" size="large" placeholder="请输入答案" />
          </div>
          <el-button type="primary" size="large" :loading="loading" @click="nextStep2"
            style="width:100%;height:46px;font-size:15px;font-weight:600;border-radius:12px;margin-top:8px">验证</el-button>
        </div>
      </div>

      <!-- Step 3: 重置密码 -->
      <el-form v-if="step === 3" :model="form3" :rules="rules" ref="form3Ref" label-width="0" @keyup.enter="resetPassword">
        <el-form-item prop="password">
          <el-input v-model="form3.password" type="password" placeholder="新密码 (6-30个字符)" size="large" :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="form3.confirmPassword" type="password" placeholder="确认新密码" size="large" :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" :loading="loading" @click="resetPassword"
            style="width:100%;height:46px;font-size:15px;font-weight:600;border-radius:12px">重置密码</el-button>
        </el-form-item>
      </el-form>

      <div class="auth-footer">
        想起密码了？<router-link to="/login">返回登录</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import { ElMessage } from 'element-plus'
import { User, Lock, ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter()
const step = ref(1)
const loading = ref(false)
const form1 = reactive({ username: '' })
const questions = ref([])
const answers = ref(['', '', ''])
const userId = ref(null)
const token = ref('')
const form3 = reactive({ password: '', confirmPassword: '' })
const form3Ref = ref(null)

const rules = {
  password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 30, message: '密码长度6-30个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (value !== form3.password) callback(new Error('两次密码不一致'))
      else callback()
    }, trigger: 'blur' }
  ]
}

const nextStep1 = async () => {
  if (!form1.username.trim()) return
  loading.value = true
  try {
    const res = await userApi.getForgotQuestions(form1.username)
    userId.value = res.data.userId
    questions.value = res.data.questions
    step.value = 2
  } catch (e) { /* error shown by interceptor */ }
  loading.value = false
}

const nextStep2 = async () => {
  loading.value = true
  try {
    // Verify answers directly - backend checks username exists + answers correct
    const res = await userApi.verifyForgotPassword({
      username: form1.username,
      answers: answers.value.slice(0, 3).map(a => ({ answer: a }))
    })
    userId.value = res.data.userId
    token.value = res.data.token
    step.value = 3
  } catch (e) { /* error shown by interceptor */ }
  loading.value = false
}

const resetPassword = async () => {
  const valid = await form3Ref.value?.validate().catch(() => false)
  if (valid === false) return
  loading.value = true
  try {
    await userApi.resetForgotPassword({
      userId: userId.value,
      token: token.value,
      password: form3.password
    })
    ElMessage.success('密码重置成功，请登录')
    router.push('/login')
  } catch (e) { /* error shown by interceptor */ }
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
.auth-footer a { color: #5b7fff; font-weight: 600; }
</style>
