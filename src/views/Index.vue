<template>
  <div id="app">
    <!-- 头部 -->
  

    <!-- 内容区域 -->
    <main>
      <LeftBlock  />
      <div class="post-wrapper" ref="postWrapper">
        <div class="post-list">
          <!-- 第一个帖子特殊处理 -->
          <div class="post-item">
            <div class="scroll-indicator left" @click="scrollLeft" v-if="canScrollLeft"></div>
            <div class="scroll-indicator right" @click="scrollRight" v-if="canScrollRight"></div>
            <div class="section-list-container">
              <div class="section-list-scroll" ref="sectionListScroll">
                <div 
                  v-for="section in sections" 
                  :key="section.id" 
                  class="section-item"
                  @click="handlesectionClick(section)"
                >
                  <img 
                    :src="section.imageUrl" 
                    alt="分区图标" 
                    class="section-icon"
                  >
                  <span class="section-name">{{ section.sectionName }}</span>
                </div>
              </div>
            </div>
          </div>
          <!-- 从第二个帖子开始展示posts数据 -->
          <div @click="handlePostClick(post.id)" v-for="post in displayedPosts" :key="post.id" class="post-item">
            <div class="user-info">
              <img @click.stop="goToUserProfile(post.user.id)" :src="post.user.imageUrl" alt="用户头像" class="avatar" style="cursor: pointer">
              <span @click.stop="goToUserProfile(post.user.id)" class="username" style="cursor: pointer">{{ post.user.username }}</span>
            </div>
            <h2>{{ post.title }}</h2>
            <p>{{ post.content }}</p>
            <div v-if="post.imageUrl" class="post-image" :class="{ 'multiple-images': post.imageUrl.length > 1 }">
              <template v-if="post.imageUrl.length === 1">
                <img :src="post.imageUrl[0]" alt="帖子图片" class="single-image">
              </template>
              <template v-else>
                <div v-for="(img, index) in post.imageUrl.slice(0, 3)" :key="index" style="position: relative;">
                  <img :src="img" alt="帖子图片">
                  <span v-if="index === 2 && post.imageUrl.length > 3" class="image-count">
                    {{ post.imageUrl.length }}张
                  </span>
                </div>
              </template>
            </div>
            <div class="sectionname">{{ post.section.sectionName }}</div>
            <div class="post-meta">
              <span class="post-time">{{ formatDate(post.postDate) }}</span>
              <div class="interaction">
                <span class="likes">👍 {{ post.likesCount }}</span>
                <span class="comments">💬 {{ post.commentsCount }}</span>
              </div>
            </div>
          </div>
          
          <!-- 加载更多按钮，仅登录用户可见 -->
          <div v-if="authStore.isLoggedIn && !isLastPage && !isLoading" class="load-more-container">
            <button @click="loadMorePosts" class="load-more-button">加载更多</button>
          </div>
          
          <!-- 加载中提示 -->
          <div v-if="isLoading" class="loading-indicator">
            加载中...
          </div>
          
          <!-- 全部加载完毕提示 -->
          <div v-if="isLastPage && posts.length > 0" class="all-loaded-message">
            已加载全部内容
          </div>
         
        </div>
      </div>
      <RightBlock 
        @post-click="handlePostClick"
      />
    </main>


    <router-view></router-view>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, onBeforeUnmount, computed} from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth.js';
import LeftBlock from '../components/LeftBlock.vue';
import RightBlock from '../components/RightBlock.vue';

