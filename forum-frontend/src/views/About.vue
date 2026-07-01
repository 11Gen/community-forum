<template>
  <div class="about-page">
    <button class="back-arrow" @click="$router.back()">
      <el-icon :size="20"><ArrowLeft /></el-icon>
    </button>
    <div class="about-card">
      <h2>关于社区</h2>
      <section>
        <h4>社区简介</h4>
        <p>这是一个开放、友好的技术交流与生活分享社区。无论是编程技术、日常生活、学习资源还是问答求助，都欢迎大家在这里畅所欲言，分享知识与见解。</p>
      </section>
      <section>
        <h4>社区版规</h4>
        <ul>
          <li>尊重他人，文明交流，禁止人身攻击和谩骂</li>
          <li>禁止发布违法、违规、涉黄、涉政等内容</li>
          <li>技术交流区请保持内容与技术相关</li>
          <li>资源分享需确保链接有效、内容合法</li>
          <li>重复发帖、恶意灌水将做删帖处理</li>
          <li>发现违规内容欢迎联系管理员举报</li>
        </ul>
      </section>
      <section>
        <h4>联系方式</h4>
        <p>如有问题或建议，请联系社区管理员。管理员邮箱：admin@forum.com</p>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ArrowLeft } from '@element-plus/icons-vue'
</script>

<style scoped>
.back-arrow {
  display: inline-flex; align-items: center; justify-content: center;
  width: 36px; height: 36px; border-radius: 10px; border: none;
  background: transparent; color: #999; cursor: pointer;
  transition: all .2s; margin-bottom: 12px;
}
.back-arrow:hover { background: #e8e4dd; color: #333; }
.about-page { max-width: 800px; margin: 0 auto; }
.about-card { background: #fff; border-radius: 16px; padding: 32px 36px; border: 1px solid #eee9e0; }
.about-card h2 { font-size: 22px; font-weight: 700; margin-bottom: 24px; color: #1a1a1a; }
section { margin-bottom: 24px; }
section h4 { font-size: 15px; font-weight: 700; color: #333; margin-bottom: 10px; }
section p, section li { font-size: 14px; color: #555; line-height: 1.8; }
section ul { padding-left: 20px; }
section li { margin-bottom: 4px; }
</style>
