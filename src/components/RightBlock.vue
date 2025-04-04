<template>
  <div class="right-block">
    <div class="hot-posts-title">热门帖子</div>
    <div class="hot-posts-list">
      <div 
        v-for="post in computedHotPosts" 
        :key="post.id" 
        class="hot-post-item"
        @click="emit('post-click', post.id)"
      >
        <div class="hot-post-image">
          <img 
            :src="getFirstImage(post)" 
            alt="帖子图片" 
            class="hot-post-img"
          />
        </div>
        <div class="hot-post-content">
          <h3>{{ post.title }}</h3>
          <div class="hot-post-meta">
            <span class="hot-post-likes">👍 {{ post.likesCount }}</span>
            <span class="hot-post-comments">💬 {{ post.commentsCount }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';



const emit = defineEmits(['post-click']);

// 获取帖子的第一张图片
const getFirstImage = (post) => {
  if (post.imageUrl && post.imageUrl.length > 0) {
    return post.imageUrl[0]; // 返回图片数组的第一张
  }
  if (post.section?.imageUrl) {
    return post.section.imageUrl; // 如果没有帖子图片，返回分区图片
  }
  return 'default-image-url.jpg'; // 默认图片
};

// 获取帖子数据
const posts = ref([]);
const fetchPosts = async () => {
  try {
    const response = await axios.get('/api/posts');
    posts.value = response.data;
  } catch (error) {
    console.error('获取帖子失败:', error);
  }
};

// 计算热门帖子
const computedHotPosts = computed(() => {
  return posts.value
    .map(post => {
      // 计算热度 (可以根据需要调整权重)
      const heat = (post.likesCount * 0.3) + (post.commentsCount * 0.7);
      return { ...post, heat };
    })
    .sort((a, b) => b.heat - a.heat) // 按热度降序排序
    .slice(0, 5); // 只取前5个最热门的帖子
});

// 组件挂载时获取数据
onMounted(() => {
  fetchPosts();
});
</script>

<style scoped>
/* 右边块 */
.right-block {
  width: 350px;
  height: 500px;
  margin-left: 20px;
  position: sticky;
  top: 85px;
  background-color: #ffffff;
  padding: 20px;
  border-radius: 8px;
 
}

.hot-posts-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 15px;
}

.hot-posts-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.hot-post-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background-color: #f7f8f9;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.hot-post-item:hover {
  background-color: #e9ecef;
}

.hot-post-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
}

.hot-post-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.hot-post-content {
  flex: 1;
}

.hot-post-content h3 {
  font-size: 14px;
  margin: 0;
  color: #333;
}

.hot-post-meta {
  display: flex;
  gap: 10px;
  font-size: 12px;
  color: #666;
}
</style>