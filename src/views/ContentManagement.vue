<template>
  <div>
    <main>
      <!-- 左侧边栏 - 与首页保持一致 -->
      <LeftBlock />
      
      <!-- 右侧内容管理区域 - 合并了中间和右侧为一个大块 -->
      <div class="content-wrapper">
        <div class="content-header">
          <h1>我的内容</h1>
          <div class="content-stats">
            <div class="stat-item">
              <span class="stat-value">{{ totalPosts }}</span>
              <span class="stat-label">总帖子</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ totalViews }}</span>
              <span class="stat-label">总浏览</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ totalLikes }}</span>
              <span class="stat-label">总点赞</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ totalComments }}</span>
              <span class="stat-label">总评论</span>
            </div>
          </div>
        </div>
        
        <!-- 帖子列表 -->
        <div class="posts-list" v-if="!showAnalytics">
          <div v-if="isLoading && userPosts.length === 0" class="loading">加载中...</div>
          <div v-else-if="userPosts.length === 0" class="no-posts">
            暂无帖子，开始创作吧！
          </div>
          <div v-else class="post-items">
            <div v-for="post in userPosts" :key="post.id" class="post-item" @click="viewPostAnalytics(post.id)">
              <div class="post-image-container">
                <div class="post-image" v-if="post.imageUrl && post.imageUrl.length">
                  <img :src="post.imageUrl[0]" alt="帖子图片">
                </div>
                <div v-else class="post-image no-image">
                  <i class="no-image-icon">📄</i>
                </div>
                <div class="post-time-section">
                  <span class="post-time">{{ formatDate(post.postDate) }}</span>
                  <div class="section-tag" v-if="post.section">
                    {{ post.section.sectionName }}
                  </div>
                </div>
                <div class="post-stats">
                  <div class="stat">
                    <i class="stat-icon">👁️</i>
                    <span>{{ post.viewsCount }}</span>
                  </div>
                  <div class="stat">
                    <i class="stat-icon">👍</i>
                    <span>{{ post.likesCount }}</span>
                  </div>
                  <div class="stat">
                    <i class="stat-icon">💬</i>
                    <span>{{ post.commentsCount }}</span>
                  </div>
                </div>
              </div>
              <div class="post-content-container">
                <div class="post-content">
                  <h3 class="post-title">{{ post.title }}</h3>
                  <p class="post-summary">{{ post.content }}</p>
                </div>
                <div class="post-actions">
                  <button class="action-btn edit" @click.stop="editPost(post.id)">编辑</button>
                  <button class="action-btn delete" @click.stop="confirmDelete(post.id)">删除</button>
                </div>
              </div>
            </div>
            
            <!-- 加载更多按钮 -->
            <div v-if="hasMorePosts && !isLoading" class="load-more-container">
              <button @click="loadMorePosts" class="load-more-button">加载更多</button>
            </div>
            
            <!-- 加载中提示 -->
            <div v-if="isLoading && userPosts.length > 0" class="loading-indicator">
              加载中...
            </div>
            
            <!-- 全部加载完毕提示 -->
            <div v-if="!hasMorePosts && userPosts.length > 0" class="all-loaded-message">
              已加载全部内容
            </div>
          </div>
        </div>
        
        <!-- 数据分析面板 -->
        <div v-if="showAnalytics" class="analytics-panel">
          <div class="analytics-header">
            <div class="analytics-title">
              <button class="back-button" @click="closeAnalytics">返回</button>
              <h2>内容详情分析</h2>
            </div>
            <div class="post-basic-info">
              <h3>{{ currentPostAnalytics?.title }}</h3>
              <div class="post-meta-info">
                <span class="section-label">{{ currentPostAnalytics?.section }}</span>
                <span class="post-date">{{ formatDate(currentPostAnalytics?.postDate) }}</span>
              </div>
            </div>
          </div>
          
          <div v-if="analyticsLoading" class="analytics-loading">
            加载分析数据中...
          </div>
          
          <div v-else class="analytics-content">
            <!-- 内容数据 -->
            <div class="analytics-section">
              <h4>内容</h4>
              <div class="analytics-stats-row">
                <div class="analytics-stat-item">
                  <span class="analytics-label">内容得分</span>
                  <span class="analytics-value">-</span>
                </div>
                <div class="analytics-stat-item">
                  <span class="analytics-label">浏览量</span>
                  <span class="analytics-value">{{ currentPostAnalytics?.viewsCount }}</span>
                </div>
                <div class="analytics-stat-item">
                  <span class="analytics-label">平均浏览时长</span>
                  <span class="analytics-value">{{ currentPostAnalytics?.avgViewTime }}秒</span>
                </div>
              </div>
            </div>
            
            <!-- 浏览量趋势图 -->
            <div class="analytics-section">
              <h4>浏览量趋势</h4>
              <div class="chart-container">
                <div class="chart-y-axis">
                  <div v-for="(value, index) in 5" :key="index" class="y-axis-label">
                    {{ 200 - index * 50 }}
                  </div>
                </div>
                <div class="chart-area">
                  <div class="chart-line" :style="{ height: '200px' }">
                    <div 
                      v-for="(value, index) in viewsChartData.data" 
                      :key="index" 
                      class="chart-bar"
                      :style="{ 
                        height: `${Math.min(value * 4, 200)}px`,
                        left: `${index * (100 / viewsChartData.data.length)}%`
                      }"
                    ></div>
                  </div>
                  <div class="chart-x-axis">
                    <div 
                      v-for="(label, index) in viewsChartData.labels"
                      :key="index"
                      class="x-axis-label"
                      :style="{ left: `${index * (100 / viewsChartData.labels.length)}%` }"
                      v-show="index % 5 === 0"
                    >
                      {{ label }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 互动数据 -->
            <div class="analytics-section">
              <h4>互动</h4>
              
              <!-- 互动数量 -->
              <div class="analytics-stats-row interaction-stats">
                <div class="analytics-stat-box">
                  <div class="stat-label">点赞量</div>
                  <div class="stat-value">{{ currentPostAnalytics?.likesCount || 0 }}</div>
                </div>
                <div class="analytics-stat-box">
                  <div class="stat-label">评论量</div>
                  <div class="stat-value">{{ currentPostAnalytics?.commentsCount || 0 }}</div>
                </div>
                <div class="analytics-stat-box">
                  <div class="stat-label">分享量</div>
                  <div class="stat-value">{{ currentPostAnalytics?.shareCount || 0 }}</div>
                </div>
                <div class="analytics-stat-box">
                  <div class="stat-label">收藏量</div>
                  <div class="stat-value">{{ currentPostAnalytics?.favoriteCount || 0 }}</div>
                </div>
              </div>
              
              <!-- 互动率 -->
              <div class="analytics-stats-row interaction-stats">
                <div class="analytics-stat-box">
                  <div class="stat-label">点赞率</div>
                  <div class="stat-value">{{ currentPostAnalytics?.likeRate || '0.0' }}%</div>
                </div>
                <div class="analytics-stat-box">
                  <div class="stat-label">评论率</div>
                  <div class="stat-value">{{ currentPostAnalytics?.commentRate || '0.0' }}%</div>
                </div>
                <div class="analytics-stat-box">
                  <div class="stat-label">分享率</div>
                  <div class="stat-value">{{ currentPostAnalytics?.shareRate || '0.0' }}%</div>
                </div>
                <div class="analytics-stat-box">
                  <div class="stat-label">收藏率</div>
                  <div class="stat-value">{{ currentPostAnalytics?.favoriteRate || '0.0' }}%</div>
                </div>
              </div>
              
              <!-- 互动趋势图 -->
              <div class="interaction-chart-container">
                <div class="chart-y-axis">
                  <div v-for="i in 5" :key="i" class="y-axis-label">
                    {{ (i - 1) * 0.3 }}
                  </div>
                </div>
                <div class="chart-area">
                  <div class="trend-line-chart">
                    <svg v-if="viewsChartData && viewsChartData.data && viewsChartData.data.length > 0" 
                         width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="none">
                      <!-- 动态生成折线，使用后端返回的数据 -->
                      <polyline 
                        :points="generateChartPoints(viewsChartData.data)" 
                        fill="none" 
                        stroke="#409EFF" 
                        stroke-width="2"
                      />
                    </svg>
                    <!-- 网格线 -->
                    <div class="grid-lines">
                      <div v-for="i in 4" :key="i" class="grid-line" :style="{bottom: `${i * 25}%`}"></div>
                    </div>
                  </div>
                  <div class="chart-x-axis">
                    <div v-for="(date, index) in viewsChartData.labels" :key="index" 
                         class="date-label" 
                         :style="{left: `${index * (100 / (viewsChartData.labels.length - 1))}%`}"
                         v-show="index % 5 === 0 || index === viewsChartData.labels.length - 1">
                      {{ date }}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 粉丝板块 -->
            <div class="analytics-section fans-section">
              <h4>粉丝</h4>
              
              <!-- 粉丝数据 -->
              <div class="analytics-stats-row">
                <div class="analytics-stat-box">
                  <div class="stat-label">新增粉丝</div>
                  <div class="stat-value">{{ currentPostAnalytics?.newFans || 0 }}</div>
                </div>
              </div>
              
              <!-- 粉丝趋势图 -->
              <div class="interaction-chart-container">
                <div class="chart-y-axis">
                  <div v-for="i in 5" :key="i" class="y-axis-label">
                    {{ (i - 1) * 0.3 }}
                  </div>
                </div>
                <div class="chart-area">
                  <div class="trend-line-chart">
                    <svg width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="none">
                      <!-- 示例折线，真实数据应从API获取 -->
                      <polyline 
                        points="0,200 100,200 200,200 300,200 400,200 500,200 600,200 700,200 800,200 900,200 1000,200" 
                        fill="none" 
                        stroke="#409EFF" 
                        stroke-width="2"
                      />
                    </svg>
                    <!-- 网格线 -->
                    <div class="grid-lines">
                      <div v-for="i in 4" :key="i" class="grid-line" :style="{bottom: `${i * 25}%`}"></div>
                    </div>
                  </div>
                  <div class="chart-x-axis">
                    <div v-for="(date, index) in ['02.09', '02.17', '02.25', '03.05', '03.13', '03.21', '03.29', '04.06', '04.14']" :key="index" class="date-label" :style="{left: `${index * 12.5}%`}">
                      {{ date }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, onBeforeUnmount} from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth.js';
import axios from 'axios';
import LeftBlock from '../components/LeftBlock.vue';
import { ElMessage, ElMessageBox } from 'element-plus';

export default defineComponent({
  name: 'ContentManagement',
  components: {
    LeftBlock
  },
  setup() {
    const router = useRouter();
    const authStore = useAuthStore();
    const userPosts = ref([]);
    const isLoading = ref(true);
    const totalPosts = ref(0);
    const totalViews = ref(0);
    const totalLikes = ref(0);
    const totalComments = ref(0);
    
    // 添加分页相关变量
    const currentPage = ref(1);
    const hasMorePosts = ref(true);
    
    // 添加数据分析相关变量
    const showAnalytics = ref(false);
    const currentPostAnalytics = ref(null);
    const analyticsLoading = ref(false);
    
    // 模拟图表数据
    const viewsChartData = ref({
      labels: [],
      data: []
    });

    // 获取用户帖子列表
    const fetchUserPosts = async (reset = true) => {
      if (!authStore.isLoggedIn) {
        ElMessage.error('请先登录');
        router.push('/');
        return;
      }

      isLoading.value = true;
      
      // 如果是重置，则重置页码和帖子列表
      if (reset) {
        currentPage.value = 1;
        userPosts.value = [];
      }
      
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        const response = await axios.get('http://localhost:7070/api/posts/by-user', {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          },
          params: {
            userId: authStore.userInfo.id,
            pageNum: currentPage.value,
            pageSize: 5
          }
        });

        // 处理分页数据
        const pageData = response.data;
        const newPosts = pageData.records || [];
        
        // 处理字段名称差异，将views映射为viewsCount
        newPosts.forEach(post => {
          post.viewsCount = post.views;
        });
        
        if (reset) {
          userPosts.value = newPosts;
        } else {
          userPosts.value = [...userPosts.value, ...newPosts];
        }
        
        // 检查是否还有更多页
        hasMorePosts.value = currentPage.value < pageData.pages && newPosts.length > 0;
        
        // 计算总计数据
        calculateTotals();
      } catch (error) {
        console.error('获取帖子失败:', error);
        ElMessage.error('获取帖子列表失败');
      } finally {
        isLoading.value = false;
      }
    };
    
    // 获取帖子分析数据
    const fetchPostAnalytics = async (postId) => {
      analyticsLoading.value = true;
      
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        const response = await axios.get(`http://localhost:7070/api/posts/${postId}/analytics`, {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        });
        
        // 获取API返回的分析数据
        const analyticsData = response.data;
        
        // 设置当前帖子分析数据
        currentPostAnalytics.value = {
          title: analyticsData.title,
          section: analyticsData.section || '未分类',
          postDate: analyticsData.postDate,
          viewsCount: analyticsData.viewsCount || 0,
          avgViewTime: analyticsData.avgViewTime || 0,
          likesCount: analyticsData.likesCount || 0,
          commentsCount: analyticsData.commentsCount || 0,
          shareCount: analyticsData.shareCount || 0,
          favoriteCount: analyticsData.favoriteCount || 0,
          likeRate: analyticsData.likeRate || '0.0',
          commentRate: analyticsData.commentRate || '0.0',
          shareRate: analyticsData.shareRate || '0.0',
          favoriteRate: analyticsData.favoriteRate || '0.0',
          newFans: analyticsData.newFans || 0
        };
        
        // 设置图表数据
        if (analyticsData.viewsData) {
          viewsChartData.value = analyticsData.viewsData;
        } else {
          // 后备方案：如果API未返回图表数据，则设置空数据
          viewsChartData.value = {
            labels: [],
            data: []
          };
        }
        
        // 显示分析面板
        showAnalytics.value = true;
      } catch (error) {
        console.error('获取帖子分析数据失败:', error);
        ElMessage.error('获取帖子分析数据失败，请稍后再试');
      } finally {
        analyticsLoading.value = false;
      }
    };
    
    // 加载更多帖子
    const loadMorePosts = async () => {
      if (isLoading.value || !hasMorePosts.value) return;
      
      currentPage.value++;
      await fetchUserPosts(false);
    };

    // 计算总计数据
    const calculateTotals = () => {
      totalPosts.value = userPosts.value.length;
      totalViews.value = userPosts.value.reduce((sum, post) => sum + (post.viewsCount || 0), 0);
      totalLikes.value = userPosts.value.reduce((sum, post) => sum + (post.likesCount || 0), 0);
      totalComments.value = userPosts.value.reduce((sum, post) => sum + (post.commentsCount || 0), 0);
    };

    // 查看帖子详情
    const viewPostDetail = (postId) => {
      router.push(`/post-detail?postId=${postId}`);
    };
    
    // 查看帖子分析
    const viewPostAnalytics = (postId) => {
      fetchPostAnalytics(postId);
    };
    
    // 关闭分析面板
    const closeAnalytics = () => {
      showAnalytics.value = false;
      currentPostAnalytics.value = null;
    };

    // 编辑帖子
    const editPost = (postId) => {
      router.push(`/creator-center?postId=${postId}`);
    };

    // 确认删除帖子
    const confirmDelete = (postId) => {
      ElMessageBox.confirm('确定要删除这篇帖子吗？此操作不可撤销。', '删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        deletePost(postId);
      }).catch(() => {
        // 用户取消删除
      });
    };

    // 删除帖子
    const deletePost = async (postId) => {
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        await axios.delete(`http://localhost:7070/api/posts/${postId}`, {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        });
        
        ElMessage.success('帖子已删除');
        // 重新获取帖子列表
        fetchUserPosts();
      } catch (error) {
        console.error('删除帖子失败:', error);
        ElMessage.error('删除帖子失败');
      }
    };

    // 时间格式化函数
    const formatDate = (dateStr) => {
      if (!dateStr) return '暂无日期';
      
      try {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(dateStr).toLocaleDateString('zh-CN', options);
      } catch (error) {
        console.error('日期格式化错误:', error);
        return dateStr;
      }
    };

    // 生成图表点坐标
    const generateChartPoints = (dataArray) => {
      if (!dataArray || dataArray.length === 0) return '';
      
      // 找出数据中的最大值，用于缩放
      const maxValue = Math.max(...dataArray);
      
      // 生成点坐标
      const points = dataArray.map((value, index) => {
        // 横坐标：根据索引平均分布
        const x = (index / (dataArray.length - 1)) * 1000;
        
        // 纵坐标：将值映射到0-200的范围，0是最大值(顶部)，200是最小值(底部)
        // 如果最大值为0，则所有点都在底部
        const y = maxValue === 0 ? 200 : 200 - (value / maxValue) * 200;
        
        return `${x},${y}`;
      }).join(' ');
      
      return points;
    };

    // 组件挂载时添加滚动控制
    onMounted(() => {
      // 获取用户帖子
      fetchUserPosts();
      
      // 标记当前页面，用于控制头部搜索框显示
      document.body.classList.add('content-management-page');
      
      // 强制禁用body滚动
      document.body.style.overflow = 'hidden';
      document.documentElement.style.overflow = 'hidden';
      
      // 查找所有可能的容器并禁用滚动
      const app = document.getElementById('app');
      if (app) {
        app.style.overflow = 'hidden';
      }
      
      // 只允许帖子列表滚动
      const postsList = document.querySelector('.posts-list');
      if (postsList) {
        postsList.style.overflow = 'auto';
        postsList.style.height = `${window.innerHeight - 295}px`;
      }
    });
    
    // 组件卸载时恢复滚动
    onBeforeUnmount(() => {
      document.body.classList.remove('content-management-page');
      
      // 恢复滚动
      document.body.style.overflow = '';
      document.documentElement.style.overflow = '';
      
      const app = document.getElementById('app');
      if (app) {
        app.style.overflow = '';
      }
    });

    return {
      userPosts,
      isLoading,
      totalPosts,
      totalViews,
      totalLikes,
      totalComments,
      viewPostDetail,
      viewPostAnalytics,
      editPost,
      confirmDelete,
      hasMorePosts,
      loadMorePosts,
      formatDate,
      showAnalytics,
      currentPostAnalytics,
      analyticsLoading,
      closeAnalytics,
      viewsChartData,
      generateChartPoints
    };
  }
});
</script>

