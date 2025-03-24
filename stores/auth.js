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
    },
    logout() {
      this.isLoggedIn = false
      this.userInfo = {}
    }
  }
})