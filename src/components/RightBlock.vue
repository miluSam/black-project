<template>
  <div class="right-block">
    <div class="hot-posts-title">热门帖子</div>
    <div class="hot-posts-list">
      <div 
        v-for="post in hotPosts" 
        :key="post.id" 
        class="hot-post-item"
        @click="emit('post-click', post.id)"
      >
        <div class="hot-post-image">
          <img 
            :src="post.imageUrl || post.section?.imageUrl || 'default-image-url.jpg'" 
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
defineProps({
  hotPosts: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['post-click']);
</script>

<style scoped>
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