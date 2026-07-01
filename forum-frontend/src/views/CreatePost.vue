<template>
  <div class="editor-page">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>

    <div class="editor-card">
      <h2>{{ isEdit ? '编辑帖子' : '发布新帖子' }}</h2>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="0">
        <el-form-item prop="title">
          <el-input v-model="form.title" placeholder="起一个吸引人的标题..." size="large" maxlength="200" show-word-limit />
        </el-form-item>
        <el-form-item prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="选择分类" size="large" style="width:100%">
            <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>

        <!-- 图片上传区 -->
        <div class="upload-section">
          <div class="upload-header">
            <span class="upload-label">图片</span>
            <el-upload :http-request="handleUpload" :show-file-list="false" accept="image/*" :before-upload="beforeUpload">
              <el-button size="small" :loading="uploading" :icon="Plus">上传图片</el-button>
            </el-upload>
            <span class="upload-note">JPG/PNG/GIF, 单张 &le; 5MB</span>
          </div>
          <div class="image-strip" v-if="images.length > 0">
            <div v-for="(img, idx) in images" :key="idx" class="image-thumb">
              <img :src="img.url" />
              <div class="thumb-overlay">
                <button @click="insertImage(img.url)">插入</button>
                <button @click="removeImage(idx)" class="del">删除</button>
              </div>
            </div>
          </div>
        </div>

        <!-- 正文 -->
        <el-form-item prop="content">
          <div class="toolbar">
            <button @click="wrapTag('b')"><b>B</b></button>
            <button @click="wrapTag('i')"><i>I</i></button>
            <button @click="wrapTag('u')"><u>U</u></button>
            <span class="sep"></span>
            <button @click="wrapTag('h3')">标题</button>
            <button @click="wrapTag('blockquote')">引用</button>
            <button @click="wrapTag('pre')">代码</button>
            <span class="sep"></span>
            <button @click="insertRaw('<br>')">换行</button>
            <button @click="insertRaw('<hr>')">分隔线</button>
          </div>
          <el-input v-model="form.content" type="textarea" :rows="16"
            placeholder="写下你想分享的内容... 点击上方按钮插入格式标签，上传图片后可点击【插入】将图片添加到正文。" />
        </el-form-item>

        <div class="form-footer">
          <el-button size="large" @click="$router.back()" style="min-width:100px">取消</el-button>
          <el-button type="primary" size="large" :loading="loading" @click="submit" style="min-width:140px">
            {{ isEdit ? '保存修改' : '发布帖子' }}
          </el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { postApi, categoryApi, uploadApi } from '../api'
import { ElMessage } from 'element-plus'
import { Plus, ArrowLeft } from '@element-plus/icons-vue'

const route = useRoute(); const router = useRouter()
const formRef = ref(null); const loading = ref(false); const uploading = ref(false)
const categories = ref([]); const isEdit = ref(false); const images = ref([])

const form = reactive({ title: '', categoryId: null, content: '' })
const rules = {
  title: [{ required: true, message: '请输入帖子标题', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  content: [{ required: true, message: '请输入帖子内容', trigger: 'blur' }]
}

onMounted(async () => {
  const res = await categoryApi.getList(); categories.value = res.data
  if (route.params.id) {
    isEdit.value = true
    const postRes = await postApi.getDetail(route.params.id)
    const p = postRes.data
    form.title = p.title; form.categoryId = p.categoryId; form.content = p.content
  }
})

const beforeUpload = (file) => {
  if (!file.type.startsWith('image/')) { ElMessage.error('只能上传图片文件'); return false }
  if (file.size / 1024 / 1024 > 5) { ElMessage.error('图片不超过5MB'); return false }
  return true
}

const handleUpload = async (options) => {
  uploading.value = true
  try {
    const res = await uploadApi.uploadImage(options.file)
    images.value.push({ url: res.data.url, name: options.file.name })
    ElMessage.success('上传成功')
  } catch (e) { ElMessage.error('上传失败') }
  uploading.value = false
}

const insertImage = (url) => {
  form.content += `\n<img src="${url}" alt="" style="max-width:100%;border-radius:10px;margin:10px 0" />\n`
  ElMessage.success('图片已插入正文')
}

const removeImage = (idx) => images.value.splice(idx, 1)

const wrapTag = (tag) => {
  const map = { b: ['<b>','</b>'], i: ['<i>','</i>'], u: ['<u>','</u>'], h3: ['<h3>','</h3>'], blockquote: ['<blockquote>','</blockquote>'], pre: ['<pre><code>','</code></pre>'] }
  const [o, c] = map[tag]; form.content += o + c
}

const insertRaw = (str) => { form.content += str }

const submit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    if (isEdit.value) {
      await postApi.update(route.params.id, form)
      ElMessage.success('修改成功'); router.push(`/post/${route.params.id}`)
    } else {
      const res = await postApi.create(form)
      ElMessage.success('发布成功'); router.push(`/post/${res.data.id}`)
    }
  } catch (e) { /* */ }
  loading.value = false
}
</script>

<style scoped>
.editor-page { max-width: 820px; margin: 0 auto; }
.editor-card { background: #fff; border-radius: 16px; padding: 32px 36px; border: 1px solid #eee9e0; }
.editor-card h2 { font-size: 20px; font-weight: 700; margin-bottom: 28px; color: #1a1a1a; }

.upload-section { margin-bottom: 20px; background: #faf9f6; border-radius: 12px; padding: 16px 18px; }
.upload-header { display: flex; align-items: center; gap: 12px; }
.upload-label { font-size: 14px; font-weight: 600; color: #333; }
.upload-note { font-size: 12px; color: #ccc; }
.image-strip { display: flex; gap: 10px; margin-top: 12px; flex-wrap: wrap; }
.image-thumb { width: 100px; height: 100px; border-radius: 10px; overflow: hidden; position: relative; border: 1px solid #e8e4dd; }
.image-thumb img { width: 100%; height: 100%; object-fit: cover; }
.thumb-overlay { position: absolute; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; gap: 8px; opacity: 0; transition: opacity .2s; }
.image-thumb:hover .thumb-overlay { opacity: 1; }
.thumb-overlay button { background: #fff; border: none; padding: 3px 10px; border-radius: 5px; font-size: 12px; cursor: pointer; font-family: inherit; font-weight: 600; color: #333; }
.thumb-overlay button.del { background: #ff6b6b; color: #fff; }

.toolbar { display: flex; gap: 4px; margin-bottom: 8px; flex-wrap: wrap; align-items: center; }
.toolbar button { padding: 4px 10px; border: 1px solid #e0dcd5; background: #fff; border-radius: 6px; font-size: 13px; cursor: pointer; color: #666; font-family: inherit; transition: all .15s; }
.toolbar button:hover { border-color: #b0a8e0; color: #5b7fff; background: #f8f7ff; }
.sep { width: 1px; height: 20px; background: #e8e4dd; margin: 0 4px; }

.form-footer { display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; }

.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
</style>
