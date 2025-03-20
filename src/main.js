import { createApp } from 'vue';
import App from './App.vue';
import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';
import router from './router';

// 创建 Vue 应用实例
const app = createApp(App);

// 使用 ElementPlus 插件
app.use(ElementPlus);

// 使用路由
app.use(router);

// 挂载应用实例到 DOM
app.mount('#app');