<template>
  <div class="left-block">
    <div class="left-section-top">
      <div 
        class="index_center"
        :class="{ active: currentSection === 'index_center' }"
        @click="goToPage('')"
      >社区中心</div>
      <div 
        class="creator_center"
        :class="{ active: currentSection === 'creator_center' }"
        @click="goToPage('creator-center')"
      >创作者中心</div>
      <div 
        class="content_management"
        :class="{ active: currentSection === 'content_management' }"
        @click="goToPage('content-management')"
      >内容管理</div>
    </div>
    <button class="left-section-button" @click="goToPage('creator-center')">
      +发布内容
    </button>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

// 根据当前路由路径计算激活的导航项
const currentSection = computed(() => {
  const path = route.path;
  if (path.includes('creator-center')) {
    return 'creator_center';
  } else if (path.includes('content-management')) {
    return 'content_management';
  } else if (path.includes('post-detail')) {
    return 'post_detail';
  } else {
    return 'index_center';
  }
});

const goToPage = (path) => {
  router.push({ path: `/${path}` })
    .catch((error) => {
      console.error('路由跳转出错:', error);
    });
};
</script>

<style scoped>
.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px;
  height: 300px;
  background-color: #f7f8f9;
}

.left-section-top {
  height: 172px;
  width: 100%;
  background-color: #ffffff;
  border-radius: 6px;
  margin-bottom: 20px;
  padding-top: 20px;
}

.left-section-top div {
  height: 30%;
  width: 90%;
  margin: auto;
  text-align: center;
  border-radius: 6px;
  display: grid;
  align-content: center;
}

.left-section-top div:hover {
  background-color: #fafbfc;
}

.left-section-top div.active {
  background-color: #fafbfc; 
}

.left-section-button {
  height: 60px;
  width: 100%;
  border: none;
  border-radius: 8px;
  background: #32373c;
  color: white;
  cursor: pointer;
  transition: background 0.3s ease;
}

.left-section-button:hover {
  background: #2a3034;
}
</style>