<template>
  <div id="create-post">
    <!-- 内容区域 -->
    <main>
      <LeftBlock />
      <div class="center-content-wrapper">  <!-- 新增包裹层 -->
        <div class="form-wrapper">
          <h2>创建新帖子</h2>
          <form @submit.prevent="submitPost">
            <div class="form-group">
              <label for="title">标题:</label>
              <input type="text" id="title" v-model="post.title" required />
            </div>
            <div class="form-group">
              <label for="content">内容:</label>
              <textarea id="content" v-model="post.content" required></textarea>
            </div>

            <!-- 新的图片上传区域 -->
            <div class="form-group">
              <label>图片 (最多 {{ maxFiles }} 张):</label>
              <div class="image-upload-area">
                <!-- 图片预览列表 -->
                <div v-for="(preview, index) in imagePreviews" :key="index" class="image-preview-item">
                  <img :src="preview" alt="图片预览" />
                  <button type="button" class="remove-image-btn" @click="removeImage(index)">&times;</button>
                </div>
                <!-- 上传触发块 -->
                <div class="upload-block" @click="triggerFileInput" v-if="imagePreviews.length < maxFiles">
                  <span class="plus-sign">+</span>
                </div>
              </div>
              <!-- 隐藏的文件输入框 -->
              <input
                type="file"
                ref="fileInput"
                @change="handleImageUpload"
                style="display: none"
                accept="image/*"
                multiple
              />
            </div>
            <!-- 分区选择 -->
            <div class="form-group">
              <label for="section">选择分区:</label>
              <select id="section" v-model="post.sectionId" required>
                <option disabled value="">请选择一个分区</option>
                <option v-for="section in sections" :key="section.id" :value="section.id">
                  {{ section.sectionName }}
                </option>
              </select>
            </div>

            <button type="submit" :disabled="isSubmitting" class="submit-button">
              {{ isSubmitting ? '发布中...' : '发布帖子' }}
            </button>
            <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
            <p v-if="successMessage" class="success-message">{{ successMessage }}</p>
          </form>
        </div>
      </div>
      <RightBlock />
    </main>
  </div>
</template>

