import axios from 'axios'
import { ElMessage } from 'element-plus'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

request.interceptors.request.use(config => {
  const token = sessionStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

request.interceptors.response.use(
  response => {
    const data = response.data
    if (data.code === 200) {
      return data
    }
    // Allow callers to suppress the default error toast
    if (!response.config._silent) {
      ElMessage.error(data.message || '请求失败')
    }
    return Promise.reject(new Error(data.message))
  },
  error => {
    if (error.response) {
      if (error.response.status === 401) {
        ElMessage({ message: '请先登录，登录后获得更好的体验', type: 'info', duration: 2000 })
      } else if (error.response.status === 403) {
        if (!error.config?._silent) {
          ElMessage.error('没有操作权限')
        }
      } else {
        if (!error.config?._silent) {
          ElMessage.error('服务器异常')
        }
      }
    } else {
      ElMessage.error('网络错误')
    }
    return Promise.reject(error)
  }
)

export default request
