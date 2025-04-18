<template>
  <div>
    <main>
      <!-- 左侧边栏 - 与首页保持一致 -->
      <LeftBlock />
      
      <!-- 右侧内容管理区域 - 合并了中间和右侧为一个大块 -->
      <div class="content-wrapper">
        <div class="content-header">
          <h1>我的内容</h1>
          <div class="content-stats">
            <div class="stat-item">
              <span class="stat-value">{{ totalPosts }}</span>
              <span class="stat-label">总帖子</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ totalViews }}</span>
              <span class="stat-label">总浏览</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ totalLikes }}</span>
              <span class="stat-label">总点赞</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ totalComments }}</span>
              <span class="stat-label">总评论</span>
            </div>
          </div>
        </div>
        
        <!-- 帖子列表 -->
        <div class="posts-list">
          <div v-if="isLoading && userPosts.length === 0" class="loading">加载中...</div>
          <div v-else-if="userPosts.length === 0" class="no-posts">
            暂无帖子，开始创作吧！
          </div>
          <div v-else class="post-items">
            <div v-for="post in userPosts" :key="post.id" class="post-item">
              <div class="post-image-container">
                <div class="post-image" v-if="post.imageUrl && post.imageUrl.length">
                  <img :src="post.imageUrl[0]" alt="帖子图片">
                </div>
                <div v-else class="post-image no-image">
                  <i class="no-image-icon">📄</i>
                </div>
                <div class="post-time-section">
                  <span class="post-time">{{ formatDate(post.postDate) }}</span>
                  <div class="section-tag" v-if="post.section">
                    {{ post.section.sectionName }}
                  </div>
                </div>
                <div class="post-stats">
                  <div class="stat">
                    <i class="stat-icon">👁️</i>
                    <span>{{ post.viewsCount }}</span>
                  </div>
                  <div class="stat">
                    <i class="stat-icon">👍</i>
                    <span>{{ post.likesCount }}</span>
                  </div>
                  <div class="stat">
                    <i class="stat-icon">💬</i>
                    <span>{{ post.commentsCount }}</span>
                  </div>
                </div>
              </div>
              <div class="post-content-container">
                <div class="post-content">
                  <h3 class="post-title" @click="viewPostDetail(post.id)">{{ post.title }}</h3>
                  <p class="post-summary">{{ post.content }}</p>
                </div>
                <div class="post-actions">
                  <button class="action-btn edit" @click="editPost(post.id)">编辑</button>
                  <button class="action-btn delete" @click="confirmDelete(post.id)">删除</button>
                </div>
              </div>
            </div>
            
            <!-- 加载更多按钮 -->
            <div v-if="hasMorePosts && !isLoading" class="load-more-container">
              <button @click="loadMorePosts" class="load-more-button">加载更多</button>
            </div>
            
            <!-- 加载中提示 -->
            <div v-if="isLoading && userPosts.length > 0" class="loading-indicator">
              加载中...
            </div>
            
            <!-- 全部加载完毕提示 -->
            <div v-if="!hasMorePosts && userPosts.length > 0" class="all-loaded-message">
              已加载全部内容
            </div>
            
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, onBeforeUnmount } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth.js';
import axios from 'axios';
import LeftBlock from '../components/LeftBlock.vue';
import { ElMessage, ElMessageBox } from 'element-plus';