<script>
import { ref, onMounted, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import axios from 'axios';
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
    const hotPosts = ref([]);

    const post = reactive({
      title: '',
      content: '',
      images: [], // 存储 File 对象
      sectionId: '',
    });

    const fileInput = ref(null); // Ref for the hidden file input
    const imagePreviews = ref([]); // 存储预览用的 data URL
    const sections = ref([]);
    const isSubmitting = ref(false);
    const errorMessage = ref('');
    const successMessage = ref('');
    const maxFiles = 5; // 最大文件数

    // 获取热门帖子 (假设 RightBlock 可能需要)
    const fetchHotPosts = async () => {
       try {
         const response = await axios.get('/api/posts'); // 使用相对路径或完整 API 地址
         hotPosts.value = response.data?.data || response.data || []; // 适应不同响应结构
       } catch (error) {
         console.error('获取热门帖子失败:', error);
         // 不在此处设置 errorMessage，避免干扰发布表单
       }
    };

     // 获取分区列表用于下拉选择
     const fetchSections = async () => {
       try {
         // 确保使用正确的API端点获取分区列表
         const response = await axios.get('/api/sections'); // 根据你的后端路由调整
         sections.value = response.data?.data || response.data || []; // 适应可能的响应结构
         if (!Array.isArray(sections.value)) {
             console.error("获取的分区数据不是数组:", sections.value);
             sections.value = []; // 重置为空数组
             errorMessage.value = '加载分区失败：数据格式错误。';
         }
       } catch (error) {
         console.error('获取分区失败:', error);
         errorMessage.value = '加载分区列表失败，请稍后重试。';
       }
     };

    // 触发隐藏的文件输入框
    const triggerFileInput = () => {
      // 清除之前的错误消息
      errorMessage.value = '';
      fileInput.value.click();
    };

    // 处理图片选择
    const handleImageUpload = (event) => {
      errorMessage.value = ''; // 清除旧错误
      const files = Array.from(event.target.files);
      const availableSlots = maxFiles - post.images.length;

      if (files.length > availableSlots) {
          errorMessage.value = `您最多还能选择 ${availableSlots} 张图片。`;
          // 清空文件输入框以便用户可以重新选择
          event.target.value = null;
          return;
       }


      files.forEach(file => {
        // 文件类型和大小校验
         if (!file.type.startsWith('image/')) {
           errorMessage.value = `文件 "${file.name}" 不是图片格式。`;
           return; // 可以考虑阻止后续文件处理或收集所有错误一次性显示
         }
         const maxSize = 5 * 1024 * 1024; // 5MB
         if (file.size > maxSize) {
            errorMessage.value = `图片 "${file.name}" 太大 (超过 5MB)。`;
            return;
         }

        // 校验通过，添加文件和生成预览
        post.images.push(file); // 存储原始 File 对象
        const reader = new FileReader();
        reader.onload = (e) => {
          imagePreviews.value.push(e.target.result); // 存储 Base64 预览 URL
        };
        reader.readAsDataURL(file);
      });

       // 处理完后清空文件输入框的值，这样用户可以再次选择相同的文件（如果之前移除了）
       event.target.value = null;
    };

    // 删除指定索引的图片
    const removeImage = (index) => {
      // 同时从 File 对象数组和预览 URL 数组中移除
      post.images.splice(index, 1);
      imagePreviews.value.splice(index, 1);
      errorMessage.value = ''; // 清除可能存在的错误信息
    };

    // 提交帖子
    const submitPost = async () => {
      // 基本校验
      if (!authStore.isLoggedIn || !authStore.userInfo?.id) {
           errorMessage.value = '请先登录后再发布帖子。';
           return;
      }
       if (!post.title.trim()) {
           errorMessage.value = '请输入帖子标题。';
           return;
       }
        if (!post.content.trim()) {
           errorMessage.value = '请输入帖子内容。';
           return;
       }
      if (!post.sectionId) {
          errorMessage.value = '请选择一个分区。';
          return;
      }


      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      const formData = new FormData();
      formData.append('title', post.title);
      // 注意：这里 content 直接作为文本发送。如果后端需要特定格式（如JSON），需调整。
      formData.append('content', post.content);
      formData.append('userId', authStore.userInfo.id);
      formData.append('sectionId', post.sectionId);

      // 添加图片文件
      post.images.forEach((file) => {
        formData.append('images', file, file.name); // 添加文件名可能有助于后端处理
      });

      try {
        const jwtToken = sessionStorage.getItem('jwtToken') || localStorage.getItem('jwtToken');
        if (!jwtToken) {
           errorMessage.value = '登录状态无效，请重新登录。';
           isSubmitting.value = false;
           // 可能需要引导用户重新登录
           return;
        }

        const config = {
          headers: {
            'Authorization': `Bearer ${jwtToken}`,
            // 'Content-Type': 'multipart/form-data' // Axios 会自动设置
          }
        };

        // 发送到后端的 /api/posts
        const response = await axios.post('/api/post/add', formData, config);

        // 假设后端成功响应会包含 { code: 200, data: { id: newPostId } } 或类似结构
        // 根据你的 Result 结构调整判断逻辑
        if (response.data && (response.data.code === 200 || response.status === 201)) {
            successMessage.value = '帖子发布成功！';
            // 清空表单
            post.title = '';
            post.content = '';
            post.images = [];
            post.sectionId = '';
            imagePreviews.value = [];

             // 跳转到新帖子详情页或首页
             setTimeout(() => {
                 // 尝试从响应数据中获取新帖子ID
                 const newPostId = response.data?.data?.id;
                 if (newPostId) {
                      router.push({ name: 'PostDetail', query: { postId: newPostId } });
                 } else {
                     console.warn("后端未返回新帖子ID，将跳转到首页");
                     router.push('/'); // 跳转到首页
                 }
             }, 1500);
        } else {
             // 处理后端返回的业务错误信息
            errorMessage.value = response.data?.message || '发布失败，请稍后重试。';
        }


      } catch (error) {
        console.error('提交帖子出错:', error);
        // 处理网络错误或后端返回的非2xx状态码错误
        if (error.response) {
          // 后端返回了错误响应 (e.g., 400, 401, 500)
          errorMessage.value = `发布失败: ${error.response.data?.message || error.response.statusText || '服务器错误'}`;
        } else if (error.request) {
          // 请求已发出，但没有收到响应
          errorMessage.value = '发布失败：无法连接到服务器，请检查网络。';
        } else {
          // 设置请求时发生了一些事情，触发了一个错误
          errorMessage.value = `发布失败：${error.message || '未知错误'}`;
        }
      } finally {
        isSubmitting.value = false;
      }
    };

    // --- 生命周期钩子 ---
    onMounted(() => {
      // 页面加载时获取分区列表和热门帖子
      fetchSections();
      fetchHotPosts(); // 确保 fetchHotPosts 也被调用
    });

    return {
      authStore,
      post,
      fileInput, // 需要暴露给模板
      imagePreviews,
      sections,
      isSubmitting,
      errorMessage,
      successMessage,
      maxFiles, // 暴露给模板
      triggerFileInput, // 暴露给模板
      handleImageUpload,
      removeImage,
      submitPost,
      fetchSections,
      fetchHotPosts, // 如果 RightBlock 需要，也暴露
    };
  }
};
</script>