export default defineComponent({
  name: 'HomePage',
  components: {
    LeftBlock,
    RightBlock
  },
  setup() {
    // 数据响应式声明
    const isLoggedIn = ref(false);
    const authStore = useAuthStore();
    const posts = ref([]);
    const sections = ref([]);
    const currentPage = ref(1);
    const isLoading = ref(false);
    const isLastPage = ref(false);
    const totalPages = ref(1);

    const username = ref('');
    const password = ref('');
    const canScrollLeft = ref(false);
    const canScrollRight = ref(false);
    const userInfo = ref({});

    const captchaImage = ref('');
    const userCaptcha = ref('');
    const isCaptchaLoading = ref(false);
    

    // 挂载生命周期钩子
    onMounted(() => {
      const storedInLocal = localStorage.getItem('userInfo');
      if (!sessionStorage.getItem('userInfo') && storedInLocal) {
        sessionStorage.setItem('userInfo', storedInLocal);
      }
      
      // 检查JWT令牌是否过期
      checkJwtExpiration();
      
      fetchPosts();

      // 添加全局滚轮事件监听
      window.addEventListener('wheel', handleGlobalScroll);

      // 确保DOM更新后执行
      setTimeout(() => {
        const postWrapper = document.querySelector('.post-wrapper');
        if (postWrapper) {
          postWrapper.scrollLeft = 100; // 设置 scrollLeft 属性
          postWrapper.scrollTop = 0;
        }
      }, 0);
    });

    // 检查JWT令牌是否过期
    const checkJwtExpiration = () => {
      const jwtToken = sessionStorage.getItem('jwtToken');
      if (jwtToken) {
        try {
          // 解析JWT获取过期时间（假设JWT格式为header.payload.signature）
          const base64Url = jwtToken.split('.')[1];
          const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
          const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
          }).join(''));
          
          const payload = JSON.parse(jsonPayload);
          const expTime = payload.exp * 1000; // 转换为毫秒
          
          // 判断是否过期
          if (Date.now() >= expTime) {
            console.log('JWT令牌已过期');
            authStore.logout(); // 执行登出操作
          } else {
            console.log('JWT令牌有效');
            isLoggedIn.value = true;
          }
        } catch (error) {
          console.error('解析JWT令牌出错:', error);
        }
      }
    };

    // 卸载生命周期钩子
    onBeforeUnmount(() => {
      // 移除全局滚轮事件监听
      window.removeEventListener('wheel', handleGlobalScroll);

      const sectionListScroll = document.querySelector('.section-list-scroll');
      if (sectionListScroll) {
        // 移除滚动事件监听
        sectionListScroll.removeEventListener('scroll', updateScrollButtonsVisibility);
      }
    });

  
    // 根据登录状态决定展示的帖子数量
    const displayedPosts = computed(() => {
      return posts.value;
    });
    
    // 加载更多帖子
    const loadMorePosts = async () => {
      if (isLoading.value || isLastPage.value) return;
      
      currentPage.value++;
      await fetchPosts(false);
    };


    const handlePostClick = (postId)=>{
      router.push({ 
    name: 'PostDetail', 
    query: { postId: postId } ,
    
  });
    }
    // 跳转到用户中心方法
    const goToUserCenter = () => {
      console.log('跳转到用户中心');
      // 后续可以添加实际的路由跳转逻辑，例如：this.$router.push('/user - center');
    };

    // 点击分区处理方法
    const handlesectionClick = (section) => {
      console.log('点击分区:', section);
      // 这里可以跳转到分区详情页
    };

    // 获取帖子数据方法
    const fetchPosts = async (reset = true) => {
      try {
        isLoading.value = true;
        
        if (reset) {
          // 重置数据
          posts.value = [];
          currentPage.value = 1;
          isLastPage.value = false;
        }
        
        const jwtToken = sessionStorage.getItem('jwtToken');
        const config = {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          },
          params: {
            pageNum: currentPage.value,
            pageSize: 10
          }
        };
        
        // 获取帖子数据
        const postsResponse = await axios.get('http://localhost:7070/api/posts/page', config);
        const pageData = postsResponse.data;
        const newPosts = pageData.records || [];
        
        // 获取分区数据（只在第一次加载时获取）
        if (reset || sections.value.length === 0) {
          const sectionsResponse = await axios.get('http://localhost:7070/api/sections', config);
          sections.value = sectionsResponse.data;
        }
        
        // 更新总页数
        totalPages.value = pageData.pages || 1;
        
        // 判断是否是最后一页
        if (currentPage.value >= totalPages.value || newPosts.length === 0 || !authStore.isLoggedIn) {
          isLastPage.value = true;
        }
        
        // 添加新帖子到列表
        if (reset) {
          posts.value = newPosts;
        } else {
          posts.value = [...posts.value, ...newPosts];
        }

        // 确保DOM更新后执行
        setTimeout(() => {
          const container = document.querySelector('.section-list-scroll');
          if (container) {
            container.scrollLeft = 0;
            // 立即更新按钮状态
            updateScrollButtonsVisibility();

            // 添加图片加载完成的检测
            const images = container.getElementsByTagName('img');
            let loadedCount = 0;

            Array.from(images).forEach(img => {
              if (img.complete) {
                loadedCount++;
              } else {
                img.onload = () => {
                  loadedCount++;
                  if (loadedCount === images.length) {
                    updateScrollButtonsVisibility();
                  }
                };
              }
            });

            // 如果所有图片已经加载完成
            if (loadedCount === images.length) {
              updateScrollButtonsVisibility();
            }
          }
        }, 0);
      } catch (error) {
        console.error('数据获取失败:', error);
      } finally {
        isLoading.value = false;
      }
    };
    
    const router = useRouter(); // 引入路由
    const goToPage = (path) => {
            // 假设你还想管理当前激活的项，可保留这行代码来更新状态
            // 如果你不需要管理激活状态，这行代码可以省略
            console.log('点击事件触发，即将跳转至:', path);
            currentSection.value = path.replace('-center', '_center');
            router.push({ path: `/${path}` }) // 进行路由跳转
            .catch((error) => {
            console.error('路由跳转出错:', error);
        });
        };
    

    // 格式化日期方法
    const formatDate = (dateStr) => {
      const options = { year: 'numeric', month: 'long', day: 'numeric' };
      return new Date(dateStr).toLocaleDateString('zh-CN', options);
    };

    // 全局滚轮事件处理方法
    const handleGlobalScroll = (event) => {
      const postWrapper = document.querySelector('.post-wrapper');

      // 确保事件目标是.post-wrapper 或其子元素
      if (!event.target.closest('.post-wrapper') ||!postWrapper) return;

      const isAtTop = postWrapper.scrollTop === 0;
      const isAtBottom = postWrapper.scrollTop + postWrapper.offsetHeight >= postWrapper.scrollHeight;

      const isScrollingDown = event.deltaY > 0;
      const isScrollingUp = event.deltaY < 0;

      if ((isScrollingDown && isAtBottom) || (isScrollingUp && isAtTop)) {
        return; // 边界锁定
      }

      const scrollStep = Math.min(Math.abs(event.deltaY) * 0.5, 100);
      postWrapper.scrollTop += isScrollingDown? scrollStep : -scrollStep;

      // 同步页面滚动
      const scrollRatio = postWrapper.scrollTop / (postWrapper.scrollHeight - postWrapper.offsetHeight);
      window.scrollTo({
        top: window.innerHeight * scrollRatio,
        behavior: 'smooth'
      });
    };

    // 向右滚动方法
    const scrollRight = () => {
      const container = document.querySelector('.section-list-scroll');
      if (!container) return;

      // 计算滚动的量
      const scrollAmount = 200;
      const maxScrollPosition = container.scrollWidth - container.clientWidth;

      // 确保滚动位置不会超出最大滚动范围
      const targetScrollLeft = Math.min(container.scrollLeft + scrollAmount, maxScrollPosition);
      container.scrollTo({
        left: targetScrollLeft,
        behavior: 'smooth'
      });

      // 异常捕获以确保按钮可见性更新的安全性
      try {
        updateScrollButtonsVisibility();
      } catch (error) {
        console.error('Failed to update scroll buttons visibility:', error);
      }
    };

    // 向左滚动方法
    const scrollLeft = () => {
      const container = document.querySelector('.section-list-scroll');
      if (!container) return;

      const scrollAmount = 200;
      container.scrollTo({
        left: container.scrollLeft - scrollAmount,
        behavior: 'smooth'
      });

      updateScrollButtonsVisibility();
    };

    // 更新滚动按钮可见性方法
    const updateScrollButtonsVisibility = () => {
      const container = document.querySelector('.section-list-scroll');
      if (!container) return;

      canScrollLeft.value = container.scrollLeft > 0;
      canScrollRight.value = container.scrollLeft + container.clientWidth < container.scrollWidth;

      // 获取第一个帖子元素并设置CSS变量
      const firstPostItem = document.querySelector('.post-item:first-child');
      if (firstPostItem) {
        firstPostItem.style.setProperty('--show-left', canScrollLeft.value? 'block' : 'none');
        firstPostItem.style.setProperty('--show-right', canScrollRight.value? 'block' : 'none');
      }
    };

    // 发布新内容方法
    
    const currentSection = ref('community_center');
    const goToUserProfile = (userId) => {
      router.push(`/user/${userId}`);
    };
    return {
      isLoggedIn,
      authStore,
      posts,
      displayedPosts,
      sections,
      username,
      password,
      canScrollLeft,
      canScrollRight,
      userInfo,
      currentSection,
      captchaImage,
      userCaptcha,
      isCaptchaLoading,
      isLoading,
      isLastPage,
      loadMorePosts,
      goToUserCenter,
      goToUserProfile,
      handlePostClick,
      handlesectionClick,
      fetchPosts,
      formatDate,
      handleGlobalScroll,
      scrollRight,
      scrollLeft,
      updateScrollButtonsVisibility,
      goToPage 
    };
  }
});
</script>

