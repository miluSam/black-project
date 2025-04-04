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
const pinia = createPinia()
app.use(createPinia())
// 使用 ElementPlus 插件
app.use(ElementPlus);

// 使用路由
app.use(router);

app.use(pinia)

// 初始化auth状态
const authStore = useAuthStore()
authStore.initializeFromStorage()

// 全局注册组件
app.component('LeftBlock', LeftBlock);
app.component('RightBlock', RightBlock);

// 挂载应用实例到 DOM
app.mount('#app');

axios.interceptors.request.use(config => {
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
    const authStore = useAuthStore();
    // 只有在确实是token过期时才logout
    if (authStore.isLoggedIn) {
      authStore.logout();
      ElMessage.error('登录已过期，请重新登录');
      router.push({ name: 'Index' });
    }
  }
  return Promise.reject(error);
});