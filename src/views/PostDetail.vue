<template>
  <div>
    <main>
      <!-- 左侧边栏保持不变 -->
      <LeftBlock />
      
      <!-- 中间内容区域 -->
      <div class="post-wrapper">
        <div class="post-detail" v-if="post">
          <div class="user-info">
            <img :src="post.user.imageUrl" alt="用户头像" class="avatar">
            <span class="username">{{ post.user.username }}</span>
          </div>
          <h1>{{ post.title }}</h1>
          <div class="post-content">{{ post.content }}</div>
          
          <!-- 图片轮播部分修改为 -->
  <div class="image-carousel" v-if="post.imageUrl && post.imageUrl.length">
    <div class="carousel-container">
      <button class="carousel-button left" @click="prevImage" :disabled="currentImageIndex === 0">
        &lt;
      </button>
      
      <div class="carousel-slide">
        <transition-group name="slide-fade" tag="div" class="slide-wrapper">
          <img 
            v-for="(img, index) in post.imageUrl" 
            :key="index"
            :src="img" 
            alt="帖子图片"
            class="carousel-image"
            v-show="index === currentImageIndex"
          >
        </transition-group>
      </div>
      
      <button class="carousel-button right" @click="nextImage" :disabled="currentImageIndex === post.imageUrl.length - 1">
        &gt;
      </button>
    </div>
    <div class="carousel-indicator">
      <span v-for="(img, index) in post.imageUrl" 
            :key="index" 
            :class="{ active: currentImageIndex === index }"
            @click="currentImageIndex = index"></span>
    </div>
  </div>
          
  <!-- 点赞与评论显示区域 -->
  <div class="post-actions">
    <div class="like-button" @click="toggleLike" :class="{ 'liked': isLiked }">
      <i class="like-icon">👍</i>
      <span>{{ post.likesCount }}</span>
    </div>
    <div class="comment-count">
      <i class="comment-icon">💬</i>
      <span>{{ post.commentsCount }}</span>
    </div>
  </div>
        <!-- 评论区域 -->
  <div class="comments-section">
    <h3>评论 ({{ post.commentsCount }})</h3>
    
    <div v-for="comment in post.comments" :key="comment.id" class="comment">
      <!-- 父评论区域 - 添加点击事件 -->
      <div class="comment-header" @click="setReplyContext(comment.id, comment.user?.id)" @contextmenu.prevent="showDeleteMenu($event, comment.id)">
  <img :src="comment.user?.imageUrl || 'default-avatar.jpg'" alt="用户头像" class="avatar">
  <span class="username">{{ comment.user?.username || '匿名用户' }}</span>
</div>

      <div class="comment-content">
        <p>{{ comment.commentText }}</p>
        <span class="comment-date">{{ formatDate(comment.commentDate) }}</span>
      </div>
      
      <!-- 子评论部分 - 添加点击事件 -->
   <!-- 修改后的子评论部分 -->
<div v-if="comment.childComments && comment.childComments.length" class="replies-container">
  <div v-for="reply in comment.childComments" 
       :key="reply.id" 
       class="reply"
       @click="setReplyContext(comment.id, reply.user?.id)">
    <span class="reply-username">{{ reply.user?.username || '匿名用户' }}</span>
    <template v-if="reply.replyToUser">
      <span class="reply-to-text">回复</span>
      <span class="reply-target">@{{ reply.replyToUser.username }}</span>
    </template>
    <span class="reply-content">: {{ reply.commentText }}</span>
  </div>
</div>
    </div>
  </div>
        </div>
        <div v-else class="loading">加载中...</div>
      </div>
      
      <!-- 右侧边栏保持不变 -->
      <RightBlock :hot-posts="hotPosts" />
    </main>
    
    <div class="fixed-comment-input" v-if="post">
      <div class="comment-input-container">
        <textarea v-model="newComment" placeholder="发表评论" rows="2"></textarea>
        <button @click="sendComment">发送</button>
      </div>
    </div>
    
    <!-- 上下文菜单 -->
    <div v-if="contextMenu.visible" 
         class="context-menu" 
         :style="{top: `${contextMenu.y}px`, left: `${contextMenu.x}px`}"
         @click.stop>
      <div class="menu-item delete" @click="deleteComment(contextMenu.commentId)">
        <i class="el-icon-delete"></i> 删除评论
      </div>
    </div>
    
  </div>
  
