<template>
  <div id="create-post">
    <!-- 头部 -->
    <header class="header">
      <div class="logo">
        <img src="https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/blackbox.png" alt="Logo" />
      </div>
      <div class="page-title">
        创作者中心
      </div>
      <div class="user-section">
        <div v-if="authStore.isLoggedIn" class="userinfo" @click="toggleDropdown">
          <img :src="authStore.userInfo.avatar" alt="用户头像" class="avatar" />
          <span class="username">{{ authStore.userInfo.username }}</span>
          <div v-if="isDropdownVisible" class="dropdown">
            <div class="dropdown-item" @click="goToPage('UserCenter')">用户中心</div>
            <div class="dropdown-item" @click="handleLogout">退出登录</div>
          </div>
        </div>
        <button v-else @click="showLoginPopup = true">登录</button>
      </div>
    </header>

    <!-- 内容区域 -->
    <main>
      <LeftBlock />
      
      <div class="editor-wrapper">
        <div class="editor-container">
          <div class="editor-header">
            <input 
              v-model="postTitle" 
              type="text" 
              placeholder="输入文章标题" 
              class="title-input"
            >
          </div>
          
          <div class="editor-toolbar">
            <button @click="insertImage" class="toolbar-button">
              <i class="el-icon-picture"></i> 插入图片
            </button>
            <input 
              type="file" 
              ref="fileInput" 
              @change="handleImageUpload" 
              style="display: none" 
              accept="image/*"
              multiple
            >
          </div>
          
          <div class="editor-content" ref="editorContent">
            <div 
              v-for="(block, index) in contentBlocks" 
              :key="index" 
              class="content-block"
              :class="{ 'image-block': block.type === 'image' }"
            >
              <textarea 
                v-if="block.type === 'text'" 
                v-model="block.content"
                placeholder="输入文章内容..."
                class="text-block"
                @input="autoResize($event)"
              ></textarea>
              
              <div v-if="block.type === 'image'" class="image-container">
                <img :src="block.content" alt="上传的图片" class="uploaded-image">
                <button @click="removeImage(index)" class="remove-image-button">
                  <i class="el-icon-delete"></i>
                </button>
              </div>
            </div>
          </div>
          
          <div class="editor-footer">
            
            <button @click="submitPost" class="submit-button">
              发布文章
            </button>
          </div>
        </div>
      </div>
      
      <RightBlock  />
    </main>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import axios from 'axios';
import { ElMessage } from 'element-plus';
import LeftBlock from '@/components/LeftBlock.vue';
import RightBlock from '@/components/RightBlock.vue';

export default {
  name: 'CreatorCenter',
  components: {
    LeftBlock,
    RightBlock
  },
  setup() {
    const router = useRouter();
    const authStore = useAuthStore();
    
    const postTitle = ref('');
    const contentBlocks = ref([{ type: 'text', content: '' }]);
    const fileInput = ref(null);
    const editorContent = ref(null);
    const isDropdownVisible = ref(false);
    const showLoginPopup = ref(false);
    const hotPosts = ref([]);
    
    // 获取热门帖子
    const fetchHotPosts = async () => {
      try {
        const response = await axios.get('/api/posts');
        hotPosts.value = response.data;
      } catch (error) {
        console.error('获取热门帖子失败:', error);
      }
    };
    
    // 插入图片按钮点击
    const insertImage = () => {
      fileInput.value.click();
    };
    
    // 处理图片上传
    const handleImageUpload = async (event) => {
      const files = event.target.files;
      if (!files.length) return;
      
      try {
        const formData = new FormData();
        for (let i = 0; i < files.length; i++) {
          formData.append('images', files[i]);
        }
        
        const response = await axios.post('/api/upload', formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': `Bearer ${authStore.userInfo.token}`
          }
        });
        
        // 添加图片块到内容
        response.data.forEach(url => {
          contentBlocks.value.push({ type: 'image', content: url });
        });
        
        // 重置文件输入
        fileInput.value.value = '';
      } catch (error) {
        console.error('图片上传失败:', error);
        ElMessage.error('图片上传失败');
      }
    };
    
    // 删除图片
    const removeImage = (index) => {
      contentBlocks.value.splice(index, 1);
    };
    
    
    
    // 自动调整文本框高度
    const autoResize = (event) => {
      event.target.style.height = 'auto';
      event.target.style.height = event.target.scrollHeight + 'px';
    };
    
    // 提交文章
    const submitPost = async () => {
      if (!postTitle.value.trim()) {
        ElMessage.warning('请输入文章标题');
        return;
      }
      
      if (contentBlocks.value.length === 1 && !contentBlocks.value[0].content.trim()) {
        ElMessage.warning('请输入文章内容');
        return;
      }
      
      try {
        const postData = {
          title: postTitle.value,
          content: contentBlocks.value,
          authorId: authStore.userInfo.id
        };
        
        await axios.post('/api/posts', postData, {
          headers: {
            'Authorization': `Bearer ${authStore.userInfo.token}`
          }
        });
        
        ElMessage.success('文章发布成功');
        router.push({ name: 'Index' });
      } catch (error) {
        console.error('文章发布失败:', error);
        ElMessage.error('文章发布失败');
      }
    };
    
    // 用户操作
    const toggleDropdown = () => {
      isDropdownVisible.value = !isDropdownVisible.value;
    };
    
    const goToPage = (path) => {
      router.push({ name: path });
    };
    
    const handleLogout = () => {
      authStore.logout();
      router.push({ name: 'Index' });
    };
    
    onMounted(() => {
      fetchHotPosts();
    });
    
    return {
      authStore,
      postTitle,
      contentBlocks,
      fileInput,
      editorContent,
      isDropdownVisible,
      showLoginPopup,
      hotPosts,
      insertImage,
      handleImageUpload,
      removeImage,
      autoResize,
      submitPost,
      toggleDropdown,
      goToPage,
      handleLogout
    };
  }
};
</script>