<style scoped>
/* --- 基本布局样式 --- */
#create-post {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f7f8f9; /* 给页面一个背景色 */
}

main {
  display: flex;
  justify-content: center;
  padding-top: 30px;
  /* 移除 min-height */
}

/* Styles for LeftBlock within CreatorCenter */
:deep(.left-block) {
  width: 200px;
  margin-right: 20px; /* Match Index spacing */
  position: sticky; /* 改回 sticky */
  top: 85px; /* Match Index */
  height: fit-content; /* 保持自适应高度 */
  align-self: flex-start; /* 顶部对齐 */
  /* 移除背景色 */
}

/* 新增包裹层样式 */
.center-content-wrapper {
  width: 610px; /* 与 form-wrapper 宽度一致 */
  margin: 0 20px; /* 保持左右间距 */
  /* 设置最大高度并允许滚动 */
  max-height: calc(100vh - 115px); /* 100vh - 导航栏高度 - main的padding-top */
  overflow-y: auto;
  /* 隐藏滚动条样式 (可选，根据 Index.vue) */
  /* scrollbar-width: none;  /* Firefox */
  /* &::-webkit-scrollbar { display: none; } /* Chrome, Safari, Opera */
}

.form-wrapper {
  /* 移除 width 和 margin，由父级 .center-content-wrapper 控制 */
  background-color: #ffffff;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  margin-top: 10px;
  /* 移除 margin-bottom */
}

.form-wrapper h2 {
  text-align: center;
  margin-bottom: 30px; /* 增加标题下方间距 */
  color: #333;
  font-size: 1.6em; /* 调整标题大小 */
  font-weight: 600;
}

.form-group {
  margin-bottom: 25px; /* 增加表单组间距 */
}

.form-group label {
  display: block;
  margin-bottom: 10px; /* 增加标签下方间距 */
  font-weight: 600;
  color: #555;
  font-size: 0.95em;
}

.form-group input[type="text"],
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 12px 15px; /* 调整内边距 */
  border: 1px solid #dcdfe6; /* 更新边框颜色 */
  border-radius: 4px; /* 调整圆角 */
  box-sizing: border-box;
  font-size: 1em;
  color: #333;
  transition: border-color 0.2s;
}
.form-group select {
   cursor: pointer;
   appearance: none; /* 移除默认下拉箭头 */
   background-image: url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23606266%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E');
   background-repeat: no-repeat;
   background-position: right 15px center;
   background-size: 10px 10px;
   padding-right: 40px; /* 为箭头留出空间 */
}


.form-group input[type="text"]:focus,
.form-group textarea:focus,
.form-group select:focus {
  border-color: #409EFF;
  outline: none;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2); /* 添加 focus 效果 */
}

.form-group textarea {
  min-height: 200px; /* 增加文本域最小高度 */
  resize: vertical;
  line-height: 1.6;
}

/* --- 图片上传区域样式 --- */
.image-upload-area {
  display: flex; /* 水平排列 */
  flex-wrap: wrap; /* 允许换行 */
  gap: 15px; /* 元素间距 */
  padding: 10px;
  border: 1px dashed #dcdfe6; /* 虚线边框 */
  border-radius: 6px;
  background-color: #fafafa; /* 浅灰色背景 */
  min-height: 100px; /* 最小高度 */
  align-items: center; /* 垂直居中 */
}

