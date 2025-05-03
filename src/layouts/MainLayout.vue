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

      <!-- Center Section (Search Bar or Page Title) -->
      <div class="center-section">
        <!-- 动态页面标题 -->
        <h1 v-if="currentPageType !== 'default'" class="page-title">{{ currentPageTitle }}</h1>
        
        <!-- 在私信页面显示标题 -->
        <h1 v-else-if="isMessagesPage" class="page-title">私信</h1>
        
        <!-- 在用户个人中心页面显示标题 -->
        <h1 v-else-if="isUserProfilePage" class="page-title">个人中心</h1>
        
        <!-- 在创作者中心页面显示标题 -->
        <h1 v-else-if="isCreatorCenterPage" class="page-title">创作者中心</h1>
        
        <!-- 在其他页面显示搜索框 -->
        <div v-else class="search-bar">
          <input type="text" v-model="searchQuery" placeholder="搜索帖子/游戏" @keyup.enter="search" />
          <i class="el-icon-search" @click="search"></i>
        </div>
      </div>

      <!-- Right Section Wrapper -->
      <div class="header-section right">
        <div class="login">
          <!-- 根据登录状态显示登录按钮或用户头像和用户名 -->
          <button v-if="!isLoggedIn" @click="showLoginPopup = true">登录</button>
          <div v-if="isLoggedIn" class="userinfo" @click.stop="toggleDropdown">
            <img :src="userInfo.avatar" alt="用户头像" class="avatar" />
            <span class="username">{{ userInfo.username }}</span>
            <div class="message-icon-container">
              <el-icon class="message-icon" @click.stop="goToMessagePage" title="私信">
                <Message />
              </el-icon>
              <UnreadMessageBadge />
            </div>
            <div v-if="isDropdownVisible" class="dropdown">
              <div class="dropdown-item" @click.stop="goToUserProfile">用户中心</div>
              <div class="dropdown-item" @click.stop="handleLogout">退出登录</div>
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
        <input type="password" v-model="password" placeholder="密码" @keyup.enter="handleLogin" />
        <div class="remember-me">
          <button type="button"
                  :class="['remember-btn', { active: rememberMe }]"
                  @click="rememberMe = !rememberMe">
            {{ rememberMe ? '已记住' : '记住我' }}
          </button>
        </div>
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
        @keyup.enter="handleLogin"
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
  <!-- 注册弹窗 -->
  <div v-if="showRegisterPopup" class="register-popup-overlay">
    <div class="register-popup-content">
      <span class="close" @click="cancelRegister">&times;</span>
      <h2>账号注册</h2>
      <input v-model="regUsername" placeholder="用户名" />
      <input type="password" v-model="regPassword" placeholder="密码" />
      <input type="email" v-model="regEmail" placeholder="邮箱" />
      <div v-if="regEmail && !isEmailValid" class="error-msg">请输入有效的邮箱地址</div>
      <input type="tel" v-model="regPhoneNumber" placeholder="手机号" />
      <div v-if="regPhoneNumber && !isPhoneValid" class="error-msg">请输入有效的手机号</div>
      <div class="cf-turnstile" data-sitekey="0x4AAAAAABZax1N5QEqOLkei" data-callback="onTurnstileSuccess"></div>
      <div v-if="loadingTurnstile" class="turnstile-loading">正在加载人机验证，请稍候...</div>
      <button @click="handleRegisterSubmit"
              :disabled="loadingTurnstile || !regUsername || !regPassword || !isEmailValid || !isPhoneValid || !regTurnstileToken">
        注册
      </button>
    </div>
  </div>
  </div>
  
</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js';
import axios from 'axios'
import { Message } from '@element-plus/icons-vue'
import UnreadMessageBadge from '@/components/UnreadMessageBadge.vue';

const router = useRouter()
const authStore = useAuthStore()

const showLoginPopup = ref(false)
const showRegisterPopup = ref(false)
const turnstileWidgetId = ref(null)
const username = ref('')
const password = ref('')
const regUsername = ref('')
const regPassword = ref('')
const regEmail = ref('')
const regPhoneNumber = ref('')
const regTurnstileToken = ref('')
const captchaImage = ref('')
const captchaKey = ref('')
const userCaptcha = ref('')
const isCaptchaLoading = ref(false)
const rememberMe = ref(false)
const isDropdownVisible = ref(false)
const searchQuery = ref('');
const loadingTurnstile = ref(false);

// 验证邮箱格式
const isEmailValid = computed(() => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(regEmail.value));
// 验证手机号格式（中国手机号）
const isPhoneValid = computed(() => /^1[3-9]\d{9}$/.test(regPhoneNumber.value));

