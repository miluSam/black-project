<template>
  <div>
    <main>
      <div class="left-block">
        <div class="left-section-top">
          <div class="community_center"
          :class="{ active: currentSection === 'community_center' }"
          @click="currentSection = 'community_center'"
          >社区中心</div>
          <div class="creator_center"
          :class="{ active: currentSection === 'creator_center' }"
          @click="goToPage('creator-center')"
          >创作者中心</div>
          <div class="developer_center"
          :class="{ active: currentSection === 'developer_center' }"
          @click="goToPage('developer-center')"
          >开发者中心</div>
        </div>
        <button class="left-section-button" @click="JoinNewPost">
          +发布内容
        </button>
        <div>

        </div>
      </div>
      <div class="post-wrapper" ref="postWrapper">
        

      </div>
      <div class="right-block">
  <div class="like-posts-title">相似内容</div>
  <div class="like-posts-list">
    <div v-for="post in LikePosts" :key="post.id" class="like-post-item">
      <div class="like-post-image">
        <img 
          :src="post.imageUrl || post.section.imageUrl || 'default-image-url.jpg'" 
          alt="帖子图片" 
          class="like-post-img"
        />
      </div>
      <div class="like-post-content">
        <h3>{{ post.title }}</h3>
        <div class="like-post-meta">
          <span class="like-post-likes">👍 {{ post.likesCount }}</span>
          <span class="like-post-comments">💬 {{ post.commentsCount }}</span>
        </div>
      </div>
    </div>
  </div>
</div>
    </main>
  </div>
</template>

<script>
import { defineComponent, ref } from 'vue';

export default defineComponent({
  name: 'DeveloperCenter',
  props: {
    isLoggedIn: {
      type: Boolean,
      default: false
    }
  },
  setup(props) {
    const searchQuery = ref('');
    const search = () => {
      console.log('搜索内容:', searchQuery.value);
    };
    const showLoginPopup = ref(false);
    const userInfo = ref({});
    const isDropdownVisible = ref(false);
    const toggleDropdown = () => {
      isDropdownVisible.value =!isDropdownVisible.value;
    };
    const goToUserCenter = () => {
      console.log('跳转到用户中心');
    };
    const handleLogout = () => {
      console.log('退出登录');
    };
    console.log('登录状态:', props.isLoggedIn);
    return {
      searchQuery,
      search,
      showLoginPopup,
      userInfo,
      isDropdownVisible,
      toggleDropdown,
      goToUserCenter,
      handleLogout,
       // 从 props 中获取 isLoggedIn
    };
  }
});
</script>

<style>
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background-color: #f7f8f9;
}
</style>
<style scoped>

main {
  display: flex;
  justify-content: center;
  padding-top: 30px;
  min-height: calc(100vh - 75px); /* 计算可视区域高度 */
  margin-top: 10px; /* 保持与头部的间距 */
}
.left-block,
.right-block {
  /* 原样式保留 */
  /* height: calc(100vh - 100px); 改用固定高度 */
  /* max-height: 800px;  */
  overflow-y: auto;
  align-self: flex-start; /* 保持顶部对齐 */
  background-color: #f7f8f9;
}


.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px; /* 与头部保持10px间距 */
  /* height: 300px; */
}

.left-section-top {
  height: 172px;
  width: 100%;
  background-color: #ffffff;
  border-radius: 6px;
  margin-bottom: 20px; /* 间距设置 */
  padding-top: 20px;
  
}
.left-section-top div{
  height: 30%;
  width: 90%;
  margin: auto;
  text-align: center;
  
  border-radius: 6px;
  display: grid;
  align-content: center;
}
.left-section-top div:hover{
  
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
/* 侧边栏尺寸锁定 */
.right-block {
  width: 350px;
  height: 545px;
  margin-left: 20px;
  position: sticky;
  top: 85px; /* 与头部保持10px间距 */
  background-color: #ffffff;
  
}
.left-block,
.right-block,
.post-wrapper {
  overflow: visible !important;
}
</style>