<style scoped>
/* 更强力的页面全局样式 */
html, body, #app {
  overflow: hidden !important; /* 强制禁止整个页面滚动 */
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
}

:deep(*) {
  scrollbar-width: none; /* Firefox */
}

:deep(*::-webkit-scrollbar) {
  display: none; /* Chrome, Safari, Edge */
}

.posts-list {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  margin-top: 130px; /* 为顶部固定的内容区域留出空间 */
  margin-bottom: 20px;
  height: calc(100vh - 295px); /* 设置固定高度 */
  overflow-y: auto; /* 允许垂直滚动 */
  scrollbar-width: none; /* Firefox 隐藏滚动条 */
  -ms-overflow-style: none; /* IE and Edge 隐藏滚动条 */
}

/* 隐藏Chrome、Safari等浏览器的滚动条 */
.posts-list::-webkit-scrollbar {
  display: none;
}

/* 清除之前的滚动条样式 */
.posts-list::-webkit-scrollbar-track,
.posts-list::-webkit-scrollbar-thumb {
  background: transparent;
}

/* 添加平滑滚动效果 */
.posts-list, .analytics-panel {
  scroll-behavior: smooth;
}

/* 修改布局样式，使其与Index页面一致 */
main {
  display: flex;
  justify-content: center; /* 改为居中对齐，与Index页面一致 */
  padding-top: 30px;
  height: 100vh; /* 使用固定高度而非最小高度 */
  margin-top: 75px; /* 保留此样式，为页头留出空间 */
  position: relative;
  overflow: hidden; /* 防止整体滚动 */
}

