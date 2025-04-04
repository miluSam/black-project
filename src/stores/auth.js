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
    },
    logout() {
      this.isLoggedIn = false
      this.userInfo = {}
      sessionStorage.removeItem('jwtToken')
      sessionStorage.removeItem('userInfo')
    },
    // 新增初始化方法
    initializeFromStorage() {
      const token = sessionStorage.getItem('jwtToken');
      if (token) {
        const userInfo = sessionStorage.getItem('userInfo');
        if (userInfo) {
          this.isLoggedIn = true;
          this.userInfo = JSON.parse(userInfo);
        }
      }
    }
  }
})