</template>

<script>
import { defineComponent, ref, onMounted, computed, onBeforeUnmount } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import { useAuthStore } from '../stores/auth.js';
import { ElMessage } from 'element-plus'

export default defineComponent({
  name: 'PostDetail',
  setup() {
    const route = useRoute();
    const post = ref(null);
    const isLoading = ref(true);
    const error = ref(null);
    const currentImageIndex = ref(0);
    const newComment = ref('');
    const transitionName = ref('slide-next');
    const comments = ref([]);
    const authStore = useAuthStore();
    const isLiked = ref(false);
    const replyContext = ref({
      parentCommentId: null,
      replyToUserId: null
    });
    
    // 添加上下文菜单状态
    const contextMenu = ref({
      visible: false,
      x: 0,
      y: 0,
      commentId: null
    });
    
    // 关闭上下文菜单
    const closeContextMenu = () => {
      contextMenu.value.visible = false;
    };
    
    // 点击文档其他地方时关闭上下文菜单
    const handleDocumentClick = () => {
      if (contextMenu.value.visible) {
        closeContextMenu();
      }
    };
    
    onMounted(() => {
      fetchPostDetail();
      document.addEventListener('click', handleDocumentClick);
    });
    
    onBeforeUnmount(() => {
      document.removeEventListener('click', handleDocumentClick);
    });

    const hotPosts = computed(() => {
      if (!post.value || !post.value.relatedPosts) return [];
      return post.value.relatedPosts.slice(0, 5);
    });

    const checkAndRefreshToken = async () => {
  const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
  if (!jwtToken) {
    authStore.logout();
    ElMessage.error('登录已过期，请重新登录');
    return false;
  }
  return true;
};
    const fetchPostDetail = async () => {
      if (!(await checkAndRefreshToken())) return;
      try {
        const postId = route.query.postId;
        if (!postId) throw new Error('缺少帖子ID');
        
        const authStore = useAuthStore();
        if (!authStore.isLoggedIn) {
          throw new Error('未登录或登录已过期');
        }

        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');

        if (!jwtToken) {
          console.error('未找到认证令牌');
          return;
        }

        const response = await axios.get('/api/post-detail', {
          params: { postId },
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        });

        if (!response.data) throw new Error('无效的响应数据');
        post.value = response.data;
        
        // 获取帖子详情后检查当前用户是否已点赞
        await checkLikeStatus();
      } catch (err) {
        error.value = err.response?.data?.message || err.message || '获取帖子详情失败';
        console.error('Error details:', err);
        
        if (err.response?.status === 401) {
          const authStore = useAuthStore();
          authStore.logout();
        }
      } finally {
        isLoading.value = false;
      }
    };
    
    const fetchComments = async () => {
  try {
    const response = await axios.get(`/api/post-detail/${post.value.id}`);
    comments.value = response.data.comments || [];
  } catch (error) {
    console.error('获取评论失败:', error);
    ElMessage.error('获取评论失败');
  }
};

    const nextImage = () => {
  transitionName.value = 'slide-next';
  if (currentImageIndex.value < post.value.imageUrl.length - 1) {
    currentImageIndex.value++;
  }
};

const prevImage = () => {
  transitionName.value = 'slide-prev';
  if (currentImageIndex.value > 0) {
    currentImageIndex.value--;
  }
};

    
const sendComment = async () => {
  console.log("即将发送评论请求",  newComment.value);
  try {
    // 确保重新从storage获取最新状态
    authStore.initializeFromStorage();
    
    if (!authStore.isLoggedIn) {
      ElMessage.error('请先登录');
      return;
    }
    
    if (!newComment.value.trim()) {
      ElMessage.error('评论内容不能为空');
      return;
    }
    
    const commentData = {
      postId: post.value.id,
      commentText: newComment.value,
      userId: authStore.userInfo.id,
      parentCommentId: replyContext.value.parentCommentId,
      replyToUserId: replyContext.value.replyToUserId
    };

    const response = await axios.post('/api/comments/add', commentData, {
      headers: {
        Authorization: `Bearer ${authStore.userInfo.token}`
      }
    });

    if (response.data.code === 200) {
      ElMessage.success('评论成功');
      newComment.value = '';
      replyContext.value = { parentCommentId: null, replyToUserId: null };
      await fetchPostDetail();
    } else {
      ElMessage.error(response.data.message || '评论失败');
    }
  } catch (error) {
    console.error('评论失败:', error);
    if (error.response?.status === 401) {
  ElMessage.error('登录已过期，请重新登录');
  return;
} else {
      ElMessage.error(error.response?.data?.message || '评论失败');
    }
  }
};
    
    const formatDate = (dateStr) => {
      const options = { year: 'numeric', month: 'long', day: 'numeric' };
      return new Date(dateStr).toLocaleDateString('zh-CN', options);
    };

    // 检查当前用户是否已点赞该帖子
    const checkLikeStatus = async () => {
      if (!authStore.isLoggedIn || !post.value) return;
      
      try {
        const response = await axios.get(`/api/posts/likes/check`, {
          params: {
            postId: post.value.id,
            userId: authStore.userInfo.id
          },
          headers: {
            Authorization: `Bearer ${authStore.userInfo.token}`
          }
        });
        
        // 根据后端返回结构调整
        isLiked.value = response.data.data || false;
      } catch (error) {
        console.error('检查点赞状态失败:', error);
      }
    };

    // 切换点赞状态
    const toggleLike = async () => {
      if (!authStore.isLoggedIn) {
        ElMessage.error('请先登录');
        return;
      }
      
      try {
        const requestData = {
          postId: post.value.id,
          userId: authStore.userInfo.id
        };
        
        if (isLiked.value) {
          // 取消点赞 - 使用POST方法和正确的路径
          await axios.post(`/api/posts/likes/remove`, requestData, {
            headers: {
              Authorization: `Bearer ${authStore.userInfo.token}`
            }
          });
          
          post.value.likesCount = Math.max(0, post.value.likesCount - 1);
          isLiked.value = false;
          ElMessage.success('已取消点赞');
        } else {
          // 添加点赞 - 使用POST方法和正确的路径
          await axios.post(`/api/posts/likes/add`, requestData, {
            headers: {
              Authorization: `Bearer ${authStore.userInfo.token}`
            }
          });
          
          post.value.likesCount++;
          isLiked.value = true;
          ElMessage.success('点赞成功');
        }
      } catch (error) {
        console.error('点赞操作失败:', error);
        ElMessage.error('操作失败，请稍后再试');
      }
    };

    // 显示上下文菜单
    const showDeleteMenu = (event, commentId) => {
      // 阻止默认右键菜单
      event.preventDefault();
      
      // 只有当评论是当前用户发布的，或者当前用户是管理员时才允许删除
      if (!authStore.isLoggedIn) return;
      
      const isCommentOwner = post.value.comments.some(comment => 
        comment.id === commentId && comment.user?.id === authStore.userInfo.id
      );
      
      const isAdmin = authStore.userInfo.role === 'ADMIN';
      
      if (isCommentOwner || isAdmin) {
        // 显示上下文菜单
        contextMenu.value.x = event.clientX;
        contextMenu.value.y = event.clientY;
        contextMenu.value.commentId = commentId;
        contextMenu.value.visible = true;
        event.stopPropagation(); // 阻止事件冒泡
      }
    };

    // 执行删除评论的操作
    const deleteComment = async (commentId) => {
      try {
        const response = await axios.delete(`${import.meta.env.VITE_API_URL}/comments/${commentId}`, {
          headers: {
            Authorization: `Bearer ${authStore.userInfo?.token || localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken')}`
          }
        });
        
        if (response.status === 200) {
          // 更新评论列表
          post.value.comments = post.value.comments.filter(comment => comment.id !== commentId);
          // 显示成功消息
          ElMessage.success('评论已成功删除');
          // 关闭上下文菜单
          closeContextMenu();
        }
      } catch (error) {
        console.error('删除评论失败:', error);
        ElMessage.error(error.response?.data?.message || '删除评论失败');
        // 关闭上下文菜单
        closeContextMenu();
      }
    };

    // 设置回复上下文的方法
    const setReplyContext = (parentId, replyUserId) => {
      replyContext.value = {
        parentCommentId: parentId,
        replyToUserId: replyUserId
      };
      // 自动聚焦输入框（可选）
      document.querySelector('.fixed-comment-input textarea')?.focus();
    };

    return { 
      post, 
      isLoading, 
      error, 
      currentImageIndex,
      hotPosts,
      newComment,
      contextMenu,
      closeContextMenu,
      setReplyContext,
      fetchComments,
      nextImage,
      prevImage,
      sendComment,
      formatDate,
      toggleLike,
      checkLikeStatus,
      showDeleteMenu,
      deleteComment
    };
  }
});
</script>

