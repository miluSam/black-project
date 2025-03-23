
<template>
  <div class="main-layout">
    <!-- 头部 -->
    <header class="header">
      <div class="logo">
        <img src="https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/blackbox.png" alt="Logo" />
      </div>
      <div class="search-bar">
        <input type="text" v-model="searchQuery" placeholder="搜索帖子/游戏" />
        <i class="el-icon-search" @click="search"></i>
      </div>
      <div class="login">
        <!-- 根据登录状态显示登录按钮或用户头像和用户名 -->
        <button v-if="!isLoggedIn" @click="showLoginPopup = true">登录</button>
        <div v-if="isLoggedIn" class="userinfo" @click="toggleDropdown">
          <img :src="userInfo.avatar" alt="用户头像" class="avatar" />
          <span class="username">{{ userInfo.username }}</span>
          <div v-if="isDropdownVisible" class="dropdown">
            <div class="dropdown-item" @click="goToUserCenter">用户中心</div>
            <div class="dropdown-item" @click="handleLogout">退出登录</div>
          </div>
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
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const goToPage = (path) => {
  router.push({ name: path })
}
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
  padding: 0 10px;
  justify-content: space-between;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 4;
}

.logo img {
  margin-left: 320px;
  height: 26px;
  width: auto;
}

.search-bar {
  flex-grow: 1;
  margin: auto;
  margin-left: 130px;
  max-width: 600px;
  position: relative;
}

.search-bar input {
  width: 610px;
  padding: 12px 30px 12px 15px;
  border-radius: 8px;
  border: none;
  border: 1px solid #c9ced2;
  background-color: #fafbfc;
}

.search-bar input:focus {
  outline: none;
}

.search-bar i {
  position: absolute;
  right: -40px;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
}

.login {
  position: absolute;
  right: 320px; /* 根据实际布局调整 */
  transform: translateX(-50%);
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
  margin-left: 100px;
}

.login button:hover {
  background-color: #2a3034;
}

</style>    
