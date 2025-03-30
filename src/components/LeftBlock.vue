<template>
  <div class="left-block">
    <div class="left-section-top">
      <div 
        class="community_center"
        :class="{ active: currentSection === 'community_center' }"
        @click="currentSection = 'community_center'"
      >社区中心</div>
      <div 
        class="creator_center"
        :class="{ active: currentSection === 'creator_center' }"
        @click="goToPage('creator-center')"
      >创作者中心</div>
      <div 
        class="developer_center"
        :class="{ active: currentSection === 'developer_center' }"
        @click="goToPage('developer-center')"
      >开发者中心</div>
    </div>
    <button class="left-section-button" @click="emit('new-post')">
      +发布内容
    </button>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const currentSection = ref('community_center');

const emit = defineEmits(['new-post']);

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