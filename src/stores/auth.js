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
      // 确保 token 存储在 sessionStorage
      if (user.token) {
        sessionStorage.setItem('jwtToken', user.token)
      }
    },
    logout() {
      this.isLoggedIn = false
      this.userInfo = {}
      // 清除存储的 token
      sessionStorage.removeItem('jwtToken')
      localStorage.removeItem('jwtToken')
    }
  },
  persist: true // 如果需要持久化状态
})