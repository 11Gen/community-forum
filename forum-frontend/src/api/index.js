import request from '../utils/request'

// 用户
export const userApi = {
  register: (data) => request.post('/user/register', data),
  login: (data) => request.post('/user/login', data),
  getProfile: () => request.get('/user/profile'),
  getUser: (id) => request.get(`/user/${id}`),
  updateProfile: (data) => request.put('/user/profile', data),
  uploadAvatar: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return request.post('/user/avatar', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
  },
  saveSecurityQuestions: (questions) => request.post('/user/security-questions', { questions }),
  getSecurityQuestions: (userId) => request.get(`/user/security-questions/${userId}`),
  getForgotQuestions: (username) => request.post('/user/forgot-password/questions', { username }),
  verifyForgotPassword: (data) => request.post('/user/forgot-password/verify', data),
  resetForgotPassword: (data) => request.post('/user/forgot-password/reset', data)
}

// 帖子
export const postApi = {
  getList: (params) => request.get('/post/list', { params }),
  getRecommended: (params) => request.get('/post/recommended', { params }),
  getEssence: (params) => request.get('/post/essence', { params }),
  getDetail: (id) => request.get(`/post/${id}`),
  create: (data) => request.post('/post/create', data),
  update: (id, data) => request.put(`/post/${id}`, data),
  delete: (id) => request.delete(`/post/${id}`),
  search: (params) => request.get('/post/search', { params })
}

// 评论
export const commentApi = {
  getByPost: (postId) => request.get(`/comment/post/${postId}`),
  create: (data) => request.post('/comment/create', data),
  delete: (id) => request.delete(`/comment/${id}`),
  toggleLike: (commentId) => request.post(`/comment/like/${commentId}`),
  togglePin: (commentId, postId) => request.put(`/comment/${commentId}/pin`, { postId })
}

// 点赞
export const likeApi = {
  toggle: (postId) => request.post(`/like/toggle/${postId}`)
}

// 收藏
export const favoriteApi = {
  toggle: (postId) => request.post(`/favorite/toggle/${postId}`),
  check: (postId) => request.get(`/favorite/check/${postId}`),
  list: (params) => request.get('/favorite/list', { params })
}

// 浏览历史
export const historyApi = {
  list: (params) => request.get('/user/history', { params })
}

// 分类
export const categoryApi = {
  getList: () => request.get('/category/list')
}

// 通知
export const notificationApi = {
  getList: () => request.get('/notification/list'),
  getUnreadCount: () => request.get('/notification/unread-count'),
  markRead: (id) => request.put(`/notification/${id}/read`),
  markAllRead: () => request.put('/notification/read-all')
}

// 上传
export const uploadApi = {
  uploadImage: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return request.post('/upload/image', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
  }
}

// 管理员
export const adminApi = {
  getUsers: (params) => request.get('/admin/users', { params }),
  toggleUserStatus: (id, status) => request.put(`/admin/user/${id}/status`, { status }),
  getPosts: (params) => request.get('/admin/posts', { params }),
  deletePost: (id) => request.delete(`/admin/post/${id}`),
  togglePin: (id) => request.put(`/admin/post/${id}/pin`),
  toggleEssence: (id) => request.put(`/admin/post/${id}/essence`),
  getComments: (params) => request.get('/admin/comments', { params }),
  deleteComment: (id) => request.delete(`/admin/comment/${id}`),
  createCategory: (data) => request.post('/admin/category', data),
  updateCategory: (id, data) => request.put(`/admin/category/${id}`, data),
  deleteCategory: (id) => request.delete(`/admin/category/${id}`),
  resetPassword: (id) => request.put(`/admin/user/${id}/reset-password`)
}

// 关注
export const followApi = {
  follow: (userId) => request.post(`/follow/${userId}`),
  unfollow: (userId) => request.delete(`/follow/${userId}`),
  check: (userId) => request.get(`/follow/check/${userId}`),
  followers: (userId) => request.get(`/follow/followers/${userId}`),
  following: (userId) => request.get(`/follow/following/${userId}`),
  stats: (userId) => request.get(`/follow/stats/${userId}`),
}

// 私信
export const messageApi = {
  send: (data) => request.post('/message/send', data, { _silent: true }),
  getConversation: (userId) => request.get(`/message/conversation/${userId}`),
  getConversations: () => request.get('/message/conversations'),
  markRead: (id) => request.put(`/message/${id}/read`),
  getUnreadCount: () => request.get('/message/unread-count'),
  delete: (id) => request.delete(`/message/${id}`),
  recall: (id) => request.put(`/message/${id}/recall`),
}

// 搜索
export const searchApi = {
  getHot: () => request.get('/search/hot'),
  getHistory: () => request.get('/search/history'),
  clearHistory: () => request.delete('/search/history'),
  record: (keyword) => request.post('/search/history', { keyword }),
}
