<template>
  <div id="app">
    <!-- 头部 -->
  

    <!-- 内容区域 -->
    <main>
      <LeftBlock  />
      <div class="post-wrapper" ref="postWrapper">
        <div class="post-list">
          <!-- 第一个块替换为用户信息 -->
          <div class="post-item user-info-container">
            <!-- 用户信息卡片 -->
            <div class="profile-card" v-if="!profileError">
              <div class="profile-header">
                <img :src="userProfile.imageUrl" alt="用户头像" class="profile-avatar">
                <div class="profile-info">
                  <h2>{{ userProfile.username }}</h2>
                  <div class="profile-stats">
                    <div class="stats-item">
                      <span class="stats-value">{{ userPosts.length }}</span>
                      <span class="stats-label">发布</span>
                    </div>
                    <div class="stats-item">
                      <span class="stats-value">{{ followers }}</span>
                      <span class="stats-label">粉丝</span>
                    </div>
                    <div class="stats-item">
                      <span class="stats-value">{{ following }}</span>
                      <span class="stats-label">关注</span>
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="profile-actions">
                <!-- 如果是当前登录用户，显示编辑按钮；否则显示关注和私信按钮 -->
                <template v-if="isCurrentUser">
                  <button class="edit-profile-btn" @click="showEditProfileDialog = true">编辑个人资料</button>
                </template>
                <template v-else>
                  <button :class="['follow-btn', {'following': isFollowing}]" @click="toggleFollow">
                    {{ isFollowing ? '已关注' : '关注' }}
                  </button>
                  <button class="message-btn" @click="sendMessage">发送私信</button>
                </template>
              </div>
              
              <div class="profile-bio">
                {{ userProfile.bio || '这个人很懒，还没有填写个人简介...' }}
              </div>
            </div>
            
            <!-- 用户资料获取错误提示 -->
            <div v-if="profileError" class="error-card">
              <i class="error-icon">!</i>
              <p>{{ profileError }}</p>
            </div>
          </div>
          
          <!-- 帖子标题 -->
          <div class="post-section-title">
            <!-- 添加切换选项卡 -->
            <div class="post-tabs">
              <div 
                class="post-tab" 
                :class="{ 'active': activeTab === 'posts' }" 
                @click="switchTab('posts')"
              >
                用户发布的帖子
              </div>
              <div 
                class="post-tab" 
                :class="{ 'active': activeTab === 'favorites' }" 
                @click="switchTab('favorites')"
              >
                用户收藏的帖子
              </div>
            </div>
          </div>
          
          <!-- 没有帖子时的提示 - 根据当前标签页显示不同提示 -->
          <div v-if="(activeTab === 'posts' && userPosts.length === 0 && !postsError) || 
                     (activeTab === 'favorites' && userFavorites.length === 0 && !favoritesError)" 
               class="no-posts">
            {{ activeTab === 'posts' ? '该用户暂未发布任何帖子' : '该用户暂未收藏任何帖子' }}
          </div>
          
          <!-- 帖子获取错误提示 - 根据当前标签页显示不同错误 -->
          <div v-if="(activeTab === 'posts' && postsError) || 
                     (activeTab === 'favorites' && favoritesError)" 
               class="error-message">
            <i class="error-icon">!</i>
            <p>{{ activeTab === 'posts' ? postsError : favoritesError }}</p>
          </div>
          
          <!-- 用户发布的帖子 -->
          <template v-if="activeTab === 'posts'">
            <div @click="handlePostClick(post.id)" v-for="post in userPosts" :key="post.id" class="post-item">
              <div class="user-info">
                <img @click.stop="goToUserProfile(post.user ? post.user.id : userId)" :src="post.user ? post.user.imageUrl : userProfile.imageUrl" alt="用户头像" class="avatar" style="cursor: pointer">
                <span @click.stop="goToUserProfile(post.user ? post.user.id : userId)" class="username" style="cursor: pointer">{{ post.user ? post.user.username : userProfile.username }}</span>
              </div>
              <h2 class="post-title">{{ truncateTitle(post.title) }}</h2>
              <p class="post-content">{{ truncateContent(post.content) }}</p>
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
          </template>
          
          <!-- 用户收藏的帖子 -->
          <template v-if="activeTab === 'favorites'">
            <div @click="handlePostClick(post.id)" v-for="post in userFavorites" :key="post.id" class="post-item">
              <div class="user-info">
                <img @click.stop="goToUserProfile(post.user ? post.user.id : post.userId)" 
                     :src="post.user ? post.user.imageUrl : 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'" 
                     alt="用户头像" 
                     class="avatar" 
                     style="cursor: pointer">
                <span @click.stop="goToUserProfile(post.user ? post.user.id : post.userId)" 
                      class="username" 
                      style="cursor: pointer">{{ post.user ? post.user.username : '用户已不存在' }}</span>
              </div>
              <h2 class="post-title">{{ truncateTitle(post.title) }}</h2>
              <p class="post-content">{{ truncateContent(post.content) }}</p>
              <div v-if="post.imageUrl && post.imageUrl.length" class="post-image" :class="{ 'multiple-images': post.imageUrl.length > 1 }">
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
              <div class="sectionname">{{ post.section ? post.section.sectionName : '未分类' }}</div>
              <div class="post-meta">
                <span class="post-time">{{ formatDate(post.postDate) }}</span>
                <div class="interaction">
                  <span class="likes">👍 {{ post.likesCount }}</span>
                  <span class="comments">💬 {{ post.commentsCount }}</span>
                  <span class="favorite-time">收藏于 {{ formatDate(post.favoriteDate || post.postDate) }}</span>
                </div>
              </div>
            </div>
          </template>
          
          <!-- 加载更多按钮 - 根据当前标签页显示不同的加载按钮 -->
          <div v-if="(activeTab === 'posts' && hasMorePosts && !isLoading) || 
                     (activeTab === 'favorites' && hasMoreFavorites && !isLoadingFavorites)" 
               class="load-more-container">
            <button 
              @click="activeTab === 'posts' ? loadMorePosts() : loadMoreFavorites()" 
              class="load-more-button"
            >
              加载更多
            </button>
          </div>
          
          <!-- 加载中提示 - 根据当前标签页显示不同的加载提示 -->
          <div v-if="(activeTab === 'posts' && isLoading) || 
                     (activeTab === 'favorites' && isLoadingFavorites)" 
               class="loading-indicator">
            加载中...
          </div>
          
          <!-- 全部加载完毕提示 - 根据当前标签页显示不同的提示 -->
          <div v-if="(activeTab === 'posts' && !hasMorePosts && userPosts.length > 0) || 
                     (activeTab === 'favorites' && !hasMoreFavorites && userFavorites.length > 0)" 
               class="all-loaded-message">
            已加载全部内容
          </div>
         
        </div>
      </div>
      <RightBlock 
        @post-click="handlePostClick"
      />
    </main>


    <router-view></router-view>
    
    <!-- 添加编辑个人资料弹窗 -->
    <div v-if="showEditProfileDialog" class="message-dialog-overlay">
      <div class="profile-edit-dialog">
        <div class="message-dialog-header">
          <h3>编辑个人资料</h3>
          <button class="close-btn" @click="showEditProfileDialog = false">×</button>
        </div>
        <div class="profile-edit-body">
          <!-- 头像上传区域 -->
          <div class="avatar-upload">
            <div class="avatar-preview">
              <img :src="editProfileForm.imagePreview || userProfile.imageUrl" alt="用户头像" class="edit-avatar">
            </div>
            <div class="avatar-actions">
              <label for="avatar-upload" class="upload-btn">上传头像</label>
              <input 
                type="file" 
                id="avatar-upload" 
                accept="image/*" 
                style="display: none;"
                @change="handleAvatarUpload"
              >
            </div>
          </div>
          
          <!-- 性别选择 -->
          <div class="form-group">
            <label>性别</label>
            <div class="gender-options">
              <label class="gender-option">
                <input type="radio" v-model="editProfileForm.gender" value="male">
                <span>男</span>
              </label>
              <label class="gender-option">
                <input type="radio" v-model="editProfileForm.gender" value="female">
                <span>女</span>
              </label>
              <label class="gender-option">
                <input type="radio" v-model="editProfileForm.gender" value="other">
                <span>其他</span>
              </label>
            </div>
          </div>
          
          <!-- 个人简介 -->
          <div class="form-group">
            <label>个人简介</label>
            <textarea 
              v-model="editProfileForm.bio" 
              placeholder="介绍一下自己吧..." 
              class="bio-input"
            ></textarea>
          </div>
        </div>
        <div class="message-dialog-footer">
          <button class="cancel-btn" @click="showEditProfileDialog = false">取消</button>
          <button class="save-btn" @click="saveProfileChanges" :disabled="isSaving">
            {{ isSaving ? '保存中...' : '保存修改' }}
          </button>
        </div>
      </div>
    </div>
    
    <!-- 使用teleport将弹窗移到body元素底部，避免被其他元素遮挡 -->
    <teleport to="body">
      <!-- 头像裁剪弹窗 - 简单可靠的实现 -->
      <div v-if="showCropDialog" class="crop-overlay">
        <div class="crop-dialog">
          <div class="crop-header">
            <h3>裁剪头像</h3>
            <button @click="cancelCrop" class="close-btn">×</button>
          </div>
          
          <div class="crop-body">
            <!-- 裁剪容器 -->
            <div class="crop-container" 
                 @wheel="handleWheel" 
                 @mousedown="startDrag" 
                 @touchstart="startDrag">
              <!-- 可拖动的图片 -->
              <div class="crop-image-wrapper"
                  :style="{transform: `translate(${imgPosition.x}px, ${imgPosition.y}px) scale(${zoomValue})`}">
                <img :src="cropImageSrc" ref="cropImage" @load="onImageLoaded">
              </div>
              
              <!-- 固定位置的裁剪圆圈 -->
              <div class="crop-circle-mask">
                <div class="crop-circle"></div>
              </div>
            </div>
            
            <!-- 操作提示 -->
            <div class="crop-hint">
              拖动图片调整位置，使用鼠标滚轮放大缩小
            </div>
          </div>
          
          <div class="crop-footer">
            <button @click="cancelCrop" class="cancel-btn">取消</button>
            <button @click="confirmCrop" class="confirm-btn">确认</button>
          </div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, onBeforeUnmount, computed, watch } from 'vue';