<style scoped>
/* 保持与 Index.vue 一致的布局样式 */
main {
  display: flex;
  justify-content: center;
  padding-top: 30px;
  min-height: calc(100vh - 75px);
  margin-top: 10px;
  position: relative; 
}

.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px;
  background-color: #f7f8f9;
  height: calc(100vh - 115px); /* 视口高度减去头部和间距 */
  overflow-y: auto; /* 允许内容滚动 */
  align-self: flex-start; /* 顶部对齐 */
}

.left-section-top {
  height: 172px;
  width: 100%;
  background-color: #ffffff;
  border-radius: 6px;
  margin-bottom: 20px;
  padding-top: 20px;
}

.left-section-top div {
  height: 30%;
  width: 90%;
  margin: auto;
  text-align: center;
  border-radius: 6px;
  display: grid;
  align-content: center;
}

.left-section-top div:hover {
  background-color: #fafbfc;
}

.left-section-top div.active {
  background-color: #fafbfc; 
}

/* 帖子详情区域 - 保持与 Index.vue 一致的宽度 */
.post-wrapper {
  width: 610px;

}

.post-detail {
  background-color: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.post-detail h1 {
  font-size: 24px;
  margin: 20px 0;
}

.post-content {
  line-height: 1.6;
  margin-bottom: 20px;
}

/* 用户信息样式 */
.user-info {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.user-info .avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  margin-right: 10px;
  border: 2px solid #eee;
}

.user-info .username {
  font-weight: 500;
  color: #333;
  font-size: 14px;
}

/* 图片轮播样式 */
.image-carousel {
  position: relative;
  margin-bottom: 20px;
}

.carousel-container {
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  height: 400px;
  overflow: hidden;
}

.carousel-slide {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.carousel-image {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: 4px;
}
/* 添加动画样式 */
.slide-wrapper {
  position: relative;
  width: 100%;
  height: 100%;
}

.carousel-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 4px;
}

/* 滑动动画 */
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.5s ease;
}