<style>
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background-color: #f7f8f9;
}
</style>

<style scoped>
/* 页面样式 */



main {
  display: flex;
  justify-content: center;
  padding-top: 30px;
  min-height: calc(100vh - 75px); /* 计算可视区域高度 */
  margin-top: 10px; /* 保持与头部的间距 */
}
.left-block,
.right-block {
  /* 原样式保留 */
  /* height: calc(100vh - 100px); 改用固定高度 */
  /* max-height: 800px;  */
  overflow-y: auto;
  align-self: flex-start; /* 保持顶部对齐 */
  background-color: #f7f8f9;
}


.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px; /* 与头部保持10px间距 */
  /* height: 300px; */
}

.left-section-top {
  height: 172px;
  width: 100%;
  background-color: #ffffff;
  border-radius: 6px;
  margin-bottom: 20px; /* 间距设置 */
  padding-top: 20px;
  
}
.left-section-top div{
  height: 30%;
  width: 90%;
  margin: auto;
  text-align: center;
  
  border-radius: 6px;
  display: grid;
  align-content: center;
}
.left-section-top div:hover{
  
  background-color: #fafbfc;
}
.left-section-top div.active {
  background-color: #fafbfc; 
}

.left-section-button {
  height: 60px;
  width: 100%;
  border: none;
  border-radius: 8px;
  background: #32373c;
  color: white;
  cursor: pointer;
  transition: background 0.3s ease;
}