import axios from 'axios';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth.js';
import LeftBlock from '../components/LeftBlock.vue';
import RightBlock from '../components/RightBlock.vue';

export default defineComponent({
  name: 'UserCenter',
  components: {
    LeftBlock,
    RightBlock
  },
  setup() {
    // 数据响应式声明
    const route = useRoute();
    const router = useRouter();
    const authStore = useAuthStore();
    
    // 用户资料数据
    const userId = ref(route.params.userId || (authStore.isLoggedIn ? authStore.userInfo.id : null));
    const userProfile = ref({});
    const userPosts = ref([]);
    const userFavorites = ref([]); // 添加用户收藏帖子数组
    const followers = ref(0);
    const following = ref(0);
    const currentPage = ref(1);
    const currentFavoritePage = ref(1); // 添加收藏页码
    const hasMorePosts = ref(true);
    const hasMoreFavorites = ref(true); // 添加收藏是否有更多
    const isLoading = ref(false);
    const isLoadingFavorites = ref(false); // 添加收藏加载状态
    const isFollowing = ref(false);
    const showLoginPopup = ref(false);
    const profileError = ref('');
    const postsError = ref('');
    const favoritesError = ref(''); // 添加收藏错误信息
    const activeTab = ref('posts'); // 添加当前活动标签页
    
    // UI 相关
    const canScrollLeft = ref(false);
    const canScrollRight = ref(false);
    
    // 判断是否是当前登录用户的个人资料
    const isCurrentUser = computed(() => {
      return authStore.isLoggedIn && authStore.userInfo.id === parseInt(userId.value);
    });

    // 添加编辑个人资料相关变量
    const showEditProfileDialog = ref(false);
    const isSaving = ref(false);
    const editProfileForm = ref({
      imagePreview: '',
      imageFile: null,
      bio: '',
      gender: 'other'
    });

    // 裁剪相关变量
    const showCropDialog = ref(false);
    const cropImageSrc = ref('');
    const cropImage = ref(null);
    const zoomValue = ref(1);
    const imgPosition = ref({ x: 0, y: 0 });
    const originalFile = ref(null);
    const isDragging = ref(false);
    const startPosition = ref({ x: 0, y: 0 });

    // 截断标题，限制为20个字
    const truncateTitle = (title) => {
      if (!title) return '';
      return title.length > 20 ? title.substring(0, 20) + '...' : title;
    };

    // 截断内容，限制为50个字
    const truncateContent = (content) => {
      if (!content) return '';
      return content.length > 50 ? content.substring(0, 50) + '...' : content;
    };

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
          }
        } catch (error) {
          console.error('解析JWT令牌出错:', error);
        }
      }
    };

    // 获取用户资料
    const fetchUserProfile = async () => {
      try {
        profileError.value = ''; // 清除先前的错误
        const jwtToken = sessionStorage.getItem('jwtToken');
        const config = {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        };
        
        const response = await axios.get(`/api/users/${userId.value}`, config);
        userProfile.value = response.data;
        
        // 获取关注和粉丝数量
        const statsResponse = await axios.get(`/api/users/${userId.value}/stats`, config);
        followers.value = statsResponse.data.followers || 0;
        following.value = statsResponse.data.following || 0;
        
        // 检查当前用户是否已关注该用户
        if (authStore.isLoggedIn && !isCurrentUser.value) {
          const followResponse = await axios.get(`/api/users/follow/check/${userId.value}`, config);
          isFollowing.value = followResponse.data.following;
        }
      } catch (error) {
        console.error('获取用户资料失败:', error);
        profileError.value = '获取用户资料失败，请稍后再试';
      }
    };
    
    // 获取用户帖子
    const fetchUserPosts = async (reset = true) => {
      try {
        isLoading.value = true;
        postsError.value = ''; // 清除先前的错误
        
        if (reset) {
          userPosts.value = [];
          currentPage.value = 1;
          hasMorePosts.value = true;
        }
        
        const jwtToken = sessionStorage.getItem('jwtToken');
        const config = {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          },
          params: {
            userId: userId.value,
            pageNum: currentPage.value,
            pageSize: 5
          }
        };
        
        const response = await axios.get('/api/posts/by-user', config);
        const pageData = response.data;
        const newPosts = pageData.records || [];
        
        if (reset) {
          userPosts.value = newPosts;
        } else {
          userPosts.value = [...userPosts.value, ...newPosts];
        }
        
        // 判断是否还有更多帖子
        if (currentPage.value >= pageData.pages || newPosts.length === 0) {
          hasMorePosts.value = false;
        }
      } catch (error) {
        console.error('获取用户帖子失败:', error);
        postsError.value = '获取用户帖子失败，请稍后再试';
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
    
    // 关注/取消关注用户
    const toggleFollow = async () => {
      if (!authStore.isLoggedIn) {
        showLoginPopup.value = true;
        return;
      }
      
      try {
        const jwtToken = sessionStorage.getItem('jwtToken');
        const config = {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        };
        
        if (isFollowing.value) {
          await axios.post(`/api/users/unfollow/${userId.value}`, {}, config);
          followers.value--;
        } else {
          await axios.post(`/api/users/follow/${userId.value}`, {}, config);
          followers.value++;
        }
        
        isFollowing.value = !isFollowing.value;
      } catch (error) {
        console.error('关注/取消关注失败:', error);
        
        // 如果API未实现，直接切换状态
        if (isFollowing.value) {
          followers.value--;
        } else {
          followers.value++;
        }
        isFollowing.value = !isFollowing.value;
      }
    };
    
    // 发送私信
    const sendMessage = () => {
      if (!authStore.isLoggedIn) {
        showLoginPopup.value = true;
        return;
      }
      
      // 直接跳转到消息页面，并传递用户ID作为参数
      router.push({
        path: '/messages',
        query: { userId: userId.value }
      });
    };

    // 跳转到帖子详情
    const handlePostClick = (postId) => {
      router.push({
        name: 'PostDetail',
        query: { postId }
      });
    };
    
    // 跳转到用户中心
    const goToUserProfile = (userId) => {
      router.push(`/user/${userId}`);
    };
    
    // 格式化日期
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

    // 初始化编辑表单
    const initEditForm = () => {
      editProfileForm.value = {
        imagePreview: userProfile.value.imageUrl || '',
        imageFile: null,
        bio: userProfile.value.bio || '',
        gender: userProfile.value.gender || 'other'
      };
    };

    // 图片加载完成后自动适应容器大小
    const onImageLoaded = () => {
      if (!cropImage.value) return;
      
      const img = cropImage.value;
      const cropContainer = document.querySelector('.crop-container');
      
      if (!cropContainer) return;
      
      // 计算容器和图片尺寸
      const containerWidth = cropContainer.offsetWidth;
      const containerHeight = cropContainer.offsetHeight;
      
      // 减去一些边距，确保图片不会紧贴容器边缘
      const maxWidth = containerWidth - 40; 
      const maxHeight = containerHeight - 40;
      
      // 计算适合容器的缩放比例
      const widthRatio = maxWidth / img.naturalWidth;
      const heightRatio = maxHeight / img.naturalHeight;
      
      // 选择较小的比例，确保图片完全在容器内
      const fitScale = Math.min(widthRatio, heightRatio);
      
      // 设置初始缩放比例和位置
      zoomValue.value = fitScale;
      
      // 居中图片
      imgPosition.value = {
        x: (containerWidth - img.naturalWidth * fitScale) / 2,
        y: (containerHeight - img.naturalHeight * fitScale) / 2
      };
    };
    
    // 处理头像上传
    const handleAvatarUpload = (event) => {
      const file = event.target.files[0];
      if (!file) return;
      
      // 检查文件类型
      if (!file.type.includes('image/')) {
        alert('请上传图片文件');
        return;
      }
      
      // 储存原始文件
      originalFile.value = file;
      
      // 创建图片预览
      const reader = new FileReader();
      reader.onload = (e) => {
        cropImageSrc.value = e.target.result;
        showCropDialog.value = true;
        
        // 初始缩放比例会在onImageLoaded中设置
      };
      reader.readAsDataURL(file);
    };
    
    // 开始拖动图片
    const startDrag = (event) => {
      event.preventDefault();
      isDragging.value = true;
      
      const pageX = event.pageX || event.touches[0].pageX;
      const pageY = event.pageY || event.touches[0].pageY;
      
      startPosition.value = {
        x: pageX - imgPosition.value.x,
        y: pageY - imgPosition.value.y
      };
      
      document.addEventListener('mousemove', dragMove);
      document.addEventListener('touchmove', dragMove, { passive: false });
      document.addEventListener('mouseup', dragEnd);
      document.addEventListener('touchend', dragEnd);
    };
    
    // 拖动移动
    const dragMove = (event) => {
      if (!isDragging.value) return;
      event.preventDefault();
      
      const pageX = event.pageX || event.touches[0].pageX;
      const pageY = event.pageY || event.touches[0].pageY;
      
      imgPosition.value = {
        x: pageX - startPosition.value.x,
        y: pageY - startPosition.value.y
      };
    };
    
    // 结束拖动
    const dragEnd = () => {
      isDragging.value = false;
      document.removeEventListener('mousemove', dragMove);
      document.removeEventListener('touchmove', dragMove);
      document.removeEventListener('mouseup', dragEnd);
      document.removeEventListener('touchend', dragEnd);
    };
    
    // 取消裁剪
    const cancelCrop = () => {
      showCropDialog.value = false;
      cropImageSrc.value = '';
      originalFile.value = null;
      
      // 移除事件监听器
      document.removeEventListener('mousemove', dragMove);
      document.removeEventListener('touchmove', dragMove);
      document.removeEventListener('mouseup', dragEnd);
      document.removeEventListener('touchend', dragEnd);
    };
    
    // 确认裁剪
    const confirmCrop = () => {
      if (!cropImage.value || !originalFile.value) {
        cancelCrop();
        return;
      }
      
      try {
        // 创建canvas来执行裁剪
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        
        // 裁剪圆的大小和位置
        const circleSize = 150; // 裁剪圆的直径
        canvas.width = circleSize;
        canvas.height = circleSize;
        
        // 创建圆形裁剪区域
        ctx.beginPath();
        ctx.arc(circleSize/2, circleSize/2, circleSize/2, 0, Math.PI * 2);
        ctx.closePath();
        ctx.clip();
        
        // 获取图片和容器
        const img = cropImage.value;
        const container = document.querySelector('.crop-container');
        if (!container) throw new Error('裁剪容器未找到');
        
        // 计算中心点位置（裁剪圆位于容器中心）
        const centerX = container.offsetWidth / 2;
        const centerY = container.offsetHeight / 2;
        
        // 计算从图片上哪个位置裁剪
        // 需要考虑图片的位置和缩放
        const sourceX = (centerX - imgPosition.value.x) / zoomValue.value;
        const sourceY = (centerY - imgPosition.value.y) / zoomValue.value;
        const sourceSize = circleSize / zoomValue.value;
        
        // 执行裁剪绘制
        ctx.drawImage(
          img,
          sourceX - sourceSize/2, // 中心点向左偏移半个裁剪尺寸
          sourceY - sourceSize/2, // 中心点向上偏移半个裁剪尺寸
          sourceSize,
          sourceSize,
          0, 0, circleSize, circleSize
        );
        
        // 转换为blob
        canvas.toBlob((blob) => {
          if (!blob) {
            alert('裁剪失败，请重试');
            return;
          }
          
          // 创建File对象
          const croppedFile = new File([blob], originalFile.value.name, {
            type: 'image/jpeg',
            lastModified: Date.now()
          });
          
          // 设置预览和文件对象
          const reader = new FileReader();
          reader.onload = (e) => {
            editProfileForm.value.imagePreview = e.target.result;
            editProfileForm.value.imageFile = croppedFile;
            showCropDialog.value = false;
          };
          reader.readAsDataURL(blob);
        }, 'image/jpeg', 0.9);
      } catch (error) {
        console.error('裁剪失败:', error);
        alert('裁剪失败: ' + error.message);
        cancelCrop();
      }
    };

    // 保存个人资料修改 - 修改为先上传图片再保存资料
    const saveProfileChanges = async () => {
      if (isSaving.value) return;
      
      try {
        isSaving.value = true;
        
        const jwtToken = sessionStorage.getItem('jwtToken');
        if (!jwtToken) {
          alert('请先登录');
          return;
        }
        
        let imageUrl = userProfile.value.imageUrl;
        
        // 如果有新上传的图片，先上传图片
        if (editProfileForm.value.imageFile) {
          const formData = new FormData();
          formData.append('image', editProfileForm.value.imageFile);
          
          // 修改为POST multipart/form-data请求
          const imageUploadConfig = {
            headers: {
              'Authorization': `Bearer ${jwtToken}`,
              'Content-Type': 'multipart/form-data'
            }
          };
          
          // 上传图片并获取URL
          const uploadResponse = await axios.post(
            `/api/users/upload-avatar`,
            formData,
            imageUploadConfig
          );
          
          // 获取上传后的图片URL
          imageUrl = uploadResponse.data.imageUrl;
        }
        
        // 构建要更新的用户数据
        const updateData = {
          bio: editProfileForm.value.bio,
          gender: editProfileForm.value.gender,
          imageUrl: imageUrl // 使用上传后的图片URL或原来的URL
        };
        
        // 调用更新接口
        await axios.put(
          `/api/users/${userId.value}/profile`, 
          updateData,
          {
            headers: {
              'Authorization': `Bearer ${jwtToken}`,
              'Content-Type': 'application/json'
            }
          }
        );
        
        // 更新成功后更新本地用户数据和全局authStore
        userProfile.value = {
          ...userProfile.value,
          ...updateData
        };
        
        // 同时更新全局authStore中的用户信息 - 确保头像URL在页眉更新
        if (isCurrentUser.value && authStore.isLoggedIn) {
          // 更新authStore中的用户头像
          authStore.updateUserAvatar(imageUrl);
        }
        
        showEditProfileDialog.value = false;
        alert('个人资料更新成功');
      } catch (error) {
        console.error('更新个人资料失败:', error);
        
        // 根据错误类型提供详细的错误信息
        if (error.response) {
          // 服务器返回了错误状态码
          const status = error.response.status;
          if (status === 413) {
            alert('头像文件过大！即使压缩后仍超过服务器允许的最大上传限制(2MB)，请选择更小的图片或进一步压缩后再试。');
          } else if (status === 401) {
            alert('登录已过期，请重新登录后再试。');
          } else if (status === 403) {
            alert('您没有权限执行此操作。');
          } else if (status === 404) {
            alert('用户资料不存在或已被删除。');
          } else {
            // 其他错误状态码
            const message = error.response.data?.message || '服务器返回错误';
            alert(`更新个人资料失败: ${message} (错误码: ${status})`);
          }
        } else if (error.request) {
          // 请求发出但没有收到响应
          alert('无法连接到服务器，请检查您的网络连接后再试。');
        } else {
          // 请求设置时出错
          alert(`更新个人资料失败: ${error.message}`);
        }
      } finally {
        isSaving.value = false;
      }
    };

    // 更新用户头像
    const updateAvatar = async (imageUrl) => {
      try {
        userProfile.value.imageUrl = imageUrl;
        
        // 如果是当前登录用户，同时更新authStore中的头像
        if (authStore.isLoggedIn && authStore.userInfo && authStore.userInfo.id === userProfile.value.id) {
          authStore.updateUserAvatar(imageUrl);
        }
        
        // 其他处理代码...
      } catch (error) {
        console.error('更新头像失败:', error);
      }
    };

    // 使用鼠标滚轮控制缩放
    const handleWheel = (event) => {
      event.preventDefault();
      
      if (!cropImage.value) return;
      
      // 获取鼠标相对于容器的位置
      const container = document.querySelector('.crop-container');
      if (!container) return;
      
      const rect = container.getBoundingClientRect();
      const mouseX = event.clientX - rect.left;
      const mouseY = event.clientY - rect.top;
      
      // 计算鼠标在图片坐标系中的位置
      const imgX = (mouseX - imgPosition.value.x) / zoomValue.value;
      const imgY = (mouseY - imgPosition.value.y) / zoomValue.value;
      
      // 定义缩放因子(10%的增减)
      const zoomFactor = event.deltaY < 0 ? 1.1 : 0.9;
      
      // 限制缩放范围在0.01到30之间
      const newZoom = Math.max(0.05, Math.min(30, zoomValue.value * zoomFactor));
      
      // 更新位置，保持鼠标指向的点不变
      imgPosition.value = {
        x: mouseX - imgX * newZoom,
        y: mouseY - imgY * newZoom
      };
      
      // 更新缩放值
      zoomValue.value = newZoom;
    };

    // 切换标签页
    const switchTab = (tab) => {
      if (activeTab.value === tab) return;
      
      activeTab.value = tab;
      
      if (tab === 'favorites' && userFavorites.value.length === 0) {
        // 首次切换到收藏标签时加载数据
        fetchUserFavorites();
      }
    };
    
    // 获取用户收藏的帖子
    const fetchUserFavorites = async (reset = true) => {
      try {
        isLoadingFavorites.value = true;
        favoritesError.value = ''; // 清除先前的错误
        
        if (reset) {
          userFavorites.value = [];
          currentFavoritePage.value = 1;
          hasMoreFavorites.value = true;
        }
        
        const jwtToken = sessionStorage.getItem('jwtToken') || localStorage.getItem('jwtToken');
        const config = {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          },
          params: {
            userId: userId.value,
            pageNum: currentFavoritePage.value,
            pageSize: 5
          }
        };
        
        const response = await axios.get('/api/favorites/by-user', config);
        console.log('收藏的帖子API响应:', response.data);
        
        // 处理API响应数据
        let responseData = response.data;
        // 如果响应包含嵌套的data对象且有records字段
        if (responseData.data && responseData.data.records) {
          responseData = responseData.data;
        }
        
        const newFavorites = responseData.records || [];
        console.log('处理后的收藏帖子:', newFavorites);
        
        if (reset) {
          userFavorites.value = newFavorites;
        } else {
          userFavorites.value = [...userFavorites.value, ...newFavorites];
        }
        
        // 判断是否还有更多收藏
        if (responseData.pages) {
          hasMoreFavorites.value = currentFavoritePage.value < responseData.pages;
        } else {
          hasMoreFavorites.value = newFavorites.length >= 5;
        }
      } catch (error) {
        console.error('获取用户收藏失败:', error);
        favoritesError.value = '获取用户收藏失败，请稍后再试';
      } finally {
        isLoadingFavorites.value = false;
      }
    };
    
    // 加载更多收藏
    const loadMoreFavorites = async () => {
      if (isLoadingFavorites.value || !hasMoreFavorites.value) return;
      
      currentFavoritePage.value++;
      await fetchUserFavorites(false);
    };

    // 监听路由参数变化
    watch(() => route.params.userId, (newUserId) => {
      if (newUserId && newUserId !== userId.value) {
        userId.value = newUserId;
        // 重新加载用户数据
        fetchUserProfile();
        fetchUserPosts();
        
        // 重置收藏相关状态
        userFavorites.value = [];
        currentFavoritePage.value = 1;
        hasMoreFavorites.value = true;
        
        // 重置为默认标签页
        activeTab.value = 'posts';
      }
    });

    // 组件挂载时获取数据
    onMounted(() => {
      // 检查用户是否已登录
      checkJwtExpiration();
      
      // 如果已登录且没有提供userId，使用当前用户的ID
      if (!userId.value && authStore.isLoggedIn) {
        userId.value = authStore.userInfo.id;
      }
      
      // 获取用户资料和帖子
      if (userId.value) {
        fetchUserProfile().then(() => {
          // 获取到用户资料后初始化编辑表单
          initEditForm();
        });
        fetchUserPosts();
      }
      
      // 添加全局滚轮事件监听
      window.addEventListener('wheel', handleGlobalScroll);
    });

    // 卸载生命周期钩子
    onBeforeUnmount(() => {
      // 移除全局滚轮事件监听
      window.removeEventListener('wheel', handleGlobalScroll);
      
      // 清理裁剪相关事件
      document.removeEventListener('mousemove', dragMove);
      document.removeEventListener('touchmove', dragMove);
      document.removeEventListener('mouseup', dragEnd);
      document.removeEventListener('touchend', dragEnd);
    });
    
    return {
      authStore,
      userId,
      userProfile,
      userPosts,
      userFavorites, // 添加收藏数据
      activeTab, // 添加当前标签
      followers,
      following,
      isCurrentUser,
      isFollowing,
      isLoading,
      isLoadingFavorites, // 添加收藏加载状态
      hasMorePosts,
      hasMoreFavorites, // 添加收藏是否有更多
      profileError,
      postsError,
      favoritesError, // 添加收藏错误信息
      canScrollLeft,
      canScrollRight,
      handlePostClick,
      goToUserProfile,
      loadMorePosts,
      loadMoreFavorites, // 添加加载更多收藏
      switchTab, // 添加切换标签方法
      toggleFollow,
      sendMessage,
      formatDate,
      handleGlobalScroll,
      showEditProfileDialog,
      isSaving,
      editProfileForm,
      initEditForm,
      handleAvatarUpload,
      saveProfileChanges,
      updateAvatar,
      showCropDialog,
      cropImageSrc,
      cropImage,
      zoomValue,
      imgPosition,
      originalFile,
      isDragging,
      startPosition,
      onImageLoaded,
      startDrag,
      cancelCrop,
      confirmCrop,
      handleWheel,
      truncateTitle,
      truncateContent
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
  overflow-y: auto;
  align-self: flex-start; /* 保持顶部对齐 */
  background-color: #f7f8f9;
}

