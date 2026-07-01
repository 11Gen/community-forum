import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    component: () => import('../views/Layout.vue'),
    children: [
      { path: '', name: 'Home', component: () => import('../views/Home.vue') },
      { path: 'post/:id', name: 'PostDetail', component: () => import('../views/PostDetail.vue') },
      { path: 'profile', name: 'Profile', component: () => import('../views/Profile.vue') },
      { path: 'notifications', name: 'Notifications', component: () => import('../views/Notifications.vue') },
      { path: 'create-post', name: 'CreatePost', component: () => import('../views/CreatePost.vue'), meta: { requireAuth: true } },
      { path: 'edit-post/:id', name: 'EditPost', component: () => import('../views/CreatePost.vue'), meta: { requireAuth: true } },
      { path: 'admin', name: 'Admin', component: () => import('../views/Admin.vue'), meta: { requireAuth: true, requireAdmin: true } },
      { path: 'user/:id', name: 'UserProfile', component: () => import('../views/UserProfile.vue') },
      { path: 'messages', name: 'Messages', component: () => import('../views/Messages.vue'), meta: { requireAuth: true } },
      { path: 'messages/:userId', name: 'MessagesWithUser', component: () => import('../views/Messages.vue'), meta: { requireAuth: true } },
      { path: 'essence', name: 'Essence', component: () => import('../views/TopicList.vue'), props: { mode: 'essence' } },
      { path: 'hot', name: 'Hot', component: () => import('../views/TopicList.vue'), props: { mode: 'hot' } },
      { path: 'qa', name: 'QA', component: () => import('../views/TopicList.vue'), props: { mode: 'qa' } },
      { path: 'about', name: 'About', component: () => import('../views/About.vue') },
    ]
  },
  { path: '/login', name: 'Login', component: () => import('../views/Login.vue') },
  { path: '/register', name: 'Register', component: () => import('../views/Register.vue') },
  { path: '/forgot-password', name: 'ForgotPassword', component: () => import('../views/ForgotPassword.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = sessionStorage.getItem('token')
  const user = JSON.parse(sessionStorage.getItem('user') || '{}')

  if (to.meta.requireAuth && !token) {
    next('/login')
    return
  }
  if (to.meta.requireAdmin && user.role !== 'ADMIN') {
    next('/')
    return
  }
  next()
})

export default router
