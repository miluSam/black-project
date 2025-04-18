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
          <div v-if="isLoading" class="loading">加载中...</div>
          <div v-else-if="userPosts.length === 0" class="no-posts">
            暂无帖子，开始创作吧！
          </div>
          <div v-else class="post-items">
            <div v-for="post in userPosts" :key="post.id" class="post-item">
              <div class="post-content">
                <h3 class="post-title" @click="viewPostDetail(post.id)">{{ post.title }}</h3>
                <p class="post-summary">{{ post.content }}</p>
                <div class="post-image" v-if="post.imageUrl && post.imageUrl.length">
                  <img :src="post.imageUrl[0]" alt="帖子图片">
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
              <div class="post-actions">
                <button class="action-btn edit" @click="editPost(post.id)">编辑</button>
                <button class="action-btn delete" @click="confirmDelete(post.id)">删除</button>
              </div>
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

    // 获取用户帖子列表
    const fetchUserPosts = async () => {
      if (!authStore.isLoggedIn) {
        ElMessage.error('请先登录');
        router.push('/');
        return;
      }

      isLoading.value = true;
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        const response = await axios.get('/api/user/posts', {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          },
          params: {
            userId: authStore.userInfo.id
          }
        });

        userPosts.value = response.data.posts || [];
        
        // 计算总计数据
        calculateTotals();
      } catch (error) {
        console.error('获取帖子失败:', error);
        ElMessage.error('获取帖子列表失败');
      } finally {
        isLoading.value = false;
      }
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
        await axios.delete(`/api/posts/${postId}`, {
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

    // 组件挂载时，发送事件通知父组件隐藏搜索框
    onMounted(() => {
      // 获取用户帖子
      fetchUserPosts();
      
      // 标记当前页面，用于控制头部搜索框显示
      document.body.classList.add('content-management-page');
    });
    
    // 组件卸载时移除标记
    onBeforeUnmount(() => {
      document.body.classList.remove('content-management-page');
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
      confirmDelete
    };
  }
});
</script>

<style scoped>
/* 修改布局样式，使其与Index页面一致 */
main {
  display: flex;
  justify-content: center; /* 改为居中对齐，与Index页面一致 */
  padding-top: 30px;
  min-height: calc(100vh - 75px);
  margin-top: 75px; /* 保留此样式，为页头留出空间 */
  position: relative;
}

/* 左侧块样式，与Index保持一致 */
.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px;
  background-color: #f7f8f9;
  height: calc(100vh - 115px);
  overflow-y: auto;
  align-self: flex-start;
}

/* 内容管理区域样式 */
.content-wrapper {
  width: 980px; /* 保持宽度一致 */
  margin: 0; /* 移除左边距，由main的居中布局控制 */
}

.content-header {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.content-header h1 {
  margin: 0 0 20px 0;
  font-size: 24px;
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
  padding: 15px;
  border-radius: 8px;
  width: 22%;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
}

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

/* 帖子列表样式 */
.posts-list {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
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

.post-item {
  border-bottom: 1px solid #eee;
  padding-bottom: 20px;
}

.post-item:last-child {
  border-bottom: none;
}

.post-content {
  display: flex;
  flex-direction: column;
  margin-bottom: 15px;
}

.post-title {
  font-size: 18px;
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
  margin: 0 0 10px 0;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.post-image {
  width: 100%;
  max-height: 200px;
  overflow: hidden;
  border-radius: 8px;
  margin-top: 10px;
}

.post-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.post-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #666;
  font-size: 14px;
}

.stat-icon {
  font-size: 16px;
}

.post-actions {
  display: flex;
  gap: 10px;
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
</style>