.left-section-button:hover {
  background: #2a3034;
}
/* 侧边栏尺寸锁定 */

.left-block,
.right-block,
.post-wrapper {
  overflow: visible !important;
}
.post-wrapper {
  width: 610px;
  overflow-y: auto; /* 恢复垂直滚动 */
  overflow-x: hidden; /* 隐藏横向滚动 */
  /* max-height: calc(100vh - 100px); 添加高度限制 */
  margin: 0 20px;
  margin-right: 50px;
}
/* Chrome滚动条样式 */
.post-wrapper::-webkit-scrollbar {
  width: 8px;
}
.post-wrapper::-webkit-scrollbar-track {
  background: #f1f1f1;
}
.post-wrapper::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

.post-list {
  display: flex;
  flex-direction: column;
  gap: 1px; /* 帖子间距调整为5px */
}

.post-item {
  width: 100%;
  background-color: white;
  padding: 20px;
  border-radius: 8px;
  
  margin-bottom: 5px; /* 底部间距同步调整 */
}
.post-item:first-child {
  /* 增大高度 */
  height: auto; 
  position: relative;
  overflow: hidden;
  align-items: center;
}
.section-list-container {
  margin: 15px 0;
  overflow-x: hidden; /* 隐藏横向滚动条 */
  position: relative;
}

.section-list-scroll {
  display: flex;
  gap: 25px;
  /* padding-bottom: 10px; */
  white-space: nowrap; /* 防止游戏项换行 */
  overflow-x: auto;
}
.section-list-scroll::-webkit-scrollbar {
  display: none; /* 隐藏滚动条 */
}
.section-item {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  transition: transform 0.2s;
  width: 80px;
  
}

.section-item:hover {
  transform: translateY(-3px);
}

.section-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  object-fit: cover;
  /* margin-bottom: 8px; */
  box-shadow: 0 2px 6px rgba(0,0,0,0.1);
}

.section-name {
  font-size: 12px;
  color: rgb(20, 25, 30);
  text-align: center;
  line-height: 1.3;
  max-width: 80px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  
}
.sectionname {
  /* 绝对定位在.post-meta上方 */
  position: absolute;
  
  left: 20px;
  right: 20px;
  font-size: 12px;
  /* 确保文字不会溢出 */
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  background-color: rgb(243, 244, 245);
  max-width: 60px;
  text-align: center;
  border-radius: 4px;
}
.post-item:not(:first-child) {
  height: 300px;
  position: relative;
  padding-top: 50px;
}
.post-item:not(:first-child) h2 {
  /* margin-top: 10px; */
  font-size: 16px;
}

