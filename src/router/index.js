import { createRouter, createWebHistory } from 'vue-router';
import Home from '../App.vue'; // 假设你有一个 Home 组件作为首页
import CreatorCenter from '../views/CreatorCenter.vue';
import DeveloperCenter from '../views/DeveloperCenter.vue';

const routes = [
    {
        path: '/',
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
];

const router = createRouter({
    history: createWebHistory(),
    routes
});

export default router;