/* 左侧块样式，与Index保持一致 */
.left-block {
  width: 200px;
  margin-right: 20px;
  position: fixed !important; /* 固定位置 */
  left: calc(50% - 600px); /* 居中定位 */
  top: 85px;
  background-color: #f7f8f9;
  height: calc(100vh - 115px);
  overflow: hidden; /* 禁止左侧块滚动 */
  z-index: 100;
}

/* 内容管理区域样式 */
.content-wrapper {
  width: 980px; /* 保持宽度一致 */
  margin: 0; /* 移除左边距，由main的居中布局控制 */
  margin-left: 220px; /* 给左侧块留出空间 */
  position: relative;
  overflow: hidden; /* 禁止整体滚动 */
}

.content-header {
  background-color: white;
  border-radius: 8px;
  padding: 20px; /* 恢复原来的padding */
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  position: fixed !important; /* 固定位置 */
  top: 85px;
  width: 940px; /* 恢复原来的宽度 */
  z-index: 99;
}

.content-header h1 {
  margin: 0 0 20px 0; /* 恢复原来的间距 */
  font-size: 24px; /* 恢复原来的字体大小 */
  color: #333;
}

.content-stats {
  display: flex;
  justify-content: space-between;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: #f7f8f9;
  padding: 15px; /* 恢复原来的padding */
  border-radius: 8px;
  width: 22%;
}

