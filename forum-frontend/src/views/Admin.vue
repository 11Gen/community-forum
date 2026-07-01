<template>
  <div class="admin">
    <div class="admin-card">
      <h2>后台管理</h2>
      <el-tabs v-model="activeTab" class="admin-tabs">
        <el-tab-pane label="用户管理" name="users">
          <el-table :data="users" stripe style="width:100%">
            <el-table-column prop="id" label="ID" width="70" />
            <el-table-column prop="username" label="登录账号" />
            <el-table-column prop="nickname" label="昵称" />
            <el-table-column prop="email" label="邮箱" />
            <el-table-column prop="role" label="角色" width="90" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <span class="status-tag" :class="statusClass(row.status)">
                  {{ statusText(row.status) }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180">
              <template #default="{ row }">
                <el-dropdown @command="(cmd) => setUserStatus(row, cmd)" trigger="click" v-if="row.role !== 'ADMIN'">
                  <el-button size="small" text type="primary">
                    {{ row.status === 0 ? '正常' : '已限制' }}<el-icon class="el-icon--right"><ArrowDown /></el-icon>
                  </el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item command="0">正常</el-dropdown-item>
                      <el-dropdown-item command="1">禁言</el-dropdown-item>
                      <el-dropdown-item command="2">禁止登录</el-dropdown-item>
                      <el-dropdown-item command="3" divided>全部禁用</el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
                <el-button size="small" text type="warning" @click="resetUserPassword(row)">重置密码</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination small background layout="prev, pager, next" :total="userTotal" :page-size="10"
            v-model:current-page="userPage" @current-change="fetchUsers" style="margin-top:16px;justify-content:center" />
        </el-tab-pane>

        <el-tab-pane label="帖子管理" name="posts">
          <el-table :data="adminPosts" stripe style="width:100%">
            <el-table-column prop="id" label="ID" width="70" />
            <el-table-column prop="title" label="标题" show-overflow-tooltip />
            <el-table-column prop="nickname" label="作者" width="100" />
            <el-table-column label="操作" width="220">
              <template #default="{ row }">
                <el-button size="small" text @click="toggleEssence(row)">{{ row.isEssence ? '取消精华' : '加精' }}</el-button>
                <el-button size="small" text type="danger" @click="deleteAdminPost(row.id)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="分类管理" name="categories">
          <div class="cat-form">
            <el-input v-model="newCatName" placeholder="新分类名称" size="small" style="width:180px" />
            <el-input v-model="newCatDesc" placeholder="描述（可选）" size="small" style="width:200px" />
            <el-button type="primary" size="small" @click="addCategory" :icon="Plus">添加</el-button>
          </div>
          <el-table :data="adminCategories" stripe style="width:100%;margin-top:12px">
            <el-table-column prop="id" label="ID" width="70" />
            <el-table-column prop="name" label="名称" />
            <el-table-column prop="description" label="描述" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" text @click="openEditCat(row)">编辑</el-button>
                <el-button size="small" text type="danger" @click="deleteCategory(row.id)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="评论管理" name="comments">
          <el-table :data="adminComments" stripe style="width:100%">
            <el-table-column prop="id" label="ID" width="70" />
            <el-table-column prop="content" label="内容" show-overflow-tooltip />
            <el-table-column prop="nickname" label="用户" width="100" />
            <el-table-column label="操作" width="80">
              <template #default="{ row }">
                <el-button size="small" text type="danger" @click="deleteAdminComment(row.id)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog v-model="showEditCat" title="编辑分类" width="400px">
      <el-form label-width="80px">
        <el-form-item label="分类名称">
          <el-input v-model="editCatForm.name" placeholder="分类名称" />
        </el-form-item>
        <el-form-item label="分类描述">
          <el-input v-model="editCatForm.description" placeholder="分类描述" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="editCatForm.sortOrder" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditCat = false">取消</el-button>
        <el-button type="primary" @click="saveEditCat">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { adminApi, categoryApi } from '../api'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, ArrowDown } from '@element-plus/icons-vue'

const activeTab = ref('users')
const users = ref([]); const userTotal = ref(0); const userPage = ref(1)
const adminPosts = ref([]); const adminComments = ref([]); const adminCategories = ref([])
const newCatName = ref(''); const newCatDesc = ref('')
const showEditCat = ref(false); const editCatForm = ref({ id: null, name: '', description: '', sortOrder: 0 })