<style scoped>
#create-post {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.header {
  background-color: #ffffff;
  height: 65px;
  display: flex;
  align-items: center;
  padding: 0 10px;
  justify-content: space-between;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 4;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.logo img {
  margin-left: 320px;
  height: 26px;
  width: auto;
}

.page-title {
  flex-grow: 1;
  text-align: center;
  font-size: 18px;
  font-weight: bold;
  margin-right: 100vh;
}

.user-section {
  position: absolute;
  right: 320px;
}

.user-section button {
  background-color: #32373c;
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  height: 35px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: 100px;
}

.user-section button:hover {
  background-color: #2a3034;
}

.userinfo {
  display: flex;
  align-items: center;
  position: relative;
  cursor: pointer;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  margin-right: 10px;
  border: 2px solid #eee;
}

.username {
  font-weight: 500;
  color: #333;
  font-size: 14px;
}

.dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  padding: 5px 0;
  z-index: 1;
}

.dropdown-item {
  padding: 8px 16px;
  cursor: pointer;
  white-space: nowrap;
}

.dropdown-item:hover {
  background-color: #f0f0f0;
}

main {
  display: flex;
  justify-content: center;
  padding-top: 30px;
  min-height: calc(100vh - 75px);
  margin-top: 10px;
}

.left-block {
  width: 200px;
  margin-right: 20px;
  position: sticky;
  top: 85px;
  height: calc(100vh - 115px);
  background-color: #f7f8f9;
  overflow-y: auto;
  align-self: flex-start;
}

.editor-wrapper {
  width: 610px;
  margin: 0 20px;
  margin-right: 20px;
}

.editor-container {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  min-height: 80vh;
  flex-direction: column;
  margin-bottom: 10px;
}

.editor-header {
  margin-bottom: 20px;
}

.title-input {
  width: 95%;
  padding: 15px;
  font-size: 24px;
  border: none;
  border-bottom: 1px solid #eee;
  outline: none;
}

.title-input:focus {
  border-bottom-color: #409EFF;
}

.editor-toolbar {
  display: flex;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.toolbar-button {
  padding: 8px 12px;
  background-color: #f0f0f0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 10px;
  display: flex;
  align-items: center;
}

.toolbar-button i {
  margin-right: 5px;
}

.toolbar-button:hover {
  background-color: #e0e0e0;
}

.editor-content {
  flex: 1;
  margin-bottom: 20px;
}

.content-block {
  margin-bottom: 20px;
}

.text-block {
  width: 96%;
  min-height: 100px;
  padding: 10px;
  border: 1px solid #eee;
  border-radius: 4px;
  resize: none;
  font-size: 16px;
  line-height: 1.6;
  outline: none;
}

.text-block:focus {
  border-color: #409EFF;
}

.image-block {
  position: relative;
  margin: 20px 0;
}

.image-container {
  position: relative;
  display: inline-block;
}

.uploaded-image {
  max-width: 100%;
  max-height: 400px;
  border-radius: 4px;
  display: block;
}

.remove-image-button {
  position: absolute;
  top: 10px;
  right: 10px;
  background-color: rgba(0, 0, 0, 0.7);
  color: white;
  border: none;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.remove-image-button:hover {
  background-color: rgba(0, 0, 0, 0.9);
}

.editor-footer {
  display: flex;
  justify-content: space-between;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.add-block-button {
  padding: 10px 15px;
  background-color: #f0f0f0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.add-block-button i {
  margin-right: 5px;
}

.add-block-button:hover {
  background-color: #e0e0e0;
}

.submit-button {
  padding: 10px 25px;
  background-color: #409EFF;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
}

.submit-button:hover {
  background-color: #66b1ff;
}

.right-block {
  width: 350px;
  height: calc(100vh - 115px);
  margin-left: 20px;
  position: sticky;
  top: 85px;
  background-color: #ffffff;
  padding: 20px;
  border-radius: 8px;
  overflow-y: auto;
}
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