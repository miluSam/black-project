import { createRouter, createWebHistory } from 'vue-router';
import Home from '../views/Home.vue'// 假设你有一个 Home 组件作为首页
import CreatorCenter from '../views/CreatorCenter.vue';
import DeveloperCenter from '../views/DeveloperCenter.vue';
import MainLayout from '../layouts/MainLayout.vue'
const routes = [
    {
        path: '/',
        component: MainLayout, // 使用App作为布局容器
        children: [
            {
                path: '', // 空路径表示默认子路由
                name: 'Home',
                component: Home
            },
            {
                path: '/creator-center',
                name: 'CreatorCenter',
                component: CreatorCenter
            },
            {
                path: '/developer-center',
                name: 'DeveloperCenter',
                component: DeveloperCenter
            }
        ]
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes
});

export default router;