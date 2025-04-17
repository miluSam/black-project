<template>
  <div class="main-layout">
    <!-- 头部 -->
    <header class="header">
      <!-- Left Section Wrapper -->
      <div class="header-section left">
        <div class="logo">
          <img src="https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/blackbox.png" alt="Logo" />
        </div>
      </div>

      <!-- Center Section (Search Bar) -->
      <div class="search-bar">
        <input type="text" v-model="searchQuery" placeholder="搜索帖子/游戏" @keyup.enter="search" />
        <i class="el-icon-search" @click="search"></i>
      </div>

      <!-- Right Section Wrapper -->
      <div class="header-section right">
        <div class="login">
          <!-- 根据登录状态显示登录按钮或用户头像和用户名 -->
          <button v-if="!isLoggedIn" @click="showLoginPopup = true">登录</button>
          <div v-if="isLoggedIn" class="userinfo" @click="toggleDropdown">
            <img :src="userInfo.avatar" alt="用户头像" class="avatar" />
            <span class="username">{{ userInfo.username }}</span>
            <div v-if="isDropdownVisible" class="dropdown">
              <div class="dropdown-item" @click="goToUserProfile">用户中心</div>
              <div class="dropdown-item" @click="handleLogout">退出登录</div>
            </div>
          </div>
        </div>
      </div>
      <!-- 登录弹窗 -->
    <div v-if="showLoginPopup"  class="login-popup">
      <div class="popup-content">
        <span class="close" @click="showLoginPopup = false">&times;</span>
        <h2>密码登录</h2>
        <input type="text" v-model="username" placeholder="账号" />
        <input type="password" v-model="password" placeholder="密码" />
        <div class="captcha-section">
      <div class="captcha-image-wrapper">
        <img 
          :src="captchaImage" 
          alt="验证码"
          @click="getCaptcha"
          class="captcha-image"
          v-if="captchaImage"
        >
        <div v-if="isCaptchaLoading" class="captcha-loading">
          加载中...
        </div>
      </div>
      <input
        type="text"
        v-model="userCaptcha"
        placeholder="输入验证码"
        class="captcha-input"
      >
      <button 
        @click="getCaptcha"
        class="refresh-button"
        :disabled="isCaptchaLoading"
      >
        {{ isCaptchaLoading ? '加载中...' : '刷新验证码' }}
      </button>
    </div>
        <button  @click="handleLogin">登录</button>
        <button @click="handleRegister">注册</button>
      </div>
    </div>
    </header>
    <main>
      <div class="left-block">
        <!-- 侧边栏导航 -->
        <div @click="goToPage('creator-center')">创作者中心</div>
        <div @click="goToPage('developer-center')">开发者中心</div>
      </div>
      <!-- 主要内容区域 -->
      <router-view :search-query="searchQuery" :is-logged-in="isLoggedIn"></router-view>
    </main>
     <!-- 未登录时的登录提示块 -->
  <div v-if="!authStore.isLoggedIn" class="post-item login-prompt">
    <div class="login-prompt-content">
      <p>登录查看更多精彩内容</p>
      <button @click="showLoginPopup = true">登录</button>
    </div>
  </div>
  </div>
  
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js';
import axios from 'axios'
const router = useRouter()
const authStore = useAuthStore()

const showLoginPopup = ref(false)
const username = ref('')
const password = ref('')
const captchaImage = ref('')
const captchaKey = ref('')
const userCaptcha = ref('')
const isCaptchaLoading = ref(false)
const isDropdownVisible = ref(false)
const searchQuery = ref('');

watch(showLoginPopup, (newValue) => {
  if (newValue) {
    getCaptcha() // 当弹窗显示时自动获取验证码
  }
})
 // 切换下拉菜单方法
 const toggleDropdown = () => {
      isDropdownVisible.value =!isDropdownVisible.value;
    };


  // 搜索方法
  const search = () => {
    if (!searchQuery.value.trim()) return;
    
    // 保存搜索关键词到localStorage以便首页获取
    localStorage.setItem('searchKeyword', searchQuery.value);
    
    // 跳转到首页并带上搜索标识
    router.push({ 
      path: '/', 
      query: { 
        search: 'true',
        keyword: searchQuery.value
      } 
    });
  };
// 注册方法
const handleRegister = () => {
      console.log('执行注册操作');
      // 在这里执行注册操作
      showLoginPopup.value = false;
    };