.post-item:not(:first-child) p {
  font-size: 13px;
  line-height: 1.6;
  margin-bottom: 40px; /* 为底部元数据留出空间 */
}

/* 渐变遮挡层 */
.scroll-indicator {
  position: absolute;
  top: 0;
  width: 60px; /* 扩大可点击区域 */
  height: 100%;
  background: linear-gradient(90deg, rgba(255,255,255,0) 0%, rgba(192,186,186,0.3) 100%);
  z-index: 3;
  cursor: pointer;
  transition: 0.3s;
}

.scroll-indicator.left {
  left: 0;
  transform: rotate(180deg);
}

.scroll-indicator.right {
  right: 0;
}

/* 悬浮箭头 */
/* 修正后的悬浮箭头样式 */
.post-item:first-child:hover::before {
  content: ">";
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  color: #409EFF;
  font-weight: bold;
  z-index: 1;
  animation: arrowSlide 0.5s;
}

.post-item:first-child:hover::after {
  content: "<";
  position: absolute;
  left: 8px;
  top: 50%;
  transform: translateY(-50%);
  color: #409EFF;
  font-weight: bold;
  z-index: 1;
  animation: arrowSlideLeft 0.5s;
}
@keyframes arrowSlide {
  from { right: -20px; }
  to { right: 8px; }
}

@keyframes arrowSlideLeft {
  from { left: -20px; }
  to { left: 8px; }
}

.post-item h2 {
  margin: 0 0 10px 0;
  font-size: 18px;
  color: #333;
}

.post-item p {
  font-size: 14px;
  color: #666;
}
/* 帖子图片容器样式 */
.post-image {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  justify-content: flex-start;
  align-items: flex-start;
}

/* 单张图片样式 */
.post-image img.single-image {
  max-width: 60%; 
  max-height: 190px; 
  border-radius: 4px;
  margin: 10px 0;
  display: grid; 
  margin-right: auto;
  margin-top: -30px;
}

/* 多张图片样式 */
.post-image.multiple-images {
  display: grid;
  grid-template-columns: repeat(3, 190px);
  gap: 5px;
  margin-top: -30px;
}

.post-image.multiple-images img {
  width: 190px;
  height: 190px;
  object-fit: cover;
  border-radius: 4px;
}

/* 图片数量提示 */
.image-count {
  position: absolute;
  top: 5px;
  right: 5px;
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 12px;
}
/* .post-image img {
  max-width: 60%; 
  max-height: 200px; 
  border-radius: 4px;
  margin: 10px 0;
  display: block; 
  margin-left: auto;
  margin-right: auto;
  margin-top: -30px;
} */
.user-info {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
  position: absolute;
  top: 15px;
  left: 20px;
  right: 20px;
}
.userinfo {
  display: flex;
  align-items: center;
  /* position: absolute; */
  /* right: 1320px; 根据实际布局调整 */
  /* margin-top: -10px;
  transform: translateX(-50%); */
  position: relative;
}
.avatar {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  margin-right: 12px;
  border: 2px solid #eee;
}

.username {
  font-weight: 500;
  color: #333;
  font-size: 14px;
}

.post-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: absolute;
  bottom: 15px;
  left: 20px;
  right: 20px;
}
.post-time {
  font-size: 12px;
  color: #999;
}
.interaction {
  display: flex;
  gap: 20px;
}

.likes, .comments {
  cursor: pointer;
  transition: color 0.2s;
  font-size: 13px;
}

.likes:hover, .comments:hover {
  color: #409EFF;
}
.post-meta span {
  margin-right: 15px;
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

/* 加载更多按钮样式 */
.load-more-container {
  padding: 10px 0 20px 0;
  width: 650px;
  display: flex;
  justify-content: center;
}

.load-more-button {
  width: 100%;
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

.loading-indicator {
  text-align: center;
  padding: 20px;
  color: #666;
  font-size: 14px;
}

.all-loaded-message {
  text-align: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
  font-style: italic;
}
</style>    