export default defineComponent({
  name: 'ContentManagement',
  components: {
    LeftBlock
  },
  setup() {
    const router = useRouter();
    const authStore = useAuthStore();
    const userPosts = ref([]);
    const isLoading = ref(true);
    const totalPosts = ref(0);
    const totalViews = ref(0);
    const totalLikes = ref(0);
    const totalComments = ref(0);
    
    // 添加分页相关变量
    const currentPage = ref(1);
    const hasMorePosts = ref(true);

    // 获取用户帖子列表
    const fetchUserPosts = async (reset = true) => {
      if (!authStore.isLoggedIn) {
        ElMessage.error('请先登录');
        router.push('/');
        return;
      }

      isLoading.value = true;
      
      // 如果是重置，则重置页码和帖子列表
      if (reset) {
        currentPage.value = 1;
        userPosts.value = [];
      }
      
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        const response = await axios.get('http://localhost:7070/api/posts/by-user', {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          },
          params: {
            userId: authStore.userInfo.id,
            pageNum: currentPage.value,
            pageSize: 5
          }
        });

        // 处理分页数据
        const pageData = response.data;
        const newPosts = pageData.records || [];
        
        // 处理字段名称差异，将views映射为viewsCount
        newPosts.forEach(post => {
          post.viewsCount = post.views;
        });
        
        if (reset) {
          userPosts.value = newPosts;
        } else {
          userPosts.value = [...userPosts.value, ...newPosts];
        }
        
        // 检查是否还有更多页
        hasMorePosts.value = currentPage.value < pageData.pages && newPosts.length > 0;
        
        // 计算总计数据
        calculateTotals();
      } catch (error) {
        console.error('获取帖子失败:', error);
        ElMessage.error('获取帖子列表失败');
      } finally {
        isLoading.value = false;
      }
    };
    
    // 加载更多帖子
    const loadMorePosts = async () => {
      if (isLoading.value || !hasMorePosts.value) return;
      
      currentPage.value++;
      await fetchUserPosts(false);
    };

    // 计算总计数据
    const calculateTotals = () => {
      totalPosts.value = userPosts.value.length;
      totalViews.value = userPosts.value.reduce((sum, post) => sum + (post.viewsCount || 0), 0);
      totalLikes.value = userPosts.value.reduce((sum, post) => sum + (post.likesCount || 0), 0);
      totalComments.value = userPosts.value.reduce((sum, post) => sum + (post.commentsCount || 0), 0);
    };

    // 查看帖子详情
    const viewPostDetail = (postId) => {
      router.push(`/post-detail?postId=${postId}`);
    };

    // 编辑帖子
    const editPost = (postId) => {
      router.push(`/creator-center?postId=${postId}`);
    };

    // 确认删除帖子
    const confirmDelete = (postId) => {
      ElMessageBox.confirm('确定要删除这篇帖子吗？此操作不可撤销。', '删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        deletePost(postId);
      }).catch(() => {
        // 用户取消删除
      });
    };

    // 删除帖子
    const deletePost = async (postId) => {
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        await axios.delete(`http://localhost:7070/api/posts/${postId}`, {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        });
        
        ElMessage.success('帖子已删除');
        // 重新获取帖子列表
        fetchUserPosts();
      } catch (error) {
        console.error('删除帖子失败:', error);
        ElMessage.error('删除帖子失败');
      }
    };

    // 时间格式化函数
    const formatDate = (dateStr) => {
      if (!dateStr) return '暂无日期';
      
      try {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(dateStr).toLocaleDateString('zh-CN', options);
      } catch (error) {
        console.error('日期格式化错误:', error);
        return dateStr;
      }
    };

    // 组件挂载时添加滚动控制
    onMounted(() => {
      // 获取用户帖子
      fetchUserPosts();
      
      // 标记当前页面，用于控制头部搜索框显示
      document.body.classList.add('content-management-page');
      
      // 强制禁用body滚动
      document.body.style.overflow = 'hidden';
      document.documentElement.style.overflow = 'hidden';
      
      // 查找所有可能的容器并禁用滚动
      const app = document.getElementById('app');
      if (app) {
        app.style.overflow = 'hidden';
      }
      
      // 只允许帖子列表滚动
      const postsList = document.querySelector('.posts-list');
      if (postsList) {
        postsList.style.overflow = 'auto';
        postsList.style.height = `${window.innerHeight - 295}px`;
      }
    });
    
    // 组件卸载时恢复滚动
    onBeforeUnmount(() => {
      document.body.classList.remove('content-management-page');
      
      // 恢复滚动
      document.body.style.overflow = '';
      document.documentElement.style.overflow = '';
      
      const app = document.getElementById('app');
      if (app) {
        app.style.overflow = '';
      }
    });

    return {
      userPosts,
      isLoading,
      totalPosts,
      totalViews,
      totalLikes,
      totalComments,
      viewPostDetail,
      editPost,
      confirmDelete,
      hasMorePosts,
      loadMorePosts,
      formatDate
    };
  }
});
</script>

<style scoped>
/* 更强力的页面全局样式 */
html, body, #app {
  overflow: hidden !important; /* 强制禁止整个页面滚动 */
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
}

:deep(*) {
  scrollbar-width: none; /* Firefox */
}

:deep(*::-webkit-scrollbar) {
  display: none; /* Chrome, Safari, Edge */
}

.posts-list {
  scrollbar-width: auto !important; /* Firefox */
}

.posts-list::-webkit-scrollbar {
  display: block !important; /* Chrome, Safari, Edge */
  width: 8px;
}

/* 修改布局样式，使其与Index页面一致 */
main {
  display: flex;
  justify-content: center; /* 改为居中对齐，与Index页面一致 */
  padding-top: 30px;
  height: 100vh; /* 使用固定高度而非最小高度 */
  margin-top: 75px; /* 保留此样式，为页头留出空间 */
  position: relative;
  overflow: hidden; /* 防止整体滚动 */
}