.slide-fade-enter-from {
  transform: translateX(100%);
  opacity: 0;
}

.slide-fade-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

/* 左右滑动动画变体 */
.slide-next-enter-active,
.slide-next-leave-active,
.slide-prev-enter-active,
.slide-prev-leave-active {
  transition: all 0.5s ease;
}

.slide-next-enter-from {
  transform: translateX(100%);
  opacity: 0;
}

.slide-next-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-prev-enter-from {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-prev-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
.carousel-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 40px;
  height: 40px;
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  border-radius: 50%;
  font-size: 20px;
  cursor: pointer;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
}

.carousel-button:hover {
  background-color: rgba(0, 0, 0, 0.7);
}

.carousel-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.carousel-button.left {
  left: 10px;
}

.carousel-button.right {
  right: 10px;
}

.carousel-indicator {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 10px;
}

.carousel-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #ccc;
  cursor: pointer;
}

.carousel-indicator span.active {
  background-color: #409EFF;
}

/* 评论区域样式 */
.comments-section {
  margin-top: 30px;
  margin-bottom: 60px;
}

.comments-section h3 {
  font-size: 18px;
  margin-bottom: 20px;
  color: #333;
}

.comment {
  border-bottom: 1px solid #ddd;
  padding: 15px 0;
}

.comment:last-child {
  border-bottom: none;
}

.comment-header {
  display: flex;
  align-items: center;
}

.comment-header .avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  margin-right: 10px;
  border: 1px solid #eee;
}

.comment-header .username {
  font-weight: 500;
  font-size: 14px;
  color: #333;
}

.comment-content {
  margin-left: 40px;
}