const fetchUsers = async () => {
  const res = await adminApi.getUsers({ page: userPage.value, size: 10 })
  users.value = res.data.records; userTotal.value = res.data.total
}
const fetchPosts = async () => { const res = await adminApi.getPosts({ page: 1, size: 50 }); adminPosts.value = res.data.records }
const fetchComments = async () => { const res = await adminApi.getComments({ page: 1, size: 50 }); adminComments.value = res.data.records }
const fetchCategories = async () => { const res = await categoryApi.getList(); adminCategories.value = res.data }

const statusText = (s) => ({ 0: '正常', 1: '禁言', 2: '禁止登录', 3: '全部禁用' }[s] || '未知')
const statusClass = (s) => ({ 0: 'ok', 1: 'mute', 2: 'ban', 3: 'ban' }[s] || 'ban')

const setUserStatus = async (row, cmd) => {
  const status = Number(cmd)
  await adminApi.toggleUserStatus(row.id, status)
  row.status = status
  ElMessage.success('状态已更新为：' + statusText(status))
}
const resetUserPassword = async (row) => {
  await ElMessageBox.confirm(`确定将用户"${row.nickname}"的密码重置为 88888888？`, '重置密码', { type: 'warning', confirmButtonText: '确认', cancelButtonText: '取消' })
  await adminApi.resetPassword(row.id)
  ElMessage.success('密码已重置为 88888888')
}
const toggleEssence = async (row) => { await adminApi.toggleEssence(row.id); row.isEssence = row.isEssence ? 0 : 1; ElMessage.success('操作成功') }
const deleteAdminPost = async (id) => {
  await ElMessageBox.confirm('确定删除？', '提示', { type: 'warning', confirmButtonText: '确认', cancelButtonText: '取消' })
  await adminApi.deletePost(id); ElMessage.success('已删除'); fetchPosts()
}
const deleteAdminComment = async (id) => {
  await ElMessageBox.confirm('确定删除？', '提示', { type: 'warning', confirmButtonText: '确认', cancelButtonText: '取消' })
  await adminApi.deleteComment(id); ElMessage.success('已删除'); fetchComments()
}
const addCategory = async () => {
  if (!newCatName.value) return
  await adminApi.createCategory({ name: newCatName.value, description: newCatDesc.value })
  ElMessage.success('已添加'); newCatName.value = ''; newCatDesc.value = ''; fetchCategories()
}
const deleteCategory = async (id) => {
  await ElMessageBox.confirm('确定删除？', '提示', { type: 'warning', confirmButtonText: '确认', cancelButtonText: '取消' })
  await adminApi.deleteCategory(id); ElMessage.success('已删除'); fetchCategories()
}

const openEditCat = (row) => {
  editCatForm.value = { id: row.id, name: row.name, description: row.description || '', sortOrder: row.sortOrder || 0 }
  showEditCat.value = true
}

const saveEditCat = async () => {
  await adminApi.updateCategory(editCatForm.value.id, {
    name: editCatForm.value.name,
    description: editCatForm.value.description,
    sortOrder: editCatForm.value.sortOrder
  })
  ElMessage.success('已更新'); showEditCat.value = false; fetchCategories()
}

onMounted(() => { fetchUsers(); fetchPosts(); fetchComments(); fetchCategories() })
</script>

<style scoped>
.admin { max-width: 960px; margin: 0 auto; }
.admin-card { background: #fff; border-radius: 16px; padding: 24px 28px; border: 1px solid #eee9e0; }
.admin-card h2 { font-size: 18px; font-weight: 700; margin-bottom: 20px; color: #1a1a1a; }
.admin-tabs { --el-tabs-header-height: 42px; }
.status-tag { font-size: 12px; padding: 2px 10px; border-radius: 10px; font-weight: 600; }
.status-tag.ok { background: #e8f5e9; color: #4caf50; }
.status-tag.mute { background: #fff3e0; color: #f0a050; }
.status-tag.ban { background: #fce4ec; color: #e86060; }
.cat-form { display: flex; gap: 10px; align-items: center; }
</style>