/* 左侧块样式，与Index保持一致 */
.left-block {
  width: 200px;
  margin-right: 20px;
  position: fixed !important; /* 固定位置 */
  left: calc(50% - 600px); /* 居中定位 */
  top: 85px;
  background-color: #f7f8f9;
  height: calc(100vh - 115px);
  overflow: hidden; /* 禁止左侧块滚动 */
  z-index: 100;
}

/* 内容管理区域样式 */
.content-wrapper {
  width: 980px; /* 保持宽度一致 */
  margin: 0; /* 移除左边距，由main的居中布局控制 */
  margin-left: 220px; /* 给左侧块留出空间 */
  position: relative;
  overflow: hidden; /* 禁止整体滚动 */
}

.content-header {
  background-color: white;
  border-radius: 8px;
  padding: 20px; /* 恢复原来的padding */
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  position: fixed !important; /* 固定位置 */
  top: 85px;
  width: 940px; /* 恢复原来的宽度 */
  z-index: 99;
}

.content-header h1 {
  margin: 0 0 20px 0; /* 恢复原来的间距 */
  font-size: 24px; /* 恢复原来的字体大小 */
  color: #333;
}

.content-stats {
  display: flex;
  justify-content: space-between;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: #f7f8f9;
  padding: 15px; /* 恢复原来的padding */
  border-radius: 8px;
  width: 22%;
}

.stat-value {
  font-size: 24px; /* 恢复原来的字体大小 */
  font-weight: bold;
  color: #409EFF;
}

.stat-label {
  font-size: 14px; /* 恢复原来的字体大小 */
  color: #666;
  margin-top: 5px; /* 恢复原来的间距 */
}

/* 帖子列表样式 */
.posts-list {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  margin-top: 130px; /* 为顶部固定的内容区域留出空间 */
  height: calc(100vh - 295px); /* 设置固定高度 */
  overflow-y: auto; /* 允许垂直滚动 */
}

/* 添加滚动条样式 */
.posts-list::-webkit-scrollbar {
  width: 8px;
}
.posts-list::-webkit-scrollbar-track {
  background: #f1f1f1;
}
.posts-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

.loading, .no-posts {
  text-align: center;
  padding: 40px;
  color: #666;
  font-size: 16px;
}

.post-items {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 帖子样式 */
.post-item {
  display: flex;
  background-color: white;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
}

.post-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.08);
}

/* 左侧内容 */
.post-image-container {
  width: 180px;
  margin-right: 20px;
  display: flex;
  flex-direction: column;
}

.post-image {
  width: 180px;
  height: 120px;
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 10px;
  background-color: #f5f5f5;
}

.no-image {
  display: flex;
  justify-content: center;
  align-items: center;
}

.no-image-icon {
  font-size: 36px;
  color: #ccc;
}

.post-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.post-time-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.post-time {
  font-size: 12px;
  color: #999;
}

.section-tag {
  display: inline-block;
  padding: 2px 8px;
  background-color: #f0f2f5;
  border-radius: 4px;
  font-size: 12px;
  color: #666;
  white-space: nowrap;
}

.post-stats {
  display: flex;
  justify-content: space-between;
  gap: 5px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 2px;
  color: #666;
  font-size: 12px;
}

.stat-icon {
  font-size: 14px;
}

/* 右侧内容 */
.post-content-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.post-content {
  flex: 1;
}

.post-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 10px 0;
  color: #333;
  cursor: pointer;
}

.post-title:hover {
  color: #409EFF;
}

.post-summary {
  font-size: 14px;
  color: #666;
  margin: 0;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.post-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 10px;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.edit {
  background-color: #e6f7ff;
  color: #1890ff;
}

.edit:hover {
  background-color: #1890ff;
  color: white;
}

.delete {
  background-color: #fff1f0;
  color: #f5222d;
}

.delete:hover {
  background-color: #f5222d;
  color: white;
}

/* 加载更多按钮样式 */
.load-more-container {
  padding: 10px 0 20px 0;
  width: 100%;
  display: flex;
  justify-content: center;
}

.load-more-button {
  width: 90%;
  background-color: #409EFF;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 12px 0;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.load-more-button:hover {
  background-color: #66b1ff;
}

.loading-indicator,
.all-loaded-message {
  text-align: center;
  padding: 10px;
  color: #666;
  font-size: 14px;
}

.all-loaded-message {
  color: #999;
  font-style: italic;
}
</style>