.comment-content p {
  margin: 0;
  line-height: 1.5;
  font-size: 14px;
  color: #333;
}

.comment-date {
  font-size: 12px;
  color: #999;
  margin-top: 5px;
  display: block;
}

/* 子评论样式 */
.replies-container {
  margin-top: 10px;
  margin-left: 40px;
  padding: 10px;
  background-color: #f7f8f9;
  border-radius: 4px;
  width: calc(100% - 15%);
}

.reply {
  font-size: 13px;
  line-height: 1.5;
  padding: 5px 0;
  color: #666;
}

.reply-username {
  font-weight: 500;
  color: #409EFF;
}
/* 右边块 */
.right-block {
  width: 350px;
  height: 500px;
  margin-left: 20px;
  position: sticky;
  top: 85px;
  background-color: #ffffff;
  padding: 20px;
  border-radius: 8px;
 
}

.hot-posts-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 15px;
}

.hot-posts-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.hot-post-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background-color: #f7f8f9;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.hot-post-item:hover {
  background-color: #e9ecef;
}

.hot-post-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
}

.hot-post-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.hot-post-content {
  flex: 1;
}

.hot-post-content h3 {
  font-size: 14px;
  margin: 0;
  color: #333;
}

.hot-post-meta {
  display: flex;
  gap: 10px;
  font-size: 12px;
  color: #666;
}

/* 修改固定评论输入框样式 */
.fixed-comment-input {
  position: fixed;
  bottom: 0;
  left: 44.4%; /* 居中定位 */
  transform: translateX(-50%); /* 精确居中 */
  width: 610px; /* 与.post-detail同宽 */
  background-color: white;
  padding: 10px 20px; /* 左右内边距与.post-detail一致 */
  border-top: 1px solid #eee;
  box-shadow: 0 -2px 10px rgba(0,0,0,0.05);
  z-index: 100;
  box-sizing: border-box; /* 确保宽度包含内边距 */
}

.comment-input-container {
  display: flex;
  width: 100%; /* 使用父容器的全部宽度 */
  gap: 10px;
  align-items: center;
  margin: 0; /* 移除多余的边距 */
}

.comment-input-container textarea {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  resize: none;
  min-height: 40px;
  box-sizing: border-box;
}

.comment-input-container button {
  padding: 10px 20px;
  background-color: #409EFF;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.comment-input-container button:hover {
  background-color: #66b1ff;
}

/* 加载中样式 */
.loading {
  text-align: center;
  padding: 50px;
  background-color: white;
  border-radius: 8px;
}
/* 添加一些交互样式，让用户知道可以点击评论 */
.comment-header, .reply {
  cursor: pointer;
  transition: background-color 0.2s;
}

.comment-header:hover {
  background-color: #f5f5f5;
  border-radius: 4px;
  padding: 2px 5px;
}

.reply:hover {
  background-color: #f0f0f0;
  border-radius: 4px;
  padding: 2px 5px;
}
.reply {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  font-size: 13px;
  line-height: 1.5;
  padding: 5px 0;
  color: #666;
}

.reply-username {
  font-weight: 500;
  color: #409EFF;
  margin-right: 5px;
}

.reply-to-text {
  margin: 0 5px;
  color: #666;
}

.reply-target {
  color: #409EFF;
  margin-right: 5px;
}

.reply-content {
  word-break: break-word;
}

/* 添加点赞和评论计数区域样式 */
.post-actions {
  display: flex;
  margin-top: 20px;
  border-top: 1px solid #eee;
  padding-top: 15px;
  gap: 20px;
}

.like-button, .comment-count {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #666;
}

.like-button {
  cursor: pointer;
  transition: all 0.2s;
}

.like-button:hover {
  color: #409EFF;
}

.like-button.liked {
  color: #409EFF;
}

.like-icon, .comment-icon {
  font-size: 18px;
}

/* 上下文菜单样式 */
.context-menu {
  position: fixed;
  background: white;
  border: 1px solid #eee;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  z-index: 1000;
  min-width: 100px;
}

.menu-item {
  padding: 8px 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.menu-item:hover {
  background-color: #f5f7fa;
}

.menu-item.delete {
  color: #f56c6c;
}
</style>