.stat-value {
  font-size: 24px; /* 恢复原来的字体大小 */
  font-weight: bold;
  color: #409EFF;
}

.stat-label {
  font-size: 14px; /* 恢复原来的字体大小 */
  color: #666;
  margin-top: 5px; /* 恢复原来的间距 */
}

/* 帖子列表样式 */
.posts-list {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  margin-top: 280px; /* 为顶部固定的内容区域留出空间 */
  height: calc(100vh - 295px); /* 设置固定高度 */
  overflow-y: auto; /* 允许垂直滚动 */
  scrollbar-width: none; /* Firefox 隐藏滚动条 */
  -ms-overflow-style: none; /* IE and Edge 隐藏滚动条 */
}

/* 隐藏Chrome、Safari等浏览器的滚动条 */
.posts-list::-webkit-scrollbar {
  display: none;
}

/* 清除之前的滚动条样式 */
.posts-list::-webkit-scrollbar-track,
.posts-list::-webkit-scrollbar-thumb {
  background: transparent;
}

.loading, .no-posts {
  text-align: center;
  padding: 40px;
  color: #666;
  font-size: 16px;
}

.post-items {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding-bottom: 40px; /* 添加底部内边距，允许上滑空间 */
}

/* 帖子样式 */
.post-item {
  display: flex;
  background-color: white;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
}