// 注册回调，Cloudflare Turnstile 成功后调用
window.onTurnstileSuccess = (token) => {
  regTurnstileToken.value = token;
}

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
  // 打开注册弹窗
  showLoginPopup.value = false;
  showRegisterPopup.value = true;
};

const cancelRegister = () => {
  showRegisterPopup.value = false;
}

// 获取验证码方法 (使用 fetch 避免 blob responseType 导致的 devtools 错误)
const getCaptcha = async () => {
  try {
    isCaptchaLoading.value = true;
    const response = await fetch('/api/captcha');
    const blob = await response.blob();
    const uuid = response.headers.get('captcha-key');
    captchaKey.value = uuid;
    captchaImage.value = URL.createObjectURL(blob);
  } catch (error) {
    console.error('获取验证码失败:', error);
  } finally {
    isCaptchaLoading.value = false;
  }
};

// 退出登录方法
const handleLogout = () => {
  // 关闭下拉菜单
  isDropdownVisible.value = false;
  // 执行退出操作
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
      captchaKey: captchaKey.value,
      rememberMe: rememberMe.value
    }
    
    const response = await axios.post('/api/login', user)
    
    if (response.data.code === 200) {
      // 确保存储 token
      const token = response.data.data.token;
      if (rememberMe.value) {
        localStorage.setItem('jwtToken', token);
      } else {
        sessionStorage.setItem('jwtToken', token);
      }
      
      // 更新 Pinia 状态
      authStore.login({
        ...response.data.data,
        token // 确保 token 也被存储在 userInfo 中
      });
      
      showLoginPopup.value = false
      // 清理表单
      username.value = ''
      password.value = ''
      rememberMe.value = false
      userCaptcha.value = ''
      captchaKey.value = ''
    }
  } catch (error) {
    console.error('登录失败:', error)
    getCaptcha()
  }
}

// 提交注册
const handleRegisterSubmit = async () => {
  try {
    // 注册并获取 token
    const resp = await axios.post('/api/users/register', {
      username: regUsername.value,
      password: regPassword.value,
      email: regEmail.value,
      phoneNumber: regPhoneNumber.value,
      turnstileToken: regTurnstileToken.value
    });
    // 假设后端返回 { userId, username, token }
    const { token, userId, username } = resp.data.data;
    // 存储并更新登录状态
    sessionStorage.setItem('jwtToken', token);
    authStore.login({ id: userId, username: username, token });
    window.alert('注册成功，已为您自动登录');
    showRegisterPopup.value = false;
  } catch (error) {
    console.error('注册失败', error);
    const status = error.response?.status;
    const msg = error.response?.data?.message;
    if (status === 400 && msg) {
      // 精确返回后端的错误信息
      window.alert(msg);
      // 重置 Turnstile，允许重新验证
      if (window.turnstile && turnstileWidgetId.value !== null) {
        window.turnstile.reset(turnstileWidgetId.value);
      }
      regTurnstileToken.value = '';
    } else {
      // 其他异常，提示通用信息
      window.alert('注册失败，请稍后重试');
    }
  }
};

const isLoggedIn = computed(() => authStore.isLoggedIn);
const userInfo = computed(() => authStore.userInfo);

const goToPage = (path) => {
  router.push({ path: `/${path}` });
};

const goToUserProfile = () => {
  if (isLoggedIn.value && userInfo.value.id) {
    // 关闭下拉菜单
    isDropdownVisible.value = false;
    
    // 获取当前路由和目标路由
    const currentRoute = router.currentRoute.value;
    const targetPath = `/user/${userInfo.value.id}`;
    
    // 检查是否已经在用户页面，但查看的是不同用户
    if (currentRoute.path.startsWith('/user/') && currentRoute.path !== targetPath) {
      // 强制刷新当前组件
      router.replace({ path: '/temp-redirect' }).then(() => {
        router.replace({ path: targetPath });
      });
    } else {
      // 普通跳转
      router.push(targetPath);
    }
  }
};

// 添加页面类型检测变量
const isContentManagementPage = computed(() => {
  // 检查是否在内容管理页面
  return router.currentRoute.value.path === '/content-management';
});

// 添加私信页面检测变量
const isMessagesPage = computed(() => {
  // 检查是否在私信页面
  return router.currentRoute.value.path === '/messages';
});

// 添加用户个人中心页面检测变量
const isUserProfilePage = computed(() => {
  // 检查是否在用户个人中心页面
  return router.currentRoute.value.path.startsWith('/user/');
});

// 添加创作者中心页面检测变量
const isCreatorCenterPage = computed(() => {
  // 检查是否在创作者中心页面
  return router.currentRoute.value.path === '/creator-center';
});

// 私信页面跳转方法
const goToMessagePage = () => {
  router.push('/messages');
};

