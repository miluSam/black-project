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
        
        <!-- 帖子列表 - 使用 v-show 替代 v-if，并添加 pageReady 条件 -->
        <div class="posts-list" v-show="!showAnalytics && pageReady">
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
                  <h3 class="post-title">{{ truncateTitle(post.title) }}</h3>
                  <p class="post-summary">{{ truncateContent(post.content) }}</p>
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
        
        <!-- 数据分析面板 - 使用 v-show 替代 v-if，并添加 pageReady 条件 -->
        <div v-show="showAnalytics && pageReady" class="analytics-panel">
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
                  <span class="analytics-value">{{ contentScore.score }}</span>
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
                  <div v-for="(value, index) in viewsYAxisValues" :key="index" class="y-axis-label">
                    {{ value }}
                  </div>
                </div>
                <div class="chart-area" 
                     @mousemove="handleChartMouseMove($event, viewsChartData.data, viewsChartData.labels, '浏览量')" 
                     @mouseleave="hideTooltip">
                  <div class="chart-line" :style="{ height: '200px' }">
                    <!-- 折线图 -->
                    <svg width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="none">
                      <polyline 
                        :points="generateChartPoints(viewsChartData.data)" 
                        fill="none" 
                        stroke="#409EFF" 
                        stroke-width="2"
                      />
                    </svg>
                    
                    <!-- 数据点标记 -->
                    <div v-for="(value, index) in viewsChartData.data" 
                         :key="index" 
                         class="data-point"
                         :class="{ 'active-point': tooltip.visible && tooltip.chartType === '浏览量' && tooltip.activePointIndex === index }"
                         :style="{ 
                           left: `${index * (100 / 6)}%`, 
                           bottom: `${viewsYAxisValues[0] === 0 ? 0 : (value / viewsYAxisValues[0]) * 200}px`
                         }"
                    ></div>
                    
                    <!-- 鼠标悬浮参考线 -->
                    <div v-if="tooltip.visible && tooltip.chartType === '浏览量'" 
                         class="hover-line" 
                         :style="{ left: `${tooltip.position.x}px` }"></div>
                  </div>
                  <div class="chart-x-axis">
                    <div v-for="(label, index) in viewsChartData.labels" 
                         :key="index" 
                         class="x-axis-label" 
                         :style="{ left: `${index * (100 / 6)}%` }">
                      {{ label }}
                    </div>
                  </div>
                  
                  <!-- 悬浮提示框 -->
                  <div v-if="tooltip.visible && tooltip.chartType === '浏览量'" 
                       class="chart-tooltip"
                       :style="{ 
                         left: `${tooltip.absolutePosition.x + 10}px`, 
                         top: `${tooltip.absolutePosition.y - 40}px` 
                       }">
                    <div class="tooltip-title">{{ tooltip.chartType }}</div>
                    <div class="tooltip-value">{{ tooltip.value }}</div>
                    <div class="tooltip-date">{{ tooltip.date }}</div>
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
                  <div v-for="(value, index) in interactionYAxisValues" :key="index" class="y-axis-label">
                    {{ value }}
                  </div>
                </div>
                <div class="chart-area"
                     @mousemove="handleChartMouseMove($event, interactionChartData.data, interactionChartData.labels, '互动量')" 
                     @mouseleave="hideTooltip">
                  <div class="trend-line-chart">
                    <svg width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="none">
                      <!-- 动态生成折线，使用后端返回的互动数据 -->
                      <polyline 
                        :points="generateChartPoints(interactionChartData.data)" 
                        fill="none" 
                        stroke="#409EFF" 
                        stroke-width="2"
                      />
                    </svg>
                    
                    <!-- 数据点标记 -->
                    <div v-for="(value, index) in interactionChartData.data" 
                         :key="index" 
                         class="data-point"
                         :class="{ 'active-point': tooltip.visible && tooltip.chartType === '互动量' && tooltip.activePointIndex === index }"
                         :style="{ 
                           left: `${index * (100 / 6)}%`, 
                           bottom: `${interactionYAxisValues[0] === 0 ? 0 : (value / interactionYAxisValues[0]) * 200}px`
                         }"
                    ></div>
                    
                    <!-- 鼠标悬浮参考线 -->
                    <div v-if="tooltip.visible && tooltip.chartType === '互动量'" 
                         class="hover-line" 
                         :style="{ left: `${tooltip.position.x}px` }"></div>
                    
                    <!-- 网格线 -->
                    <div class="grid-lines">
                      <div v-for="i in 4" :key="i" class="grid-line" :style="{bottom: `${i * 25}%`}"></div>
                    </div>
                  </div>
                  <div class="chart-x-axis">
                    <div v-for="(date, index) in interactionChartData.labels" 
                         :key="index" 
                         class="x-axis-label" 
                         :style="{left: `${index * (100 / 6)}%`}">
                      {{ date }}
                    </div>
                  </div>
                  
                  <!-- 悬浮提示框 -->
                  <div v-if="tooltip.visible && tooltip.chartType === '互动量'" 
                       class="chart-tooltip"
                       :style="{ 
                         left: `${tooltip.absolutePosition.x + 10}px`, 
                         top: `${tooltip.absolutePosition.y - 40}px` 
                       }">
                    <div class="tooltip-title">{{ tooltip.chartType }}</div>
                    <div class="tooltip-value">{{ tooltip.value }}</div>
                    <div class="tooltip-date">{{ tooltip.date }}</div>
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
                  <div v-for="(value, index) in fansYAxisValues" :key="index" class="y-axis-label">
                    {{ value }}
                  </div>
                </div>
                <div class="chart-area"
                     @mousemove="handleChartMouseMove($event, fansChartData.data, fansChartData.labels, '新增粉丝')" 
                     @mouseleave="hideTooltip">
                  <div class="trend-line-chart">
                    <svg width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="none">
                      <!-- 动态生成折线，使用后端返回的粉丝数据 -->
                      <polyline 
                        :points="generateChartPoints(fansChartData.data)" 
                        fill="none" 
                        stroke="#409EFF" 
                        stroke-width="2"
                      />
                    </svg>
                    
                    <!-- 数据点标记 -->
                    <div v-for="(value, index) in fansChartData.data" 
                         :key="index" 
                         class="data-point"
                         :class="{ 'active-point': tooltip.visible && tooltip.chartType === '新增粉丝' && tooltip.activePointIndex === index }"
                         :style="{ 
                           left: `${index * (100 / 6)}%`, 
                           bottom: `${fansYAxisValues[0] === 0 ? 0 : (value / fansYAxisValues[0]) * 200}px`
                         }"
                    ></div>
                    
                    <!-- 鼠标悬浮参考线 -->
                    <div v-if="tooltip.visible && tooltip.chartType === '新增粉丝'" 
                         class="hover-line" 
                         :style="{ left: `${tooltip.position.x}px` }"></div>
                    
                    <!-- 网格线 -->
                    <div class="grid-lines">
                      <div v-for="i in 4" :key="i" class="grid-line" :style="{bottom: `${i * 25}%`}"></div>
                    </div>
                  </div>
                  <div class="chart-x-axis">
                    <div v-for="(date, index) in fansChartData.labels" 
                         :key="index" 
                         class="x-axis-label" 
                         :style="{left: `${index * (100 / 6)}%`}">
                      {{ date }}
                    </div>
                  </div>
                  
                  <!-- 悬浮提示框 -->
                  <div v-if="tooltip.visible && tooltip.chartType === '新增粉丝'" 
                       class="chart-tooltip"
                       :style="{ 
                         left: `${tooltip.absolutePosition.x + 10}px`, 
                         top: `${tooltip.absolutePosition.y - 40}px` 
                       }">
                    <div class="tooltip-title">{{ tooltip.chartType }}</div>
                    <div class="tooltip-value">{{ tooltip.value }}</div>
                    <div class="tooltip-date">{{ tooltip.date }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 添加一个加载指示器，当页面还未准备好时显示 -->
        <div v-if="!pageReady" class="initial-loading">
          <div class="loading-spinner"></div>
          <div class="loading-text">加载中...</div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, onBeforeUnmount, computed, nextTick } from 'vue';
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
    
    // 添加一个页面初始加载状态控制
    const pageReady = ref(false);
    
    // 添加分页相关变量
    const currentPage = ref(1);
    const hasMorePosts = ref(true);
    
    // 添加数据分析相关变量
    const showAnalytics = ref(false);
    const currentPostAnalytics = ref(null);
    const analyticsLoading = ref(false);
    
    // 图表数据
    const viewsChartData = ref({
      labels: [],
      data: []
    });
    
    // 添加互动趋势图和粉丝趋势图的数据引用
    const interactionChartData = ref({
      labels: [],
      data: []
    });
    
    const fansChartData = ref({
      labels: [],
      data: []
    });
    
    // 图表提示框状态
    const tooltip = ref({
      visible: false,
      position: { x: 0, y: 0 },
      absolutePosition: { x: 0, y: 0 },
      value: 0,
      date: '',
      chartType: '',
      activePointIndex: -1 // 新增：当前活跃点的索引
    });
    
    // 处理图表鼠标移动事件
    const handleChartMouseMove = (event, dataArray, labels, chartType) => {
      const chartArea = event.currentTarget;
      const rect = chartArea.getBoundingClientRect();
      const offsetX = event.clientX - rect.left;
      const chartWidth = rect.width;
      
      // 计算鼠标与每个数据点的距离，选择最近的点
      let closestIndex = 0;
      let minDistance = Infinity;
      
      for (let i = 0; i < dataArray.length; i++) {
        const pointX = (i / 6) * chartWidth;
        const distance = Math.abs(offsetX - pointX);
        
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }
      
      // 计算最近点在图表中的x坐标（相对于图表容器）
      const pointX = (closestIndex / 6) * chartWidth;
      
      // 计算绝对位置（用于提示框）
      const absoluteX = rect.left + pointX;
      const absoluteY = event.clientY;
      
      // 更新提示框位置和内容
      tooltip.value = {
        visible: true,
        // 相对位置（用于参考线）
        position: {
          x: pointX,
          y: event.clientY - rect.top
        },
        // 绝对位置（用于提示框）
        absolutePosition: {
          x: absoluteX,
          y: absoluteY
        },
        value: dataArray[closestIndex] || 0,
        date: labels[closestIndex] || '',
        chartType: chartType,
        activePointIndex: closestIndex // 记录当前活跃点索引
      };
    };
    
    // 隐藏提示框
    const hideTooltip = () => {
      tooltip.value.visible = false;
    };

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
        const response = await axios.get('/api/posts/by-user', {
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
        const response = await axios.get(`/api/posts/${postId}/analytics`, {
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
        
        // 确保数据是一周的完整视图
        const processChartData = (chartData) => {
          if (!chartData || !chartData.labels || !chartData.data) {
            return { labels: generateWeekLabels(), data: [0, 0, 0, 0, 0, 0, 0] };
          }
          
          // 如果只有一个数据点，扩展为一周数据
          if (chartData.labels.length === 1) {
            const weekLabels = generateWeekLabels(chartData.labels[0]);
            const weekData = Array(7).fill(0);
            // 将唯一数据点放在正确的位置
            const dayIndex = getDayIndex(chartData.labels[0]);
            if (dayIndex >= 0 && dayIndex < 7) {
              weekData[dayIndex] = chartData.data[0];
            }
            return { labels: weekLabels, data: weekData };
          }
          
          // 如果数据点少于7个，补全为一周
          if (chartData.labels.length < 7) {
            const weekLabels = generateWeekLabels();
            const weekData = Array(7).fill(0);
            
            // 将现有数据点填充到对应位置
            chartData.labels.forEach((label, index) => {
              const dayIndex = getDayIndex(label);
              if (dayIndex >= 0 && dayIndex < 7) {
                weekData[dayIndex] = chartData.data[index];
              }
            });
            
            return { labels: weekLabels, data: weekData };
          }
          
          return chartData;
        };
        
        // 生成一周的日期标签（格式：MM.DD），以当天为最后一天
        const generateWeekLabels = (referenceDate) => {
          const result = [];
          // 参考日期或今天
          const today = referenceDate ? new Date(parseChineseDate(referenceDate)) : new Date();
          
          // 生成过去七天的日期标签（包括今天）
          for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(today.getDate() - i); // 减去天数，6天前到今天
            const month = (date.getMonth() + 1).toString().padStart(2, '0');
            const day = date.getDate().toString().padStart(2, '0');
            result.push(`${month}.${day}`);
          }
          
          return result;
        };
        
        // 解析中文日期格式（MM.DD）到日期对象
        const parseChineseDate = (dateStr) => {
          if (!dateStr || typeof dateStr !== 'string') return new Date();
          
          const parts = dateStr.split('.');
          if (parts.length !== 2) return new Date();
          
          const month = parseInt(parts[0], 10) - 1; // 月份从0开始
          const day = parseInt(parts[1], 10);
          
          const result = new Date();
          result.setMonth(month);
          result.setDate(day);
          
          return result;
        };
        
        // 获取日期标签在过去一周中的索引（0-6，对应6天前到今天）
        const getDayIndex = (dateLabel) => {
          if (!dateLabel) return -1;
          
          const date = parseChineseDate(dateLabel);
          const today = new Date();
          
          // 重置时分秒，只比较日期部分
          today.setHours(0, 0, 0, 0);
          date.setHours(0, 0, 0, 0);
          
          // 计算与今天的天数差
          const diffTime = today.getTime() - date.getTime();
          const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));
          
          // 如果在过去7天内，返回对应索引（0是6天前，6是今天）
          if (diffDays >= 0 && diffDays <= 6) {
            return 6 - diffDays; // 转换为数组索引
          }
          
          return -1; // 不在过去一周内
        };
        
        // 处理各个图表的数据
        viewsChartData.value = processChartData(analyticsData.viewsData);
        interactionChartData.value = processChartData(analyticsData.interactionData);
        fansChartData.value = processChartData(analyticsData.fansData);
        
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
        await axios.delete(`/api/posts/${postId}`, {
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

    // 计算Y轴刻度值
    const calculateYAxisValues = (dataArray, tickCount = 5) => {
      if (!dataArray || dataArray.length === 0) return [1, 0.75, 0.5, 0.25, 0];
      
      const maxValue = Math.max(...dataArray);
      
      // 如果所有数据都是0，返回一个从0到1的刻度
      if (maxValue === 0) return [1, 0.75, 0.5, 0.25, 0];
      
      // 计算合适的最大刻度值（略大于最大数据值，更易读）
      let niceMaxValue;
      
      // 如果最大值小于10，使用较小的舍入增量
      if (maxValue < 10) {
        niceMaxValue = Math.ceil(maxValue * 2) / 2; // 舍入到0.5的倍数
      } else if (maxValue < 100) {
        niceMaxValue = Math.ceil(maxValue / 5) * 5; // 舍入到5的倍数
      } else {
        niceMaxValue = Math.ceil(maxValue / 10) * 10; // 舍入到10的倍数
      }
      
      // 确保最大值比实际数据的最大值至少大10-20%
      const buffer = Math.max(1, Math.ceil(niceMaxValue * 0.2));
      niceMaxValue += buffer;
      
      // 生成均匀分布的刻度数组（从大到小）
      const result = [];
      for (let i = 0; i < tickCount; i++) {
        // 使用浮点数避免舍入导致的重复值
        const value = niceMaxValue - (i * (niceMaxValue / (tickCount - 1)));
        
        // 根据值的大小决定保留的小数位数
        let formattedValue;
        if (niceMaxValue >= 100) {
          formattedValue = Math.round(value); // 大数值只保留整数
        } else if (niceMaxValue >= 10) {
          formattedValue = Math.round(value * 10) / 10; // 中等数值保留一位小数
        } else {
          formattedValue = Math.round(value * 100) / 100; // 小数值保留两位小数
        }
        
        // 防止添加重复值（与前一个值比较）
        if (i === 0 || formattedValue !== result[result.length - 1]) {
          result.push(formattedValue);
        } else {
          // 如果发生重复，微调当前值
          result.push(formattedValue + (niceMaxValue >= 10 ? 0.1 : 0.01));
        }
      }
      
      return result;
    };
    
    // 生成图表点坐标
    const generateChartPoints = (dataArray) => {
      if (!dataArray || dataArray.length === 0) return '';
      
      // 计算Y轴的最大刻度值（与Y轴刻度计算保持一致）
      const maxValue = Math.max(...dataArray);
      let yAxisMaxValue;
      
      if (maxValue === 0) {
        yAxisMaxValue = 1; // 如果数据全为0，使用1作为最大刻度
      } else {
        // 使用与calculateYAxisValues相同的逻辑计算最大刻度
        if (maxValue < 10) {
          yAxisMaxValue = Math.ceil(maxValue * 2) / 2;
        } else if (maxValue < 100) {
          yAxisMaxValue = Math.ceil(maxValue / 5) * 5;
        } else {
          yAxisMaxValue = Math.ceil(maxValue / 10) * 10;
        }
        
        // 添加缓冲区
        const buffer = Math.max(1, Math.ceil(yAxisMaxValue * 0.2));
        yAxisMaxValue += buffer;
      }
      
      // 生成点坐标，使用yAxisMaxValue而不是maxValue来确保与Y轴刻度一致
      const points = dataArray.map((value, index) => {
        // 横坐标：根据索引平均分布
        const x = (index / (dataArray.length - 1 || 1)) * 1000;
        
        // 纵坐标：将值映射到0-200的范围，0是最大值(顶部)，200是最小值(底部)
        // 使用yAxisMaxValue作为缩放基准
        const y = 200 - (value / yAxisMaxValue) * 200;
        
        return `${x},${y}`;
      }).join(' ');
      
      return points;
    };

    // 计算不同图表的Y轴刻度
    const viewsYAxisValues = computed(() => calculateYAxisValues(viewsChartData.value.data));
    const interactionYAxisValues = computed(() => calculateYAxisValues(interactionChartData.value.data));
    const fansYAxisValues = computed(() => calculateYAxisValues(fansChartData.value.data));

    // 内容得分计算函数
    const calculateContentScore = (post) => {
      if (!post) return { score: 0, details: {} };
      
      // 1. 基础指标定义
      const views = post.viewsCount || 0;
      const avgViewTime = post.avgViewTime || 0; // 秒为单位
      const likes = post.likesCount || 0;
      const comments = post.commentsCount || 0;
      const shares = post.shareCount || 0;
      const favorites = post.favoriteCount || 0;
      const newFans = post.newFans || 0;
      
      // 2. 互动率计算
      const engagementRate = views > 0 ? 
        ((likes + comments * 2 + shares * 3 + favorites * 2) / views) * 100 : 0;
      
      // 3. 定义权重
      const weights = {
        viewScore: 0.2,      // 浏览得分权重
        timeScore: 0.25,     // 时长得分权重
        engagementScore: 0.3, // 互动得分权重
        fanScore: 0.25       // 粉丝转化权重
      };
      
      // 4. 分项得分计算 (都归一化到0-100分)
      // 浏览量得分 - 使用对数函数防止大数值过度影响
      const viewScore = views === 0 ? 0 : Math.min(100, 20 * Math.log10(views + 1));
      
      // 平均浏览时长得分 - 最长考虑3分钟，超过3分钟记满分
      const timeScore = Math.min(100, (avgViewTime / 180) * 100);
      
      // 互动率得分 - 高质量内容通常有5%以上互动率
      const engagementScore = Math.min(100, engagementRate * 20);
      
      // 粉丝转化得分 - 每篇文章能带来新粉丝是很有价值的
      const fanScore = Math.min(100, newFans * 10);
      
      // 5. 计算加权总分 (0-100分)
      const totalScore = Math.round(
        weights.viewScore * viewScore +
        weights.timeScore * timeScore +
        weights.engagementScore * engagementScore + 
        weights.fanScore * fanScore
      );
      
    return {
        score: totalScore,
        details: {
          viewScore,
          timeScore,
          engagementScore,
          fanScore
        }
      };
    };

    // 添加内容得分计算属性
    const contentScore = computed(() => {
      return calculateContentScore(currentPostAnalytics.value);
    });

    // --- 添加截断函数 ---
    const truncateText = (text, maxLength) => {
      if (!text) return '';
      if (text.length <= maxLength) {
        return text;
      }
      return text.slice(0, maxLength) + '...';
    };

    // 为标题和内容分别定义，方便理解
    const truncateTitle = (title) => truncateText(title, 20);
    const truncateContent = (content) => truncateText(content, 50);

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
      
      // 延迟一点时间确保布局计算正确
      setTimeout(() => {
        // 设置页面准备好的状态
        pageReady.value = true;
        
        // 确保在一些特殊情况下也能正确渲染（例如从其他页面返回）
        nextTick(() => {
          // 获取帖子列表和内容头部元素
          const postsList = document.querySelector('.posts-list');
          const contentHeader = document.querySelector('.content-header');
          
          if (postsList && contentHeader) {
            // 获取 content-header 的实际高度
            const headerHeight = contentHeader.offsetHeight;
            // 设置帖子列表的顶部间距，确保不重叠
            postsList.style.marginTop = `${headerHeight - 30}px`; 
            
            // 重新计算帖子列表的高度
            const topNavHeight = 75; // 顶部导航栏高度
            const bottomPadding = 20; // 底部间距
            postsList.style.height = `${window.innerHeight - topNavHeight - headerHeight - 20 - bottomPadding}px`;
            
            // 确保可以滚动
            postsList.style.overflowY = 'auto';
          }
        });
      }, 300); // 300ms的延迟通常足够等待布局渲染
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
      generateChartPoints,
      interactionChartData,
      fansChartData,
      viewsYAxisValues,
      interactionYAxisValues,
      fansYAxisValues,
      calculateYAxisValues,
      handleChartMouseMove,
      hideTooltip,
      tooltip,
      contentScore,
      truncateTitle,
      truncateContent,
      pageReady
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
  margin-top: 130px; /* 为顶部固定的内容区域留出空间 */
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
  cursor: pointer;
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
  cursor: text;
}

.post-title:hover {
  color: #409EFF;
}

.post-summary {
  font-size: 14px;
  color: #666;
  margin: 0;
  line-height: 1.5;
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
  height: calc(100vh - 295px);
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
  cursor: pointer;
}

.chart-line {
  position: relative;
  width: 100%;
  height: 200px;
  background-image: linear-gradient(to bottom, #f0f0f0 1px, transparent 1px);
  background-size: 100% 50px;
  border-bottom: 1px solid #e0e0e0;
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
  transform: translateX(-50%);
  white-space: nowrap;
}

/* 数据点样式 */
.data-point {
  position: absolute;
  width: 8px;
  height: 8px;
  background-color: #409EFF;
  border-radius: 50%;
  transform: translate(-50%, 50%); /* 居中对齐 */
  z-index: 2;
  transition: transform 0.2s, box-shadow 0.2s;
}

.data-point:hover {
  transform: translate(-50%, 50%) scale(1.5);
  box-shadow: 0 0 5px rgba(64, 158, 255, 0.8);
  cursor: pointer;
}

/* 当前活跃的数据点 */
.active-point {
  transform: translate(-50%, 50%) scale(1.5);
  box-shadow: 0 0 8px rgba(64, 158, 255, 1);
  background-color: #fff;
  border: 2px solid #409EFF;
}

/* 鼠标悬浮参考线 */
.hover-line {
  position: absolute;
  height: 100%;
  width: 1px;
  background-color: rgba(64, 158, 255, 0.5);
  bottom: 0;
  pointer-events: none;
  z-index: 1;
}

/* 提示框样式 */
.chart-tooltip {
  position: fixed; /* 改为fixed定位，使其可以超出父容器 */
  background-color: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 1000; /* 提高z-index确保显示在最上层 */
  min-width: 80px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(2px);
}

.tooltip-title {
  font-weight: bold;
  margin-bottom: 4px;
}

.tooltip-value {
  font-size: 14px;
  color: #409EFF;
  font-weight: bold;
}

.tooltip-date {
  margin-top: 2px;
  color: #ccc;
  font-size: 11px;
}

/* 互动数据样式 - 恢复原始样式 */
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

/* 增加指针样式，表示可点击 */
.post-item {
  cursor: pointer;
}

.post-title {
  cursor: text;
}

/* 互动趋势图和粉丝趋势图样式 */
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

/* 添加初始加载时的样式 */
.initial-loading {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #409EFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

.loading-text {
  color: #666;
  font-size: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>