import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    isLoggedIn: false,
    userInfo: {}
  }),
  actions: {
    login(user) {
      this.isLoggedIn = true
      this.userInfo = user
      // 存储token和用户信息
      sessionStorage.setItem('jwtToken', user.token)
      sessionStorage.setItem('userInfo', JSON.stringify(user))
      localStorage.setItem('jwtToken', user.token)
      localStorage.setItem('userInfo', JSON.stringify(user))
    },
    logout() {
      this.isLoggedIn = false
      this.userInfo = {}
      sessionStorage.removeItem('jwtToken')
      sessionStorage.removeItem('userInfo')
      localStorage.removeItem('jwtToken')
      localStorage.removeItem('userInfo')
    },
    // 新增初始化方法
    initializeFromStorage() {
      const token = sessionStorage.getItem('jwtToken') || localStorage.getItem('jwtToken');
      const userInfo = sessionStorage.getItem('userInfo') || localStorage.getItem('userInfo');

      if (token && userInfo) {
        try {
          this.isLoggedIn = true;
          this.userInfo = JSON.parse(userInfo);
          // 确保token也被存储在userInfo中
          if (!this.userInfo.token) {
            this.userInfo.token = token;
          }
        } catch (e) {
          console.error('解析用户信息失败:', e);
          this.logout();
        }
      }
    },
    // 更新用户头像
    updateUserAvatar(imageUrl) {
      if (this.isLoggedIn && this.userInfo) {
        this.userInfo.imageUrl = imageUrl;
        this.userInfo.avatar = imageUrl; // 确保同时更新avatar字段

        // 更新sessionStorage和localStorage中的用户信息
        sessionStorage.setItem('userInfo', JSON.stringify(this.userInfo));
        localStorage.setItem('userInfo', JSON.stringify(this.userInfo));
      }
    }
  }
})