import { createRouter, createWebHistory } from 'vue-router';
import Index from '../views/Index.vue'// 假设你有一个 Home 组件作为首页
import CreatorCenter from '../views/CreatorCenter.vue';
import DeveloperCenter from '../views/DeveloperCenter.vue';
import UserCenter from '../views/UserCenter.vue';
import MainLayout from '../layouts/MainLayout.vue'
import { useAuthStore } from '../stores/auth.js';
const routes = [
    {
        path: '/',
        component: MainLayout, // 使用App作为布局容器
        children: [
            {
                path: '', // 空路径表示默认子路由
                name: 'Index',
                component: Index
            },
            {
                path: '/creator-center',
                name: 'CreatorCenter',
                component: CreatorCenter,
                meta: { requiresAuth: true } // 需要登录
            },
            {
                path: '/developer-center',
                name: 'DeveloperCenter',
                component: DeveloperCenter,
                meta: { requiresAuth: true } // 需要登录
            },
            {
                path: '/user-center',
                name: 'UserCenter',
                component: UserCenter,
                meta: { requiresAuth: true } // 需要登录
            }
        ]
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes
});
// 全局前置守卫
router.beforeEach((to, from, next) => {
    const authStore = useAuthStore();

    // 检查目标路由是否需要登录
    if (to.meta.requiresAuth && !authStore.isLoggedIn) {
        // 如果用户未登录，重定向到登录页面或首页
        next({ name: 'Index' });
    } else {
        // 否则继续导航
        next();
    }
});

export default router;