.upload-block {
  width: 80px;
  height: 80px;
  background-color: #f0f2f5; /* 灰色背景 */
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: background-color 0.2s, border-color 0.2s;
}

.upload-block:hover {
  background-color: #e4e7ed;
  border-color: #c0c4cc;
}

.plus-sign {
  font-size: 30px;
  color: #909399;
  font-weight: lighter;
}

.image-preview-item {
  position: relative; /* 为了定位删除按钮 */
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden; /* 隐藏超出部分 */
  border: 1px solid #e0e0e0;
}

.image-preview-item img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover; /* 保持图片比例并填充 */
}

.remove-image-btn {
  position: absolute;
  top: 3px;
  right: 3px;
  background-color: rgba(0, 0, 0, 0.5); /* 半透明黑色背景 */
  color: white;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  width: 20px;
  height: 20px;
  font-size: 14px;
  line-height: 18px; /* 微调使 '×' 居中 */
  text-align: center;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: background-color 0.2s;
}
.remove-image-btn:hover {
   background-color: rgba(0, 0, 0, 0.8); /* 悬停加深背景 */
}

/* --- 提交按钮和消息样式 --- */
.submit-button {
  display: block; /* 独占一行 */
  width: 100%; /* 宽度100% */
  padding: 12px;
  background-color: #409EFF;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1.1em;
  font-weight: 500; /* 调整字重 */
  cursor: pointer;
  transition: background-color 0.2s ease;
  margin-top: 10px; /* 与上方元素间距 */
}

.submit-button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.submit-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.error-message {
  color: #f56c6c;
  margin-top: 15px;
  text-align: center;
  font-size: 0.9em;
}

.success-message {
  color: #67c23a;
  margin-top: 15px;
  text-align: center;
   font-size: 0.9em;
}


/* Styles for RightBlock within CreatorCenter */
:deep(.right-block) {
  width: 300px; /* CreatorCenter's width for RightBlock */
  margin-left: 20px; /* Match Index spacing */
  position: sticky; /* 改回 sticky */
  top: 85px; /* Match Index */
  height: 500px; /* 保持原有的高度 */
  align-self: flex-start; /* 顶部对齐 */
  /* 确保有背景色或其他样式使其可见 */
  background-color: #ffffff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.hot-posts-title {
  font-size: 16px; /* 减小标题字号 */
  font-weight: 600; /* 加粗 */
  margin-bottom: 15px;
  color: #333;
  padding-bottom: 10px; /* 增加下边距 */
  border-bottom: 1px solid #eee; /* 添加下边框 */
}

.hot-posts-list {
  display: flex;
  flex-direction: column;
  gap: 12px; /* 增加间距 */
}

.hot-post-item {
  display: flex;
  align-items: flex-start; /* 顶部对齐 */
  gap: 12px; /* 增加间距 */
  padding: 12px;
  /* background-color: #f7f8f9; */ /* 移除背景色 */
  border-radius: 6px; /* 圆角 */
  cursor: pointer;
  transition: background-color 0.2s ease;
  border: 1px solid #eee; /* 添加边框 */
}

.hot-post-item:hover {
  background-color: #f9f9f9; /* 悬停背景色 */
}

.hot-post-image {
  width: 50px; /* 减小图片宽度 */
  height: 50px;
  border-radius: 4px; /* 圆角 */
  overflow: hidden;
  flex-shrink: 0; /* 防止图片被压缩 */
}

.hot-post-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.hot-post-content {
  flex: 1;
  min-width: 0; /* 防止 flex 子项溢出 */
}

.hot-post-content h3 {
  font-size: 14px;
  margin: 0 0 5px 0; /* 调整下边距 */
  color: #333;
  font-weight: 500; /* 调整字重 */
   /* 处理长标题 */
   white-space: nowrap;
   overflow: hidden;
   text-overflow: ellipsis;
}

.hot-post-meta {
  display: flex;
  gap: 10px;
  font-size: 12px;
  color: #909399; /* 调整颜色 */
}
</style>