import { createApp } from 'vue';
import App from './App.vue';
import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';
import router from './router';
import { createPinia } from 'pinia';
import LeftBlock from '@/components/LeftBlock.vue';
import RightBlock from '@/components/RightBlock.vue';
import { useAuthStore } from '@/stores/auth';
import axios from 'axios';
import { ElMessage } from 'element-plus'
// 创建 Vue 应用实例
const app = createApp(App);

// 创建 Pinia 实例
const pinia = createPinia();

// 使用 ElementPlus 插件
app.use(ElementPlus);

// 使用路由
app.use(router);

// 使用 Pinia
app.use(pinia);

// 初始化 auth store (确保在 Pinia 注册之后)
// 注意：在 main.js 顶级作用域直接使用 useAuthStore 可能不安全，
// 最好在 Pinia store 或组件内部使用。
// 但如果你的初始化逻辑简单且必须在此处完成，确保在 app.use(pinia) 之后。
try {
  const authStore = useAuthStore(pinia); // 传递 pinia 实例
  authStore.initializeFromStorage();
} catch (error) {
  console.error("Failed to initialize auth store:", error);
  // 可能需要添加一些错误处理逻辑
}

// 全局注册组件
app.component('LeftBlock', LeftBlock);
app.component('RightBlock', RightBlock);

// 挂载应用实例到 DOM
app.mount('#app');

axios.interceptors.request.use(config => {
  // 在拦截器内部获取 store 实例通常更安全
  const authStore = useAuthStore(pinia);
  if (authStore.isLoggedIn) {
    config.headers.Authorization = `Bearer ${authStore.userInfo.token}`;
  }
  return config;
}, error => {
  return Promise.reject(error);
});

axios.interceptors.response.use(response => {
  return response;
}, error => {
  if (error.response && error.response.status === 401) {
    // 在拦截器内部获取 store 实例
    const authStore = useAuthStore(pinia);
    // 只有在确实是token过期时才logout
    if (authStore.isLoggedIn) {
      authStore.logout();
      ElMessage.error('登录已过期，请重新登录');
      router.push({ name: 'Index' });
    }
  }
  return Promise.reject(error);
});