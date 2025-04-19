// eventBus.js
import { createApp } from 'vue';

// 创建一个简单的事件总线
const app = createApp({});
export const eventBus = app.config.globalProperties.$eventBus = {
  events: {},

  // 注册事件监听器
  on(event, callback) {
    if (!this.events[event]) {
      this.events[event] = [];
    }
    this.events[event].push(callback);
    return () => this.off(event, callback); // 返回一个取消订阅的函数
  },

  // 触发事件
  emit(event, ...args) {
    if (this.events[event]) {
      this.events[event].forEach(callback => callback(...args));
    }
  },

  // 移除事件监听器
  off(event, callback) {
    if (this.events[event]) {
      if (callback) {
        this.events[event] = this.events[event].filter(cb => cb !== callback);
      } else {
        delete this.events[event];
      }
    }
  }
}; 