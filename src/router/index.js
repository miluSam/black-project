import { createRouter, createWebHistory } from 'vue-router';
import Index from '../views/Index.vue'// 假设你有一个 Home 组件作为首页
import CreatorCenter from '../views/CreatorCenter.vue';
import ContentManagement from '../views/ContentManagement.vue';
import MainLayout from '../layouts/MainLayout.vue'
import PostDetail from '../views/PostDetail.vue';
import { useAuthStore } from '../stores/auth.js';
import { ElMessage } from 'element-plus';
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
                path: '/content-management',
                name: 'ContentManagement',
                component: ContentManagement,
                meta: { requiresAuth: true } // 需要登录
            },

            {
                path: '/post-detail',
                name: 'PostDetail',
                component: PostDetail,

            },
            {
                path: '/user/:userId',
                name: 'UserProfile',
                component: () => import('../views/UserProfile.vue')
            },
            {
                path: '/temp-redirect',
                name: 'TempRedirect',
                component: {
                    render: () => null
                }
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
    authStore.initializeFromStorage();
    const token = localStorage.getItem('jwtToken');

    if (to.meta.requiresAuth && (!authStore.isLoggedIn || !token)) {
        ElMessage.warning('请先登录以访问此页面');
        next({ name: 'Index' });
    } else {
        next();
    }
});


export default router;