.post-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.08);
}

/* 左侧内容 */
.post-image-container {
  width: 180px;
  margin-right: 20px;
  display: flex;
  flex-direction: column;
}

.post-image {
  width: 180px;
  height: 120px;
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 10px;
  background-color: #f5f5f5;
}

.no-image {
  display: flex;
  justify-content: center;
  align-items: center;
}

.no-image-icon {
  font-size: 36px;
  color: #ccc;
}

.post-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.post-time-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.post-time {
  font-size: 12px;
  color: #999;
}

.section-tag {
  display: inline-block;
  padding: 2px 8px;
  background-color: #f0f2f5;
  border-radius: 4px;
  font-size: 12px;
  color: #666;
  white-space: nowrap;
}

.post-stats {
  display: flex;
  justify-content: space-between;
  gap: 5px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 2px;
  color: #666;
  font-size: 12px;
}

.stat-icon {
  font-size: 14px;
}

/* 右侧内容 */
.post-content-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.post-content {
  flex: 1;
}

.post-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 10px 0;
  color: #333;
  cursor: pointer;
}

.post-title:hover {
  color: #409EFF;
}

.post-summary {
  font-size: 14px;
  color: #666;
  margin: 0;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.post-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 10px;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.edit {
  background-color: #e6f7ff;
  color: #1890ff;
}

.edit:hover {
  background-color: #1890ff;
  color: white;
}

.delete {
  background-color: #fff1f0;
  color: #f5222d;
}

.delete:hover {
  background-color: #f5222d;
  color: white;
}

/* 加载更多按钮样式 */
.load-more-container {
  padding: 10px 0 20px 0;
  width: 100%;
  display: flex;
  justify-content: center;
}

.load-more-button {
  width: 90%;
  background-color: #409EFF;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 12px 0;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.load-more-button:hover {
  background-color: #66b1ff;
}

.loading-indicator,
.all-loaded-message {
  text-align: center;
  padding: 10px;
  color: #666;
  font-size: 14px;
}

.all-loaded-message {
  color: #999;
  font-style: italic;
}

/* 量化数据分析面板样式 */
.analytics-panel {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  margin-top: 130px;
  height: calc(100vh - 190px);
  overflow-y: auto;
}

.analytics-header {
  margin-bottom: 20px;
  border-bottom: 1px solid #eee;
  padding-bottom: 15px;
}

.analytics-title {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.back-button {
  background: none;
  border: none;
  color: #409EFF;
  font-size: 14px;
  cursor: pointer;
  padding: 5px 10px;
  margin-right: 10px;
  display: flex;
  align-items: center;
}

.back-button:before {
  content: '←';
  margin-right: 5px;
}

.analytics-title h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.post-basic-info h3 {
  margin: 0 0 10px 0;
  font-size: 16px;
  color: #333;
}

.post-meta-info {
  display: flex;
  gap: 15px;
  font-size: 13px;
  color: #666;
}

.section-label {
  background-color: #f0f2f5;
  padding: 2px 8px;
  border-radius: 4px;
}

.analytics-loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  color: #999;
}

.analytics-content {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.analytics-section {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 15px;
}

.analytics-section h4 {
  margin: 0 0 15px 0;
  font-size: 15px;
  color: #333;
  font-weight: 600;
}

.analytics-stats-row {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 15px;
}

.analytics-stats-row:last-child {
  margin-bottom: 0;
}

.analytics-stat-item {
  background-color: white;
  padding: 12px;
  border-radius: 6px;
  flex: 1;
  min-width: 120px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.analytics-stat-item.wide {
  flex: 2;
}

.analytics-label {
  font-size: 13px;
  color: #666;
  margin-bottom: 5px;
}

.analytics-value {
  font-size: 22px;
  font-weight: 600;
  color: #333;
}

/* 图表样式 */
.chart-container {
  display: flex;
  height: 250px;
  position: relative;
}

.chart-y-axis {
  width: 40px;
  height: 200px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding-top: 10px;
}

.y-axis-label {
  font-size: 12px;
  color: #999;
  text-align: right;
  padding-right: 5px;
}

.chart-area {
  flex: 1;
  position: relative;
  padding-top: 10px;
}

.chart-line {
  position: relative;
  width: 100%;
  background-image: linear-gradient(to bottom, #f0f0f0 1px, transparent 1px);
  background-size: 100% 50px;
  border-bottom: 1px solid #e0e0e0;
}

.chart-bar {
  position: absolute;
  bottom: 0;
  width: 3px;
  background-color: #409EFF;
  border-radius: 3px 3px 0 0;
  transition: height 0.3s;
}

.chart-x-axis {
  height: 30px;
  position: relative;
  margin-top: 5px;
}

.x-axis-label {
  position: absolute;
  font-size: 11px;
  color: #999;
  transform: translateX(-50%) rotate(45deg);
  transform-origin: top left;
  white-space: nowrap;
}

/* 增加指针样式，表示可点击 */
.post-item {
  cursor: pointer;
}

.post-title {
  cursor: text;
}

/* 互动数据样式 */
.interaction-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 15px;
}

.analytics-stat-box {
  background-color: white;
  padding: 12px;
  border-radius: 6px;
  flex: 1;
  min-width: 120px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-label {
  font-size: 13px;
  color: #666;
  margin-bottom: 5px;
}

.stat-value {
  font-size: 22px;
  font-weight: 600;
  color: #333;
}

/* 互动趋势图样式 */
.interaction-chart-container {
  margin-top: 20px;
  display: flex;
  height: 250px;
  position: relative;
}

.trend-line-chart {
  position: relative;
  width: 100%;
  height: 200px;
  border-bottom: 1px solid #eee;
  background-image: linear-gradient(to bottom, #f0f0f0 1px, transparent 1px);
  background-size: 100% 50px;
}

.grid-lines {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}

.grid-line {
  position: absolute;
  width: 100%;
  height: 1px;
  background-color: #eee;
}

.chart-x-axis {
  height: 30px;
  position: absolute;
  bottom: -30px;
  left: 40px;
  right: 0;
}

.date-label {
  position: absolute;
  font-size: 11px;
  color: #999;
  transform: translateX(-50%);
  white-space: nowrap;
}

svg polyline {
  stroke: #409EFF;
  stroke-width: 2;
  fill: none;
}

/* 粉丝板块样式 */
.fans-section {
  margin-top: 20px;
  margin-bottom: 20px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}
</style>