.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px; /* 与头部保持10px间距 */
}

.right-block {
  width: 350px;
  margin-left: 20px;
  position: sticky;
  top: 85px;
  background-color: #ffffff;
  padding: 20px;
  border-radius: 8px;
}

.left-block,
.right-block,
.post-wrapper {
  overflow: visible !important;
}

.post-wrapper {
  width: 610px;
  overflow-y: auto; /* 恢复垂直滚动 */
  overflow-x: hidden; /* 隐藏横向滚动 */
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

/* 用户信息容器 */
.user-info-container {
  background-color: transparent !important;
  box-shadow: none !important;
  height: auto !important;
  padding: 0 !important;
  margin-bottom: 15px;
}

/* 用户信息卡片样式 */
.profile-card {
  width: 100%;
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 15px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  box-sizing: border-box;
  transition: transform 0.2s;
}

.profile-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

.profile-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.profile-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #f0f2f5;
  margin-right: 25px;
}

.profile-info {
  flex: 1;
}

.profile-info h2 {
  margin: 0 0 10px 0;
  font-size: 22px;
  color: #333;
}

.profile-stats {
  display: flex;
  gap: 20px;
}

.stats-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stats-value {
  font-weight: 600;
  font-size: 18px;
  color: #333;
}

.stats-label {
  font-size: 13px;
  color: #777;
}