// 获取当前页面标题
const getPageTitle = () => {
  if (isContentManagementPage.value) {
    return '内容管理 - Blackbox';
  } else if (isMessagesPage.value) {
    return '私信 - Blackbox';
  } else if (isUserProfilePage.value) {
    return '个人中心 - Blackbox';
  } else if (isCreatorCenterPage.value) {
    return '创作者中心 - Blackbox';
  } else {
    return 'Blackbox社区';
  }
};

// 监听路由变化，更新页面标题和强制更新计算属性
watch(
  () => router.currentRoute.value.path,
  (newPath, oldPath) => {
    console.log(`路由变化: ${oldPath} -> ${newPath}`);
    // 强制刷新DOM以确保计算属性重新计算
    nextTick(() => {
      document.title = getPageTitle();
    });
  },
  { immediate: true } // 立即执行一次
);

// 初始设置页面标题
onMounted(() => {
  document.title = getPageTitle();
});

// 添加统一的页面类型和标题计算属性
const currentPageType = computed(() => {
  const path = router.currentRoute.value.path;
  
  if (path === '/content-management') return 'content';
  if (path === '/messages') return 'messages';
  if (path.startsWith('/user/')) return 'profile';
  if (path === '/creator-center') return 'creator';
  
  return 'default';
});

const currentPageTitle = computed(() => {
  switch (currentPageType.value) {
    case 'content': return '内容管理';
    case 'messages': return '私信';
    case 'profile': return '个人中心';
    case 'creator': return '创作者中心';
    default: return '';
  }
});

// 自动渲染 Turnstile 小组件：当注册弹窗打开时，重试直到脚本加载完成
watch(showRegisterPopup, (visible) => {
  if (!visible) return;
  loadingTurnstile.value = true;
  let attempts = 0;
  const tryRender = () => {
    if (window.turnstile) {
      nextTick(() => {
        turnstileWidgetId.value = window.turnstile.render(
          document.querySelector('.cf-turnstile'),
          { sitekey: '0x4AAAAAABZax1N5QEqOLkei', callback: onTurnstileSuccess }
        );
        loadingTurnstile.value = false;
      });
    } else if (attempts < 10) {
      attempts++;
      setTimeout(tryRender, 200);
    } else {
      console.error('Turnstile 脚本未加载');
      loadingTurnstile.value = false;
    }
  };
  tryRender();
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

.center-section {
  max-width: 610px;
  width: 610px;
  margin: 0 20px;
  flex-shrink: 0;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0;
  padding: 0;
  margin-bottom: 5px;
}

/* 添加私信图标样式 */
.message-icon-container {
  position: relative;
  margin-left: 15px;
}

.message-icon {
  font-size: 20px;
  color: #409EFF;
  cursor: pointer;
  transition: color 0.3s;
}

.message-icon:hover {
  color: #66b1ff;
}

.register-popup-overlay {
  position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.5);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
}

.register-popup-content {
  background: #fff; padding: 20px; border-radius: 8px; width: 90%; max-width: 400px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  display: flex; flex-direction: column; gap: 10px;
  position: relative; /* allow absolute children */
}

.register-popup-content .close {
  position: absolute;
  top: 10px;
  right: 10px;
  cursor: pointer;
  font-size: 20px;
}

.register-popup-content input {
  padding: 8px; border:1px solid #ccc; border-radius: 4px;
}

.register-popup-content button {
  padding: 10px; border:none; border-radius:4px; background: #409EFF; color:#fff; cursor:pointer;
}

.register-popup-content button:disabled {
  opacity:0.6; cursor:not-allowed;
}

/* 注册弹窗错误提示 */
.error-msg {
  color: #f56c6c;
  font-size: 12px;
  margin: 4px 0 8px;
}

.turnstile-loading {
  color: #909399;
  font-size: 14px;
  margin: 8px 0;
}

/* 记住我按钮样式 */
.remember-me {
  margin: 10px 0;
  text-align: left;
}

.remember-btn {
  padding: 6px 12px;
  border: 1px solid #ccc;
  border-radius: 4px;
  background-color: #f5f5f5;
  cursor: pointer;
  color: #333;
  font-size: 14px;
}

.remember-btn.active {
  background-color: #ffd04b;
  border-color: #ffc72b;
  color: #333;
}

/* 禁用记住我按钮的悬浮变色 */
.remember-btn:hover {
  /* 默认未选中时保持灰色 */
  background-color: #f5f5f5;
  /* 保持边框颜色 */
  border-color: #ccc;
}

.remember-btn.active:hover {
  /* 选中时保持黄色 */
  background-color: #ffd04b;
  border-color: #ffc72b;
}
</style>    