// 获取验证码方法
const getCaptcha = async () => {
  try {
    isCaptchaLoading.value = true
    const response = await axios.get('/api/captcha', {
      responseType: 'blob'
    })
    
    const uuid = response.headers['captcha-key']
    captchaKey.value = uuid
    
    const blob = new Blob([response.data], { type: 'image/jpeg' })
    captchaImage.value = URL.createObjectURL(blob)
  } catch (error) {
    console.error('获取验证码失败:', error)
  } finally {
    isCaptchaLoading.value = false
  }
}
// 退出登录方法
const handleLogout = () => {
  authStore.logout(); // 调用 logout 方法
  router.push({ name: 'Index' }); // 退出后跳转到首页
};
// 登录方法
const handleLogin = async () => {
  try {
    const user = {
      username: username.value,
      password: password.value,
      captcha: userCaptcha.value,
      captchaKey: captchaKey.value
    }
    
    const response = await axios.post('/api/login', user)
    
    if (response.data.code === 200) {
      // 确保存储 token
      const token = response.data.data.token;
      sessionStorage.setItem('jwtToken', token);
      
      // 更新 Pinia 状态
      authStore.login({
        ...response.data.data,
        token // 确保 token 也被存储在 userInfo 中
      });
      
      showLoginPopup.value = false
      // 清理表单
      username.value = ''
      password.value = ''
      userCaptcha.value = ''
      captchaKey.value = ''
    }
  } catch (error) {
    console.error('登录失败:', error)
    getCaptcha()
  }
}

const isLoggedIn = computed(() => authStore.isLoggedIn);
const userInfo = computed(() => authStore.userInfo);

const goToPage = (path) => {
  router.push({ path: `/${path}` });
};

const goToUserProfile = () => {
  if (isLoggedIn.value && userInfo.value.id) {
    router.push(`/user/${userInfo.value.id}`);
  }
};

</script>

<style>
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background-color: #f7f8f9;
}
</style>

<style scoped>
/* 包裹样式规则 */
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background-color: #e9e9e9; /* 调整背景颜色 */
  overflow-x: hidden;
  overflow-y: auto;
}


.header {
  background-color: #ffffff;
  height: 65px;
  display: flex;
  align-items: center;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 100;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

/* New Header Section Wrappers */
.header-section {
  display: flex;
  align-items: center;
  flex: 1 0 0; /* Let left and right sections take equal space */
}

.header-section.left {
  justify-content: flex-start; /* Align logo to the left within its section */
  padding-left: 200px; /* Add padding to push logo from edge */
}

.header-section.right {
  justify-content: flex-end; /* Align login to the right within its section */
  padding-right: 200px; /* Add padding to push login from edge */
}

.logo img {
  height: 26px;
  width: auto;
  display: block; /* Added previously, keep it */
}

.search-bar {
  max-width: 610px; /* Use max-width to constrain */
  width: 610px; /* Or fixed width as original */
  margin: 0 20px; /* Add some margin to prevent touching sections */
  flex-shrink: 0; /* Prevent shrinking if space is tight */
  position: relative;
}

.search-bar input {
  width: 100%; /* Input takes width of .search-bar container */
  padding: 12px 30px 12px 15px;
  border-radius: 8px;
  border: none;
  border: 1px solid #c9ced2;
  background-color: #fafbfc;
  box-sizing: border-box;
}

.search-bar input:focus {
  outline: none;
}

.search-bar i {
  position: absolute;
  right: 15px; /* Adjusted from -40px to be inside padding */
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  color: #909399; /* Added previously */
}

.login {
  display: flex;
  align-items: center;
}

.login button {
  background-color: #32373c;
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 8px ;
  cursor: pointer;
  height: 35px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login button:hover {
  background-color: #2a3034;
}
.userinfo {
  display: flex;
  align-items: center;
  position: relative;
}
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
  white-space: nowrap; /* Added previously */
}
/* 登录弹窗样式 */
.login-popup {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.popup-content {
  background-color: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
  position: relative;
}

.close {
  position: absolute;
  top: 10px;
  right: 10px;
  font-size: 24px;
  cursor: pointer;
}

.popup-content input {
  width: 95%;
  padding: 10px;
  margin-bottom: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.popup-content input:focus {
  outline: none;
}

.popup-content button {
  width: 100%;
  padding: 10px;
  margin-bottom: 10px;
  background-color: #32373c;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.popup-content button:hover {
  background-color: #2a3034;
}
/* 添加验证码区域样式 */
.captcha-section {
  margin: 15px 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.captcha-image-wrapper {
  position: relative;
  width: 120px;
  height: 40px;
}

.captcha-image {
  width: 100%;
  height: 100%;
  cursor: pointer;
  border: 1px solid #ddd;
}

.captcha-loading {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.captcha-input {
  flex: 1;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.refresh-button {
  max-width: 25%;
  max-height: 10%;
  padding: 8px 12px;
  background-color: #f0f0f0;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.refresh-button:hover {
  background-color: #e0e0e0;
}

.refresh-button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
/* 下拉菜单样式 */
.dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  padding: 5px 0;
  z-index: 1;
}

.dropdown-item {
  padding: 8px 16px;
  cursor: pointer;
  white-space: nowrap;
}

.dropdown-item:hover {
  background-color: #f0f0f0;
}
/* 登录提示块样式 */
.login-prompt {
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f7f8f9;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  max-width: 85%;
}

.login-prompt-content p {
  font-size: 16px;
  margin-bottom: 10px;
}

.login-prompt-content button {
  padding: 10px 20px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.login-prompt-content button:hover {
  background-color: #66b1ff;
}
</style>    