.profile-actions {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.profile-actions button {
  padding: 8px 15px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.edit-profile-btn {
  background-color: #f0f2f5;
  color: #333;
}

.edit-profile-btn:hover {
  background-color: #e4e6e9;
}

.follow-btn {
  background-color: #409EFF;
  color: white;
}

.follow-btn:hover {
  background-color: #66b1ff;
}

.follow-btn.following {
  background-color: #f0f2f5;
  color: #333;
}

.message-btn {
  background-color: #f0f2f5;
  color: #333;
}

.message-btn:hover {
  background-color: #e4e6e9;
}

.profile-bio {
  font-size: 14px;
  color: #555;
  line-height: 1.5;
}

/* 帖子标题样式 */
.post-section-title {
  margin-bottom: 15px;
}

.post-section-title h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
  padding-left: 10px;
  border-left: 3px solid #409EFF;
}

/* 帖子样式 */
.post-item {
  width: 100%;
  background-color: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 15px;
  position: relative;
  cursor: pointer;
  transition: transform 0.2s;
  height: 380px;
  padding-top: 50px; /* 为顶部用户信息留出空间 */
  box-sizing: border-box; /* 确保padding计入宽度 */
}

.post-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

.post-item .user-info {
  display: flex;
  align-items: center;
  position: absolute;
  top: 15px;
  left: 20px;
  right: 20px;
}

.post-item h2 {
  margin: 10px 0 10px 0;
  font-size: 16px;
  color: #333;
}

.post-item p {
  font-size: 13px;
  line-height: 1.6;
  margin-bottom: 40px; /* 为底部元素留出空间 */
  color: #666;
}

/* 图片样式 */
.post-image {
  margin-top: 10px;
  margin-bottom: 40px; /* 增加底部间距，避免与底部元素重叠 */
}

/* 单张图片样式 */
.post-image img.single-image {
  max-width: 60%;
  max-height: 190px;
  border-radius: 4px;
  display: block;
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

/* 无内容提示 */
.no-posts {
  background-color: white;
  padding: 30px;
  text-align: center;
  color: #999;
  border-radius: 8px;
  font-size: 14px;
  margin-bottom: 15px;
}

/* 错误提示 */
.error-card,
.error-message {
  width: 100%;
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 15px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  text-align: center;
  color: #f56c6c;
  box-sizing: border-box;
}

.error-icon {
  display: inline-block;
  width: 24px;
  height: 24px;
  line-height: 24px;
  text-align: center;
  border-radius: 50%;
  background-color: #f56c6c;
  color: white;
  font-weight: bold;
  margin-right: 8px;
}

/* 分类标签位置 */
.sectionname {
  display: inline-block;
  padding: 3px 8px;
  background-color: #f3f4f5;
  border-radius: 4px;
  font-size: 12px;
  position: absolute;
  left: 20px;
  bottom: 35px; /* 位于底部上方 */
  max-width: 60px;
  text-align: center;
}

/* 底部信息显示 */
.post-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: absolute;
  bottom: 15px;
  left: 20px;
  right: 20px;
  font-size: 12px;
  color: #999;
}

.post-time {
  font-size: 12px;
  color: #999;
}

.interaction {
  display: flex;
  gap: 15px;
}

.likes, .comments {
  cursor: pointer;
  transition: color 0.2s;
  font-size: 13px;
}

.likes:hover, .comments:hover {
  color: #409EFF;
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

/* 头像与用户名 */
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  margin-right: 10px;
  border: 2px solid #eee;
}

.username {
  font-weight: 500;
  color: #333;
  font-size: 14px;
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
  padding: 20px;
  color: #666;
  font-size: 14px;
}

.all-loaded-message {
  color: #999;
  font-style: italic;
}

/* 添加编辑个人资料弹窗样式 */
.profile-edit-dialog {
  width: 500px;
  background-color: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.profile-edit-body {
  padding: 25px;
}

.avatar-upload {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 25px;
}

.avatar-preview {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid #f0f2f5;
}

.edit-avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.upload-btn {
  display: inline-block;
  padding: 8px 15px;
  background-color: #409EFF;
  color: white;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  text-align: center;
  transition: background-color 0.3s;
}

.upload-btn:hover {
  background-color: #66b1ff;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.gender-options {
  display: flex;
  gap: 20px;
}

.gender-option {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.gender-option input {
  margin-right: 8px;
}

.bio-input {
  width: 100%;
  height: 100px;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  resize: vertical;
  font-size: 14px;
  font-family: inherit;
}

.save-btn {
  background-color: #409EFF;
  color: white;
}

.save-btn:hover:not(:disabled) {
  background-color: #66b1ff;
}

.save-btn:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

/* 简单直接的裁剪样式 */
.crop-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999; /* 增大z-index确保在最上层 */
}

.crop-dialog {
  width: 500px;
  background-color: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.crop-header {
  padding: 15px 20px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.crop-header h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 22px;
  color: #999;
  cursor: pointer;
}

.crop-body {
  padding: 20px;
}

.crop-container {
  position: relative;
  width: 100%;
  height: 350px;
  background-color: #f0f0f0;
  overflow: hidden;
  margin-bottom: 20px;
}

.crop-image-wrapper {
  position: absolute;
  cursor: grab;
  transform-origin: 0 0;
  will-change: transform;
}

.crop-image-wrapper:active {
  cursor: grabbing;
}

.crop-image-wrapper img {
  display: block;
  max-width: none;
  max-height: none;
}

.crop-circle-mask {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  display: flex;
  justify-content: center;
  align-items: center;
}

.crop-circle {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  border: 2px dashed white;
  box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.5);
}

.crop-hint {
  text-align: center;
  font-size: 13px;
  color: #666;
  margin-top: 15px;
}

.crop-footer {
  padding: 15px 20px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.crop-footer button {
  padding: 8px 20px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  border: none;
}

.cancel-btn {
  background-color: #f5f5f5;
  color: #333;
}

.confirm-btn {
  background-color: #409EFF;
  color: white;
}

/* 添加帖子标题和内容的截断样式 (与 Index.vue 一致) */
.post-title {
  margin: 0 0 10px 0;
  font-size: 18px; /* 或保持个人中心原有的标题大小 */
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-weight: bold;
}

.post-content {
  font-size: 14px;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2; /* 限制最多显示2行 */
  line-clamp: 2;
  -webkit-box-orient: vertical;
  margin-bottom: 10px;
  line-height: 1.5;
}

/* 确保个人中心 .post-item 样式与截断兼容 */
.post-item:not(:first-child) {
  position: relative;
  padding-top: 50px; /* 保持原有内边距 */
  padding-bottom: 50px; /* 增加底部内边距以容纳元数据 */
}

/* 添加标签页样式 */
.post-tabs {
  display: flex;
  border-bottom: 1px solid #eaeaea;
  margin-bottom: 15px;
}

.post-tab {
  padding: 10px 15px;
  cursor: pointer;
  font-size: 15px;
  color: #606266;
  transition: all 0.3s;
  position: relative;
}

.post-tab:hover {
  color: #409EFF;
}

.post-tab.active {
  color: #409EFF;
  font-weight: 500;
}

.post-tab.active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  width: 100%;
  height: 2px;
  background-color: #409EFF;
}

.post-section-title h3 {
  display: none; /* 隐藏原有标题 */
}

/* 收藏时间样式 */
.favorite-time {
  font-size: 12px;
  color: #999;
  margin-left: 15px;
}
</style>    