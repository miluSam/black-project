<template>
  <div class="messages-page">
    <!-- 左侧导航块 -->
    <div class="left-block">
      <div class="left-section-top">
        <div 
          class="index_center"
          @click="goToPage('')"
        >社区中心</div>
        <div 
          class="creator_center"
          @click="goToPage('creator-center')"
        >创作者中心</div>
        <div 
          class="content_management"
          @click="goToPage('content-management')"
        >内容管理</div>
      </div>
      <button class="left-section-button" @click="goToPage('creator-center')">
        +发布内容
      </button>
    </div>
    
    <!-- 消息内容区 -->
    <div class="content-wrapper">
      <div class="messages-container">
        <div class="left-sidebar">
          <h2>我的消息</h2>
          <div class="conversation-tabs">
            <div 
              class="conversation-tab" 
              :class="{ 'active': activeTab === 'chats' }"
              @click="activeTab = 'chats'"
            >
              会话
            </div>
            <div 
              class="conversation-tab" 
              :class="{ 'active': activeTab === 'contacts' }"
              @click="showAllContacts"
            >
              联系人
            </div>
          </div>
          <div class="conversation-list">
            <div v-if="activeTab === 'chats' && conversations.length === 0" class="empty-state">
              暂无消息记录
            </div>
            <div v-if="activeTab === 'contacts' && contacts.length === 0" class="empty-state">
              暂无联系人
            </div>
            <template v-if="activeTab === 'chats'">
              <div 
                v-for="conversation in conversations" 
                :key="conversation.id" 
                class="conversation-item"
                :class="{ 'active': selectedConversation && selectedConversation.id === conversation.id }"
              >
                <div class="conversation-content" @click="selectConversation(conversation)">
                  <img :src="conversation.avatar" alt="头像" class="avatar">
                  <div class="conversation-info">
                    <div class="conversation-header">
                      <span class="username">{{ conversation.username }}</span>
                      <span class="time">{{ formatTime(conversation.lastMessageTime) }}</span>
                    </div>
                    <div class="last-message">{{ conversation.lastMessage }}</div>
                  </div>
                </div>
                <div class="conversation-actions">
                  <div v-if="conversation.unreadCount > 0" class="unread-badge">
                    {{ conversation.unreadCount > 99 ? '99+' : conversation.unreadCount }}
                  </div>
                  <button class="delete-conversation-btn" @click.stop="confirmDeleteConversation(conversation)" title="删除会话">
                    <el-icon><Delete /></el-icon>
                  </button>
                </div>
              </div>
            </template>
            <template v-else>
              <div 
                v-for="contact in contacts" 
                :key="contact.id" 
                class="conversation-item contact-item"
                @click="startConversationWith(contact)"
              >
                <div class="conversation-content">
                  <img :src="contact.avatar || contact.imageUrl || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'" alt="头像" class="avatar">
                  <div class="conversation-info">
                    <div class="conversation-header">
                      <span class="username">{{ contact.username }}</span>
                    </div>
                    <div class="last-message contact-bio">{{ contact.bio || '点击开始会话' }}</div>
                  </div>
                </div>
              </div>
            </template>
          </div>
        </div>
        
        <div class="chat-area">
          <div v-if="!selectedConversation" class="empty-chat">
            <div class="empty-chat-content">
              <el-icon size="48" color="#c0c4cc"><Message /></el-icon>
              <p>选择一个会话以开始聊天</p>
            </div>
          </div>
          
          <template v-else>
            <div class="chat-header">
              <span class="chat-with">{{ selectedConversation.username }}</span>
            </div>
            
            <div class="messages-list" ref="messagesList">
              <div v-if="messages.length === 0" class="empty-messages">
                暂无消息，开始聊天吧
              </div>
              <div 
                v-for="(message, index) in messages" 
                :key="index"
                class="message-item"
                :class="[
                  message.isSystem ? 'system' : 
                  (authStore.userInfo?.username === message.senderName) ? 'sent' : 'received',
                  {'send-failed': message.sendFailed}
                ]"
              >
                <!-- 对系统消息使用特殊样式 -->
                <div v-if="message.isSystem" class="system-message">
                  {{ message.content }}
                  <div class="message-time">{{ formatTime(message.sendTime || message.timestamp) }}</div>
                </div>
                <template v-else>
                  <div :class="['message-bubble', message.sendFailed ? 'failed' : '']">
                    <template v-if="message.attachment || message.attachmentUrl">
                      <div v-if="(message.attachment && message.attachment.type === 'image') || message.attachmentType === 'image'" class="message-image">
                        <el-image 
                          :src="message.attachment?.url || message.attachmentUrl" 
                          :preview-src-list="[message.attachment?.url || message.attachmentUrl]"
                          fit="cover">
                        </el-image>
                      </div>
                      <div v-else class="message-file">
                        <i class="el-icon-document"></i>
                        <span class="file-name">{{ message.attachment?.name || message.attachmentName }}</span>
                        <a :href="message.attachment?.url || message.attachmentUrl" target="_blank" class="file-download">
                          <i class="el-icon-download"></i>
                        </a>
                      </div>
                    </template>
                    <div v-if="message.content" class="message-text">{{ message.content }}</div>
                    <button v-if="message.sendFailed" class="retry-button" @click="retryMessage(message)">
                      <el-icon><RefreshRight /></el-icon> 重试
                    </button>
                  </div>
                  <div class="message-time">{{ formatTime(message.sendTime || message.timestamp) }}</div>
                </template>
              </div>
            </div>
            
            <div class="message-input">
              <div class="message-textarea-container">
                <textarea 
                  ref="messageInputRef"
                  v-model="newMessage" 
                  placeholder="输入消息..." 
                  @keyup.enter.prevent="sendMessage"
                ></textarea>
                
                <!-- 文件预览区域 -->
                <div v-if="attachmentPreview.show" class="attachment-preview">
                  <div class="preview-content">
                    <div v-if="attachmentPreview.type === 'image'" class="image-preview">
                      <img :src="attachmentPreview.url" alt="图片预览" />
                    </div>
                    <div v-else class="file-preview">
                      <el-icon><Document /></el-icon>
                      <span>{{ attachmentPreview.name }}</span>
                    </div>
                  </div>
                  <div class="preview-close" @click="removeAttachment">
                    <el-icon><Close /></el-icon>
                  </div>
                </div>
              </div>
              
              <div class="send-actions">
                <button class="send-button" @click="sendMessage">
                  <span>发送</span>
                </button>
                
                <div class="attachment-buttons">
                  <label for="file-upload" class="attachment-button" title="发送文件">
                    <el-icon><Document /></el-icon>
                  </label>
                  <input type="file" id="file-upload" class="file-input" @change="handleFileUpload" />
                  
                  <div class="attachment-button" title="转发收藏" @click="showForwardDialog">
                    <el-icon><Star /></el-icon>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>

    <!-- 转发收藏对话框 -->
    <div v-if="forwardDialog.show" class="forward-dialog">
      <div class="forward-dialog-header">
        <span>转发收藏</span>
        <div class="dialog-close" @click="forwardDialog.show = false">
          <el-icon><Close /></el-icon>
        </div>
      </div>
      <div class="forward-dialog-content">
        <div class="forward-tabs">
          <div 
            class="forward-tab" 
            :class="{ 'active': forwardDialog.activeTab === 'forward' }"
            @click="activateForwardTab"
          >
            联系人
          </div>
          <div 
            class="forward-tab" 
            :class="{ 'active': forwardDialog.activeTab === 'favorite' }"
            @click="loadUserFavorites"
          >
            我的收藏
          </div>
        </div>
        
        <div v-if="forwardDialog.activeTab === 'forward'" class="tab-content">
          <div class="loading" v-if="loadingContacts">
            <el-icon><Loading /></el-icon> 加载联系人中...
          </div>
          <div v-else-if="forwardDialog.contacts.length === 0" class="empty-favorites">
            暂无联系人
          </div>
          <div v-else class="contact-list">
            <div 
              v-for="contact in forwardDialog.contacts" 
              :key="contact.id"
              class="contact-item"
              @click="toggleContactSelection(contact)"
            >
              <img :src="contact.avatar || contact.imageUrl || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'" :alt="contact.username" class="contact-avatar">
              <span class="contact-name">{{ contact.username }}</span>
              <div class="contact-checkbox" :class="{ 'selected': contact.selected }">
                <el-icon v-if="contact.selected"><Check /></el-icon>
              </div>
            </div>
          </div>
          <button class="action-button" @click="forwardSelectedPost" :disabled="!hasSelectedContacts || !selectedFavorite">
            转发
          </button>
        </div>
        
        <div v-else class="tab-content">
          <div class="loading" v-if="loadingFavorites">
            <el-icon><Loading /></el-icon> 加载收藏帖子中...
          </div>
          <div v-else-if="forwardDialog.favorites.length === 0" class="empty-favorites">
            还没有收藏帖子，快去收藏一些内容吧
          </div>
          <div v-else>
            <div 
              v-for="favorite in forwardDialog.favorites" 
              :key="favorite.id"
              class="favorite-item"
              :class="{ 'selected': selectedFavorite && selectedFavorite.id === favorite.id }"
              @click="selectFavorite(favorite)"
            >
              <div class="favorite-title">{{ favorite.title }}</div>
              <div class="favorite-summary">{{ truncate(favorite.content, 50) }}</div>
              <div class="favorite-date">{{ formatDate(favorite.favoriteDate) }}</div>
            </div>
          </div>
          <button 
            class="action-button" 
            @click="forwardDialog.activeTab = 'forward'"
            :disabled="!selectedFavorite"
          >
            下一步
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue';
import { useAuthStore } from '../stores/auth.js';
import { useRouter, useRoute } from 'vue-router';
import axios from 'axios';
import { Message, Document, Picture, Close, Star, Check, RefreshRight, Loading, Delete } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const currentUserId = computed(() => authStore.userInfo?.id);

// 会话列表
const conversations = ref([]);
const selectedConversation = ref(null);
const activeConversationId = ref(null);

// 当前选中会话的消息
const messages = ref([]);
const newMessage = ref('');
const messagesList = ref(null);

// 添加附件相关状态
const attachmentPreview = ref({
  show: false,
  type: '', // 'image' 或 'file'
  file: null,
  url: '',
  name: ''
});

// 添加转发收藏相关状态
const forwardDialog = ref({
  show: false,
  activeTab: 'favorite',
  contacts: [],
  favorites: []
});

// 选中的收藏帖子
const selectedFavorite = ref(null);

// 添加加载状态变量
const loadingFavorites = ref(false);
const loadingContacts = ref(false);

// 页面导航方法
const goToPage = (path) => {
  router.push({ path: `/${path}` })
    .catch((error) => {
      console.error('路由跳转出错:', error);
    });
};

// 滚动到消息列表底部
const scrollToBottom = () => {
  if (messagesList.value) {
    messagesList.value.scrollTop = messagesList.value.scrollHeight;
  }
};

// 加载会话列表
const loadConversations = async () => {
  try {
    if (!authStore.isLoggedIn) return;
    
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    const response = await axios.get('http://localhost:7070/api/messages/conversations', {
      headers: {
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    if (response.status === 200) {
      // 根据API返回的数据格式进行处理
      let conversationsData = [];
      if (response.data && response.data.data) {
        conversationsData = response.data.data || [];
      } else {
        conversationsData = response.data || [];
      }
      
      console.log('API返回的原始数据:', response.data);
      console.log('提取的会话数据:', conversationsData);
      
      // 过滤掉无效的会话项
      conversationsData = conversationsData.filter(conv => {
        // 验证会话有必要的数据 - 注意API返回的是conversationId而不是id
        const isValid = conv && 
                       ((conv.conversationId || conv.id) && 
                        (conv.conversationId !== 'undefined' && conv.id !== 'undefined')) && 
                       (conv.username || conv.otherUsername);
        
        if (!isValid) {
          console.warn('过滤掉无效会话:', conv);
        }
        return isValid;
      });
      
      // 字段名称标准化处理
      conversationsData = conversationsData.map(conv => {
        // 如果API返回的是conversationId而不是id，进行统一处理
        if (conv.conversationId && !conv.id) {
          conv.id = conv.conversationId;
        }
        return conv;
      });
      
      console.log('处理后的最终会话数据:', conversationsData);
      conversations.value = conversationsData;
      
      // 如果需要，加载联系人列表
      try {
        loadContacts();
      } catch (contactsError) {
        console.error('加载联系人失败, 但继续执行:', contactsError);
      }
      
      // 检查URL参数，判断是否需要打开特定用户的会话
      // 即使会话列表为空，也尝试处理直接消息请求
      checkForDirectMessage();
    }
  } catch (error) {
    console.error('加载会话列表失败:', error);
    // 显示错误提示
    ElMessage.error('无法加载会话列表，请检查网络连接或重新登录');
    conversations.value = []; // 确保会话列表为空数组而不是undefined
    
    // 即使会话列表加载失败，仍尝试处理可能的直接消息请求
    checkForDirectMessage();
  }
};

// 检查是否需要打开特定用户的私信会话
const checkForDirectMessage = async () => {
  try {
    // 检查URL参数中是否有userId
    const userId = route.query.userId;
    if (!userId) return;
    
    console.log('检测到URL参数中的userId:', userId);
    
    // 查找是否已有与该用户的会话
    const existingConversation = conversations.value.find(
      conv => (conv.userId === userId || conv.otherUserId === userId)
    );
    
    if (existingConversation) {
      // 如果已有会话，直接选择
      console.log('找到现有会话，选择此会话:', existingConversation);
      selectConversation(existingConversation);
    } else {
      // 否则创建新会话
      console.log('未找到与用户的现有会话，创建新会话');
      await createNewConversation(userId);
    }
    
    // 清除URL参数，避免刷新页面时重复处理
    if (window.history.replaceState) {
      const newUrl = window.location.pathname;
      window.history.replaceState({ path: newUrl }, '', newUrl);
    }
  } catch (error) {
    console.error('处理直接消息请求失败:', error);
    ElMessage.error('无法打开请求的会话，请稍后再试');
  }
};

// 加载联系人列表
const loadContacts = async () => {
  try {
    loadingContacts.value = true;
    console.log('开始加载联系人...');
    
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    // 使用 /api/users/contacts 作为主要API端点
    const response = await axios.get('http://localhost:7070/api/users/contacts', {
      headers: {
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    console.log('联系人API返回:', response);
    
    if (response.status === 200) {
      // 处理API返回数据
      let contactsData = [];
      if (response.data && response.data.data) {
        contactsData = response.data.data || [];
      } else {
        contactsData = response.data || [];
      }
      
      console.log('联系人数据获取成功，原始数据:', contactsData);
      
      if (contactsData.length === 0) {
        console.warn('API返回的联系人列表为空');
      }
      
      // 转换联系人数据格式，添加selected属性
      forwardDialog.value.contacts = contactsData.map(contact => ({
        ...contact,
        // 确保头像字段一致性，支持两种可能的字段名
        avatar: contact.avatar || contact.imageUrl,
        selected: false
      }));
      
      console.log('处理后的联系人数据:', forwardDialog.value.contacts);
    }
  } catch (error) {
    console.error('加载联系人失败:', error);
    // 尝试备用API端点，按优先级尝试
    try {
      const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
      // 尝试第二个可能的端点
      const response = await axios.get('http://localhost:7070/api/messages/contacts', {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      });
      
      console.log('备用联系人API返回:', response);
      
      if (response.status === 200) {
        let contactsData = [];
        if (response.data && response.data.data) {
          contactsData = response.data.data || [];
        } else {
          contactsData = response.data || [];
        }
        
        forwardDialog.value.contacts = contactsData.map(contact => ({
          ...contact,
          // 确保头像字段一致性，支持两种可能的字段名
          avatar: contact.avatar || contact.imageUrl,
          selected: false
        }));
        
        console.log('从备用API获取的联系人:', forwardDialog.value.contacts);
      }
    } catch (backupError) {
      console.error('第一个备用联系人API失败:', backupError);
      // 尝试第三个可能的端点 - 获取所有用户
      try {
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        const response = await axios.get('http://localhost:7070/api/users/all', {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        });
        
        if (response.status === 200) {
          let contactsData = [];
          if (response.data && response.data.data) {
            contactsData = response.data.data || [];
          } else {
            contactsData = response.data || [];
          }
          
          forwardDialog.value.contacts = contactsData.map(contact => ({
            ...contact,
            // 确保头像字段一致性，支持两种可能的字段名
            avatar: contact.avatar || contact.imageUrl,
            selected: false
          }));
          
          console.log('从第三个备用API获取的联系人:', forwardDialog.value.contacts);
        }
      } catch (thirdError) {
        console.error('所有联系人API尝试均失败:', thirdError);
        forwardDialog.value.contacts = []; // 保留空联系人列表
        
        // 当联系人无法加载时，创建一个暂时性的列表
        if (selectedConversation.value) {
          forwardDialog.value.contacts = [{
            id: selectedConversation.value.userId || selectedConversation.value.otherUserId,
            username: selectedConversation.value.username,
            avatar: selectedConversation.value.avatar,
            selected: false
          }];
          console.log('创建了基于当前会话的临时联系人:', forwardDialog.value.contacts);
        }
      }
    }
  } finally {
    loadingContacts.value = false;
    console.log('联系人加载完成，最终数量:', forwardDialog.value.contacts.length);
  }
};

// 选择会话
const selectConversation = async (conversation) => {
  // 验证会话对象和ID是否有效
  if (!conversation || !conversation.id) {
    console.error('尝试选择无效的会话:', conversation);
    ElMessage.warning('无法选择会话，数据无效');
    return;
  }

  console.log('选择会话:', conversation.id, conversation.username || conversation.otherUsername);
  selectedConversation.value = conversation;
  console.log('设置当前选中会话为:', JSON.stringify(selectedConversation.value));
  
  // 加载会话消息 - 让loadMessages函数处理临时会话ID的情况
  await loadMessages(conversation.id);
  
  // 只有非临时会话才需要标记已读
  const isTemporaryChat = typeof conversation.id === 'string' && conversation.id.startsWith('new_');
  
  // 标记会话为已读
  if (!isTemporaryChat && conversation.unreadCount > 0) {
    try {
      const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
      await axios.put(`http://localhost:7070/api/messages/conversations/${conversation.id}/read`, {}, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      });
      
      // 更新本地会话未读数
      conversation.unreadCount = 0;
    } catch (error) {
      console.error('标记会话已读失败:', error);
    }
  }
};

// 加载消息
const loadMessages = async (conversationId) => {
  try {
    if (!authStore.isLoggedIn) return;
    
    // 验证会话ID或用户ID是否有效
    if (!conversationId || conversationId === 'undefined' || conversationId === undefined) {
      console.error('尝试加载消息，但会话ID/用户ID无效:', conversationId);
      ElMessage.warning('无法加载消息，ID无效');
      messages.value = []; // 清空消息列表
      return;
    }
    
    // 检查是否为临时会话ID（以new_开头或temp_开头）
    const isTemporaryChat = typeof conversationId === 'string' && 
                           (conversationId.startsWith('new_') || 
                            conversationId.startsWith('temp_'));
                            
    if (isTemporaryChat) {
      console.log('临时会话，不加载历史消息:', conversationId);
      messages.value = []; // 清空消息列表
      
      // 添加一条系统消息提示用户
      const targetUsername = selectedConversation.value?.username || '此用户';
      messages.value.push({
        id: `system_${Date.now()}`,
        isSystem: true,
        content: `与 ${targetUsername} 的新对话，发送消息开始聊天`,
        timestamp: new Date().toISOString()
      });
      
      // 即使是临时会话也尝试滚动到底部
      await nextTick();
      scrollToBottom();
      return;
    }
    
    console.log('开始加载会话消息，ID:', conversationId);
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    
    // 获取当前会话的对方用户ID
    const targetUserId = selectedConversation.value?.userId || selectedConversation.value?.otherUserId;
    
    // 确定使用哪个ID调用API
    // 如果是标准会话ID(数字)，使用/messages/会话ID
    // 如果是用户ID，使用/messages/用户ID
    const apiEndpoint = `http://localhost:7070/api/messages/${targetUserId}`;
    
    console.log('使用API端点:', apiEndpoint);
    
    try {
      const response = await axios.get(apiEndpoint, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      });
      
      if (response.status === 200) {
        console.log('API消息数据响应:', response.data);
        
        // 提取消息数组，正确处理API返回的数据结构
        let messagesData = [];
        if (response.data && Array.isArray(response.data)) {
          messagesData = response.data;
        } else if (response.data && response.data.data && Array.isArray(response.data.data)) {
          messagesData = response.data.data;
        } else {
          console.warn('API响应格式不符合预期，初始化为空数组');
          messagesData = [];
        }
        
        // 确保messagesData是数组
        console.log('messagesData是数组:', Array.isArray(messagesData), '长度:', messagesData.length);
        
        // 设置消息列表
        messages.value = messagesData;
        
        if (messagesData.length === 0) {
          // 如果没有消息，添加一条系统消息提示用户
          const targetUsername = selectedConversation.value?.username || '此用户';
          messages.value.push({
            id: `system_${Date.now()}`,
            isSystem: true,
            content: `与 ${targetUsername} 的新对话，发送消息开始聊天`,
            timestamp: new Date().toISOString()
          });
        }
        
        console.log('设置消息列表为数组，长度:', messages.value.length);
        console.log('消息加载成功，数量:', messages.value.length);
      }
    } catch (apiError) {
      console.error('API请求失败:', apiError);
      
      if (apiError.response && apiError.response.status === 400) {
        console.warn('收到400错误，可能是ID格式不正确或者服务器不接受此ID:', conversationId);
        // 添加一条系统消息提示用户
        messages.value = [{
          id: `system_error_${Date.now()}`,
          isSystem: true,
          content: '无法加载历史消息，可能是新对话或服务器错误',
          timestamp: new Date().toISOString()
        }];
      } else {
        ElMessage.error('无法加载消息，请检查网络连接或重新登录');
        messages.value = []; // 清空消息列表
        // 添加一条系统消息
        messages.value.push({
          id: `system_${Date.now()}`,
          isSystem: true,
          content: `与 ${selectedConversation.value?.username || '此用户'} 的新对话，发送消息开始聊天`,
          timestamp: new Date().toISOString()
        });
      }
    }
  } catch (error) {
    console.error('加载消息失败:', error);
    ElMessage.error('无法加载消息，请检查网络连接或重新登录');
    messages.value = []; // 清空消息列表
    // 添加一条系统消息
    messages.value.push({
      id: `system_${Date.now()}`,
      isSystem: true,
      content: `与 ${selectedConversation.value?.username || '此用户'} 的新对话，发送消息开始聊天`,
      timestamp: new Date().toISOString()
    });
  }
  
  // 滚动到最新消息
  await nextTick();
  scrollToBottom();
};

// 处理文件上传
const handleFileUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;
  
  // 文件大小限制 (10MB)
  const maxSize = 10 * 1024 * 1024;
  if (file.size > maxSize) {
    ElMessage.error('文件大小不能超过10MB');
    event.target.value = ''; // 清空文件输入
    return;
  }
  
  // 显示上传前预览
  attachmentPreview.value = {
    show: true,
    type: 'file',
    file: file,
    url: '',
    name: file.name
  };
  
  // 重置文件输入，允许选择相同文件
  event.target.value = '';
  
  try {
    // 开始上传文件
    const formData = new FormData();
    formData.append('file', file);
    
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    const response = await axios.post('http://localhost:7070/api/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    if (response.status === 200) {
      // 更新预览信息为上传后的URL
      attachmentPreview.value.url = response.data.url;
      attachmentPreview.value.name = response.data.name || file.name;
      attachmentPreview.value.type = response.data.type || 'file';
    }
  } catch (error) {
    console.error('文件上传失败:', error);
    ElMessage.error('文件上传失败，请重试');
    removeAttachment();
  }
};

// 处理图片上传
const handleImageUpload = (event) => {
  const file = event.target.files[0];
  if (!file) return;
  
  // 创建预览URL
  const previewUrl = URL.createObjectURL(file);
  
  attachmentPreview.value = {
    show: true,
    type: 'image',
    file: file,
    url: previewUrl,
    name: file.name
  };
  
  // 重置文件输入，允许选择相同图片
  event.target.value = '';
};

// 移除附件
const removeAttachment = () => {
  if (attachmentPreview.value.url) {
    URL.revokeObjectURL(attachmentPreview.value.url);
  }
  
  attachmentPreview.value = {
    show: false,
    type: '',
    file: null,
    url: '',
    name: ''
  };
};

// 发送消息
const sendMessage = async () => {
  // 检查消息内容和会话是否有效
  if ((!newMessage.value.trim() && !attachmentPreview.value.show) || !selectedConversation.value) {
    console.log('消息为空或没有选择会话，不发送');
    return;
  }
  
  console.log('开始发送消息:', newMessage.value);

  // 添加更详细的消息列表检查
  console.log('消息列表类型检查:',
    'messages.value类型:', typeof messages.value,
    'Array.isArray(messages.value):', Array.isArray(messages.value),
    'messages.value instanceof Object:', messages.value instanceof Object
  );
  
  // 如果不是数组，强制转换为数组
  if (!Array.isArray(messages.value)) {
    console.warn('消息列表不是数组，正在重置为空数组', messages.value);
    messages.value = [];
  }
  
  // 判断是否是临时会话ID
  const isTemporaryChat = typeof selectedConversation.value.id === 'string' && 
                         (selectedConversation.value.id.startsWith('new_') || 
                          selectedConversation.value.id.startsWith('temp_'));
  
  // 构建消息对象（临时ID用于前端展示）
  const tempId = `temp_${Date.now()}`;
  const newMessageData = {
    id: tempId,
    conversationId: selectedConversation.value.id,
    senderId: currentUserId.value,
    senderName: authStore.userInfo?.username,
    senderAvatar: authStore.userInfo?.avatar,
    receiverId: selectedConversation.value.userId || selectedConversation.value.otherUserId,
    receiverName: selectedConversation.value.username,
    receiverAvatar: selectedConversation.value.avatar,
    content: newMessage.value.trim(),
    timestamp: new Date().toISOString(),
    isSentByCurrentUser: true,
    read: false
  };
  
  // 如果有文件或图片附件
  if (attachmentPreview.value.show) {
    const file = attachmentPreview.value.file;
    // 检查文件大小
    if (file.size > 10 * 1024 * 1024) { // 10MB限制
      ElMessage.error('文件大小不能超过10MB');
      return;
    }
    
    // 准备附件信息
    newMessageData.attachment = {
      name: file.name,
      type: attachmentPreview.value.type,
      // 临时URL用于前端预览
      url: attachmentPreview.value.url || URL.createObjectURL(file)
    };
  }
  
  // 先将消息添加到列表中（乐观UI更新）
  if (!Array.isArray(messages.value)) {
    messages.value = [];
  }
  messages.value = [...messages.value, newMessageData];
  console.log('消息已添加到列表中，当前消息姓名:', newMessageData.senderName, '当前用户姓名:', authStore.userInfo?.username);
  
  // 清空输入和附件选择
  const messageContent = newMessage.value.trim(); // 保存内容用于日志
  newMessage.value = '';
  removeAttachment();
  
  // 滚动到底部显示新消息
  scrollToBottom();
  
  // 构建要发送的消息数据
  const messageData = {
    receiverId: newMessageData.receiverId,
    content: newMessageData.content,
  };
  
  // 如果不是新会话则添加会话ID
  if (!isTemporaryChat) {
    // 对于非临时会话ID，检查是否需要转换为数字
    if (typeof selectedConversation.value.id === 'string' && !isNaN(parseInt(selectedConversation.value.id))) {
      messageData.conversationId = parseInt(selectedConversation.value.id);
    } else {
      messageData.conversationId = selectedConversation.value.id;
    }
  }
  
  console.log('准备发送的消息数据:', messageData);
  
  // 处理文件上传
  if (newMessageData.attachment) {
    try {
      const file = attachmentPreview.value.file;
      const formData = new FormData();
      formData.append('file', file);
      
      const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
      const uploadResponse = await axios.post('http://localhost:7070/api/upload', formData, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`,
          'Content-Type': 'multipart/form-data'
        }
      });
      
      if (uploadResponse.status === 200) {
        messageData.attachment = {
          url: uploadResponse.data.url,
          name: file.name,
          type: newMessageData.attachment.type
        };
      }
    } catch (error) {
      console.error('文件上传失败:', error);
      // 标记消息发送失败
      const messageIndex = messages.value.findIndex(msg => msg.id === tempId);
      if (messageIndex !== -1) {
        messages.value[messageIndex].sendFailed = true;
      }
      ElMessage.error('文件上传失败，请检查网络连接或者稍后重试');
      return;
    }
  }
  
  // 发送消息到服务器
  try {
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    console.log('开始发送API请求...');
    
    const response = await axios.post('http://localhost:7070/api/messages/send', messageData, {
      headers: {
        'Authorization': `Bearer ${jwtToken}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('消息发送API响应:', response);
    
    if (response.status === 200) {
      console.log('发送消息成功，API响应:', response.data);
      
      // 新的对话需要更新ID
      if (isTemporaryChat) {
        // 从API响应中尝试获取会话ID
        let conversationId;
        
        // 尝试多种可能的字段名找到会话ID
        if (response.data && response.data.conversationId) {
          conversationId = response.data.conversationId;
        } else if (response.data && response.data.id) {
          conversationId = response.data.id;
        } else if (response.data && response.data.data) {
          // 尝试在data子对象中查找
          if (response.data.data.conversationId) {
            conversationId = response.data.data.conversationId;
          } else if (response.data.data.id) {
            conversationId = response.data.data.id;
          }
        }
        
        // 如果找不到会话ID，使用接收者ID作为备选
        if (!conversationId && response.data && response.data.receiverId) {
          conversationId = response.data.receiverId;
          console.warn('无法从API响应中找到会话ID，使用receiverId代替:', conversationId);
        } else if (!conversationId) {
          // 最后的备选：使用一个随机ID加上时间戳
          conversationId = new Date().getTime();
          console.warn('无法获取有效会话ID，使用时间戳代替:', conversationId);
        }
        
        console.log('创建临时会话后获取到会话ID:', conversationId);
        
        // 创建新的会话对象
        const newConversation = {
          id: conversationId,
          userId: selectedConversation.value.userId || selectedConversation.value.otherUserId,
          otherUserId: selectedConversation.value.userId || selectedConversation.value.otherUserId,
          username: selectedConversation.value.username,
          avatar: selectedConversation.value.avatar,
          lastMessage: messageData.content || (messageData.attachment ? 
            `[${messageData.attachment.type === 'image' ? '图片' : '文件'}]` : ''),
          lastMessageTime: new Date().toISOString(),
          unreadCount: 0
        };
        
        console.log('新创建的会话对象:', newConversation);
        
        // 替换临时会话并更新选中的会话
        const tempIndex = conversations.value.findIndex(c => c.id === selectedConversation.value.id);
        if (tempIndex !== -1) {
          conversations.value.splice(tempIndex, 1, newConversation);
        } else {
          conversations.value.unshift(newConversation);
        }
        
        // 更新当前选中的会话
        selectedConversation.value = newConversation;
        activeConversationId.value = newConversation.id;
        
        // 用实际获取的消息替换临时消息
        const messageIndex = messages.value.findIndex(msg => msg.id === tempId);
        if (messageIndex !== -1) {
          const serverMessage = response.data;
          // 确保消息包含会话ID
          if (serverMessage) {
            serverMessage.conversationId = conversationId;
            messages.value.splice(messageIndex, 1, serverMessage);
          }
        }
      } else {
        // 更新现有会话的最后消息
        const conversationIndex = conversations.value.findIndex(c => c.id === selectedConversation.value.id);
        if (conversationIndex !== -1) {
          conversations.value[conversationIndex].lastMessage = messageData.content || 
            (messageData.attachment ? `[${messageData.attachment.type === 'image' ? '图片' : '文件'}]` : '');
          conversations.value[conversationIndex].lastMessageTime = new Date().toISOString();
          
          // 将这个会话移到列表顶部
          const updatedConversation = conversations.value.splice(conversationIndex, 1)[0];
          conversations.value.unshift(updatedConversation);
        }
        
        // 用实际获取的消息替换临时消息
        const messageIndex = messages.value.findIndex(msg => msg.id === tempId);
        if (messageIndex !== -1) {
          const serverMessage = response.data;
          // 确保消息包含会话ID
          if (serverMessage) {
            messages.value.splice(messageIndex, 1, serverMessage);
          }
        }
      }
      
      console.log('消息发送完成，更新了UI');
      
      // 消息发送成功后，立即重新获取最新的消息列表
      try {
        const targetUserId = selectedConversation.value.userId || selectedConversation.value.otherUserId;
        console.log('正在重新获取最新消息列表，用户ID:', targetUserId);
        
        const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
        const refreshResponse = await axios.get(`http://localhost:7070/api/messages/${targetUserId}`, {
          headers: {
            'Authorization': `Bearer ${jwtToken}`
          }
        });
        
        if (refreshResponse.status === 200) {
          console.log('重新获取消息成功:', refreshResponse.data);
          
          // 提取消息数组，正确处理API返回的数据结构
          let messagesData = [];
          if (refreshResponse.data && Array.isArray(refreshResponse.data)) {
            messagesData = refreshResponse.data;
          } else if (refreshResponse.data && refreshResponse.data.data && Array.isArray(refreshResponse.data.data)) {
            messagesData = refreshResponse.data.data;
          } else {
            console.warn('消息刷新API响应格式不符合预期');
            return; // 不更新消息列表
          }
          
          // 更新消息列表并滚动到底部
          messages.value = messagesData;
          nextTick(() => {
            scrollToBottom();
          });
        }
      } catch (refreshError) {
        console.error('重新获取消息失败:', refreshError);
        // 这个错误不会影响用户体验，所以不显示错误提示
      }
    }
  } catch (error) {
    console.error('发送消息失败:', error);
    // 标记消息发送失败
    const messageIndex = messages.value.findIndex(msg => msg.id === tempId);
    if (messageIndex !== -1) {
      messages.value[messageIndex].sendFailed = true;
    }
    ElMessage.error('消息发送失败，请检查网络连接后重试');
  }
};

// 重试发送失败的消息
const retryMessage = async (message) => {
  // 获取消息在数组中的索引
  const messageIndex = messages.value.findIndex(msg => msg.id === message.id);
  if (messageIndex === -1) return;
  
  // 将消息标记为发送中
  messages.value[messageIndex] = {
    ...messages.value[messageIndex],
    sendFailed: false,
    sending: true
  };
  
  // 判断是否是临时会话ID
  const isTemporaryChat = typeof selectedConversation.value.id === 'string' && 
                         (selectedConversation.value.id.startsWith('new_') || 
                          selectedConversation.value.id.startsWith('temp_'));
  
  // 构建要发送的消息数据
  const messageData = {
    receiverId: selectedConversation.value.userId || selectedConversation.value.otherUserId,
    content: message.content
  };
  
  // 如果不是临时会话，添加会话ID
  if (!isTemporaryChat) {
    // 对于非临时会话ID，检查是否需要转换为数字
    if (typeof selectedConversation.value.id === 'string' && !isNaN(parseInt(selectedConversation.value.id))) {
      messageData.conversationId = parseInt(selectedConversation.value.id);
    } else {
      messageData.conversationId = selectedConversation.value.id;
    }
  }
  
  // 处理附件（如果有）
  let formData = null;
  if (message.attachment) {
    if (message.attachment.file) {
      formData = new FormData();
      formData.append('file', message.attachment.file);
      formData.append('messageData', JSON.stringify(messageData));
    } else {
      messageData.attachment = message.attachment;
    }
  }
  
  try {
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    let response;
    
    if (formData) {
      response = await axios.post('http://localhost:7070/api/messages/upload', formData, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`,
          'Content-Type': 'multipart/form-data'
        }
      });
    } else {
      response = await axios.post('http://localhost:7070/api/messages/send', messageData, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      });
    }
    
    if (response.status === 200) {
      console.log('重发消息成功，API响应:', response.data);
      
      // 如果原来是临时会话，需要更新会话ID
      if (isTemporaryChat) {
        // 从API响应中尝试获取会话ID
        let conversationId;
        
        // 尝试多种可能的字段名找到会话ID
        if (response.data && response.data.conversationId) {
          conversationId = response.data.conversationId;
        } else if (response.data && response.data.id) {
          conversationId = response.data.id;
        } else if (response.data && response.data.data) {
          // 尝试在data子对象中查找
          if (response.data.data.conversationId) {
            conversationId = response.data.data.conversationId;
          } else if (response.data.data.id) {
            conversationId = response.data.data.id;
          }
        }
        
        if (conversationId) {
          console.log('重发消息后获取到会话ID:', conversationId);
          
          // 创建新的会话对象
          const newConversation = {
            id: conversationId,
            userId: selectedConversation.value.userId || selectedConversation.value.otherUserId,
            otherUserId: selectedConversation.value.userId || selectedConversation.value.otherUserId,
            username: selectedConversation.value.username,
            avatar: selectedConversation.value.avatar,
            lastMessage: message.content || (message.attachment ? 
              `[${message.attachment.type === 'image' ? '图片' : '文件'}]` : ''),
            lastMessageTime: new Date().toISOString(),
            unreadCount: 0
          };
          
          // 替换临时会话并更新选中的会话
          const tempIndex = conversations.value.findIndex(c => c.id === selectedConversation.value.id);
          if (tempIndex !== -1) {
            conversations.value.splice(tempIndex, 1, newConversation);
          } else {
            conversations.value.unshift(newConversation);
          }
          
          // 更新当前选中的会话
          selectedConversation.value = newConversation;
          activeConversationId.value = newConversation.id;
        }
      }
      
      // 用服务器返回的消息替换失败的消息
      messages.value.splice(messageIndex, 1, {
        ...response.data,
        sending: false
      });
      
      // 更新会话最后一条消息
      const conversationIndex = conversations.value.findIndex(c => c.id === selectedConversation.value.id);
      if (conversationIndex !== -1) {
        conversations.value[conversationIndex].lastMessage = message.content || 
          (message.attachment ? `[${message.attachment.type === 'image' ? '图片' : '文件'}]` : '');
        conversations.value[conversationIndex].lastMessageTime = new Date().toISOString();
        
        // 将这个会话移到列表顶部
        const updatedConversation = conversations.value.splice(conversationIndex, 1)[0];
        conversations.value.unshift(updatedConversation);
      }
      
      ElMessage.success('消息重发成功');
    }
  } catch (error) {
    console.error('重发消息失败:', error);
    // 标记为发送失败
    messages.value[messageIndex] = {
      ...messages.value[messageIndex],
      sendFailed: true,
      sending: false
    };
    ElMessage.error('重发消息失败，请检查网络连接后重试');
  }
};

// 激活联系人标签
const activateForwardTab = () => {
  forwardDialog.value.activeTab = 'forward';
  
  // 如果联系人列表为空或过时，重新加载
  if (forwardDialog.value.contacts.length === 0) {
    loadContacts().then(() => {
      console.log('切换到联系人标签后加载完成，联系人数量:', forwardDialog.value.contacts.length);
    });
  } else {
    console.log('使用现有联系人列表，数量:', forwardDialog.value.contacts.length);
  }
};

// 确认删除会话
const confirmDeleteConversation = (conversation) => {
  if (!conversation) return;
  
  ElMessageBox.confirm(
    `确定要删除与 ${conversation.username || '此用户'} 的会话吗？删除后不可恢复。`,
    '删除会话',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning',
    }
  )
    .then(() => {
      deleteConversation(conversation);
    })
    .catch(() => {
      // 用户取消删除
    });
};

// 删除会话
const deleteConversation = async (conversation) => {
  try {
    // 如果当前选中的是要删除的会话，先清空
    if (selectedConversation.value && selectedConversation.value.id === conversation.id) {
      selectedConversation.value = null;
      messages.value = [];
    }
    
    // 从本地列表中移除
    const index = conversations.value.findIndex(c => c.id === conversation.id);
    if (index !== -1) {
      conversations.value.splice(index, 1);
    }
    
    // 如果是API创建的正式会话，向服务器发送删除请求
    if (conversation.id && !conversation.id.toString().startsWith('new_')) {
      const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
      await axios.delete(`http://localhost:7070/api/messages/conversations/${conversation.id}`, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      });
      ElMessage.success('会话已删除');
    } else {
      ElMessage.success('临时会话已移除');
    }
  } catch (error) {
    console.error('删除会话失败:', error);
    ElMessage.error('删除会话失败，但已从本地列表移除');
  }
};

// 添加状态变量
const activeTab = ref('chats');
const contacts = ref([]);

// 显示所有联系人
const showAllContacts = async () => {
  activeTab.value = 'contacts';
  
  // 如果联系人列表为空，重新加载
  if (contacts.value.length === 0) {
    await loadAllContacts();
  }
};

// 专门用于加载联系人列表到主界面
const loadAllContacts = async () => {
  try {
    if (!authStore.isLoggedIn) return;
    
    // 显示加载中提示
    contacts.value = [{ id: 'loading', username: '加载中...', avatar: null }];
    
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    // 使用与loadContacts相同的API
    const response = await axios.get('http://localhost:7070/api/users/contacts', {
      headers: {
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    if (response.status === 200) {
      console.log('联系人API返回:', response);
      // 处理API返回数据
      let contactsData = [];
      if (response.data && response.data.data) {
        contactsData = response.data.data || [];
      } else {
        contactsData = response.data || [];
      }
      
      console.log('主页面联系人数据加载成功:', contactsData);
      
      contacts.value = contactsData.map(contact => ({
        ...contact,
        // 确保头像字段一致性
        avatar: contact.avatar || contact.imageUrl,
      }));
    }
  } catch (error) {
    console.error('加载联系人列表失败:', error);
    contacts.value = [];
    ElMessage.error('无法加载联系人，请检查网络连接');
    
    // 失败时切换回会话标签
    setTimeout(() => {
      activeTab.value = 'chats';
    }, 1500);
  }
};

// 创建新的对话
const createNewConversation = async (userId) => {
  if (!userId) {
    console.error('创建新会话失败: 用户ID无效');
    throw new Error('无效的用户ID');
  }
  
  console.log('正在创建新会话，用户ID:', userId);
  
  // 尝试从现有联系人中获取用户信息
  let user = contacts.value.find(contact => contact.id === userId);
  
  // 如果联系人列表中没有，尝试通过API获取用户信息
  if (!user) {
    try {
      const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
      const response = await axios.get(`http://localhost:7070/api/users/${userId}`, {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      });
      
      if (response.status === 200 && response.data) {
        user = response.data;
        console.log('通过API获取的用户信息:', user);
      } else {
        throw new Error('无法获取用户信息');
      }
    } catch (error) {
      console.error('获取用户信息失败:', error);
      
      // 创建一个基本的用户对象，确保UI能够继续工作
      user = {
        id: userId,
        username: '用户#' + userId,
        avatar: null
      };
      console.log('创建了基本用户信息:', user);
    }
  }
  
  // 创建新的会话对象
  const newConversation = {
    id: 'temp_' + Date.now(),
    userId: user.id,
    username: user.username || '未知用户',
    avatar: user.avatar || null,
    lastMessage: null,
    unreadCount: 0,
    lastActivity: new Date().toISOString(),
    isNew: true
  };
  
  console.log('创建的新会话对象:', newConversation);
  
  // 添加到会话列表
  conversations.value.unshift(newConversation);
  
  // 选择新会话
  selectedConversation.value = newConversation;
  activeConversationId.value = newConversation.id;
  
  // 清空消息列表，因为这是一个新会话
  messages.value = [];
  
  // 发送系统消息，表示开始了新的对话
  messages.value.push({
    id: 'system_' + Date.now(),
    isSystem: true,
    content: `与 ${newConversation.username} 的会话开始了`,
    timestamp: new Date().toISOString()
  });
  
  // 滚动到底部并聚焦输入框
  nextTick(() => {
    scrollToBottom();
    if (messageInputRef.value) {
      messageInputRef.value.focus();
    }
  });
  
  return newConversation;
};

// 格式化日期的辅助函数
const formatDate = (dateStr) => {
  if (!dateStr) return '';
  
  const date = new Date(dateStr);
  return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
};

// 格式化时间的辅助函数
const formatTime = (timestamp) => {
  if (!timestamp) return '';
  
  // 直接从时间字符串提取时间部分，格式如"2025-04-19T16:27:57.000Z"
  try {
    // 使用正则表达式提取时间部分
    const timeMatch = timestamp.match(/T(\d{2}):(\d{2}):/);
    if (timeMatch) {
      // 直接使用提取的小时和分钟，不进行时区调整
      const hour = timeMatch[1];
      const minute = timeMatch[2];
      
      return `${hour}:${minute}`;
    }
    
    // 如果无法匹配，直接返回原始时间的一部分
    return timestamp.substring(11, 16);
  } catch (e) {
    console.error('解析日期出错:', e);
    return timestamp; // 出错时返回原始值
  }
};

// 加载转发对话框中的用户收藏帖子
const loadUserFavorites = async () => {
  try {
    loadingFavorites.value = true;
    console.log('开始加载收藏帖子...');
    
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    const response = await axios.get('http://localhost:7070/api/messages/favorites', {
      headers: {
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    if (response.status === 200) {
      forwardDialog.value.favorites = response.data || [];
      console.log('收藏帖子加载成功:', forwardDialog.value.favorites);
    }
  } catch (error) {
    console.error('加载收藏帖子失败:', error);
    ElMessage.error('无法加载收藏帖子，请检查网络连接或重新登录');
    forwardDialog.value.favorites = [];
  } finally {
    loadingFavorites.value = false;
    console.log('收藏帖子加载完成，最终数量:', forwardDialog.value.favorites.length);
  }
};

// 开始与联系人的对话
const startConversationWith = async (contact) => {
  if (!contact || !contact.id) return;
  
  console.log('开始与联系人对话:', contact);
  
  // 检查是否已有会话
  const existingConversation = conversations.value.find(
    conv => (conv.userId === contact.id || conv.otherUserId === contact.id)
  );
  
  if (existingConversation) {
    // 如果已有会话，直接选择
    selectConversation(existingConversation);
    activeTab.value = 'chats'; // 切换回会话标签
  } else {
    // 否则创建新会话，但先尝试加载消息历史
    try {
      // 先尝试加载与该用户的消息历史
      const messageHistory = await loadMessagesByUserId(contact.id);
      
      // 如果找到消息历史但没有会话，创建对应的会话
      if (messageHistory && messageHistory.length > 0) {
        // 创建基于现有消息的会话
        const latestMessage = messageHistory[messageHistory.length - 1];
        const conversationId = latestMessage.conversationId;
        
        // 创建会话对象
        const newConversation = {
          id: conversationId || 'temp_' + Date.now(),
          userId: contact.id,
          otherUserId: contact.id,
          username: contact.username || '未知用户',
          avatar: contact.avatar || contact.imageUrl || null,
          lastMessage: latestMessage.content || '新会话',
          lastMessageTime: latestMessage.timestamp || new Date().toISOString(),
          unreadCount: 0
        };
        
        // 添加到会话列表
        conversations.value.unshift(newConversation);
        
        // 选择新会话
        selectedConversation.value = newConversation;
        activeConversationId.value = newConversation.id;
        
        // 切换回会话标签
        activeTab.value = 'chats';
        
        console.log('基于现有消息创建了新会话:', newConversation);
      } else {
        // 如果没有消息历史，则创建全新会话
        await createNewConversation(contact.id);
        activeTab.value = 'chats';
      }
    } catch (error) {
      console.error('创建与联系人的新会话失败:', error);
      // 回退到标准方法
      await createNewConversation(contact.id);
      activeTab.value = 'chats';
    }
  }
  
  // 确保输入框获得焦点，让用户可以立即输入
  nextTick(() => {
    const textarea = document.querySelector('.message-input textarea');
    if (textarea) {
      textarea.focus();
    }
  });
};

// 在组件挂载后自动加载会话列表
onMounted(() => {
  console.log('私信页面已加载，正在获取会话列表...');
  loadConversations();
});

// 修改加载消息的方法，支持直接通过用户ID加载消息
const loadMessagesByUserId = async (userId) => {
  try {
    if (!authStore.isLoggedIn || !userId) return;
    
    console.log('通过用户ID直接加载消息历史:', userId);
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    
    // 调用API获取与特定用户的消息历史
    const response = await axios.get(`http://localhost:7070/api/messages/user/${userId}`, {
      headers: {
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    if (response.status === 200) {
      console.log('直接加载用户消息成功:', response.data);
      
      // 处理API返回的消息数据
      let messagesData = [];
      if (response.data && response.data.data && Array.isArray(response.data.data)) {
        messagesData = response.data.data;
      } else if (Array.isArray(response.data)) {
        messagesData = response.data;
      } else {
        console.warn('API响应格式不符合预期，使用空数组');
        messagesData = [];
      }
      
      // 确保messagesData是数组
      console.log('messagesData是数组:', Array.isArray(messagesData), '长度:', messagesData.length);
      
      // 设置消息列表
      messages.value = messagesData;
      
      // 滚动到最新消息
      await nextTick();
      scrollToBottom();
      
      return messagesData;
    }
  } catch (error) {
    console.error('通过用户ID加载消息失败:', error);
    ElMessage.error('无法加载与该用户的消息历史，请稍后再试');
    messages.value = []; // 清空消息列表
    
    // 添加一条系统消息
    messages.value = [{
      id: `system_${Date.now()}`,
      isSystem: true,
      content: `无法加载历史消息，这可能是一个新对话`,
      timestamp: new Date().toISOString()
    }];
    
    // 滚动到底部
    await nextTick();
    scrollToBottom();
  }
  
  return [];
};

const messageInputRef = ref(null);

// 增加新的辅助函数，判断消息是否由当前用户发送
const determineIfSent = (message) => {
  // 使用用户名匹配判断消息发送方向
  return message.senderName === authStore.userInfo?.username;
};
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
  -ms-overflow-style: none; /* IE和Edge */
}

:deep(*::-webkit-scrollbar) {
  display: none; /* Chrome, Safari, Edge */
}

/* 主布局样式 */
main {
  display: flex;
  justify-content: center;
  padding-top: 0; /* 移除顶部内边距 */
  height: 100vh !important;
  margin-top: 0; /* 移除顶部外边距 */
  position: relative;
  overflow: hidden !important;
}

.messages-page {
  display: flex;
  justify-content: center;
  width: 100%;
  height: 100vh; /* 使用完整视口高度 */
  margin-top: 0; /* 移除顶部外边距 */
  position: relative;
  overflow: hidden !important;
}

/* 左侧导航块样式，完全参照ContentManagement */
.left-block {
  width: 200px;
  margin-right: 20px;
  position: fixed !important;
  left: calc(50% - 600px);
  top: 85px; /* 保持左侧块距顶部85px */
  background-color: #f7f8f9;
  height: calc(100vh - 115px);
  overflow: hidden !important;
  z-index: 100;
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
  cursor: pointer;
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

/* 内容区域样式，完全参照ContentManagement */
.content-wrapper {
  width: 980px;
  margin-left: 220px;
  position: fixed !important; /* 改为固定定位 */
  top: 85px !important; /* 与左侧块保持一致的顶部距离 */
  height: calc(100vh - 115px); /* 保持与左侧块一致的高度 */
  overflow: hidden !important;
}

.messages-container {
  display: flex;
  height: 100%; /* 使用100%高度填充父容器 */
  background-color: #f0f2f7; /* 调整为更柔和的蓝灰色背景 */
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
  overflow: hidden !important;
  border: 1px solid #e0e3e9; /* 添加微妙的边框 */
}

/* 左侧联系人列表样式 */
.left-sidebar {
  width: 320px;
  border-right: 1px solid #dce0e8; /* 调整边框颜色 */
  display: flex;
  flex-direction: column;
  background-color: #f8fafd; /* 调整为更亮的背景色 */
  overflow: hidden !important;
  height: 100%; /* 使用100%高度填充父容器 */
}

.left-sidebar h2 {
  padding: 20px;
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50; /* 更深的标题颜色 */
  border-bottom: 1px solid #dce0e8;
  background-color: #fff; /* 白色标题背景 */
}

.conversation-tabs {
  display: flex;
  border-bottom: 1px solid #dce0e8;
  margin-bottom: 15px;
}

.conversation-tab {
  flex: 1;
  text-align: center;
  padding: 10px;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 14px;
  color: #606266;
}

.conversation-tab:hover {
  color: #409eff;
}

.conversation-tab.active {
  color: #409eff;
  border-bottom: 2px solid #409eff;
}

.conversation-list {
  flex: 1;
  overflow-y: auto !important;
  padding: 10px;
  scrollbar-width: none; /* Firefox隐藏滚动条 */
  -ms-overflow-style: none; /* IE和Edge隐藏滚动条 */
  height: calc(100% - 61px) !important; /* 61px是标题高度 */
}

.conversation-item {
  position: relative;
  display: flex;
  padding: 15px;
  border-radius: 10px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  background-color: #fff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  justify-content: space-between;
}

.conversation-item:hover {
  background-color: #f0f7ff;
  transform: translateY(-2px);
  box-shadow: 0 3px 8px rgba(64, 158, 255, 0.1);
}

.conversation-item.active {
  background-color: #e6f7ff;
  border-left: 3px solid #409eff;
}

/* 移除悬停检测，直接基于.unread-badge类进行样式应用 */
.conversation-item .unread-badge {
  background-color: #f56c6c;
  color: white;
  border-radius: 50%;
  min-width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
  box-shadow: 0 2px 4px rgba(245, 108, 108, 0.3);
  padding: 0 5px;
}

/* 有未读消息的对话项特殊样式 */
.conversation-item:has(.unread-badge) {
  background-color: #f0f7ff;
  border-left: 3px solid #409eff;
}

.conversation-item:has(.unread-badge) .username {
  font-weight: 600;
  color: #303133;
}

.conversation-item:has(.unread-badge) .last-message {
  font-weight: 500;
  color: #303133;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  margin-right: 15px;
  border: 1px solid #eaeaea;
}

.conversation-info {
  flex: 1;
  min-width: 0;
}

.conversation-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
}

.username {
  font-weight: 500;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}



.last-message {
  font-size: 13px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 聊天区域样式 */
.chat-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #fff; /* 纯白背景 */
  overflow: hidden !important;
  height: 100%; /* 使用100%高度填充父容器 */
  border-radius: 0 12px 12px 0; /* 右侧圆角 */
  position: relative; /* 添加相对定位 */
}

.chat-header {
  padding: 15px 20px;
  border-bottom: 1px solid #dce0e8;
  display: flex;
  align-items: center;
  background-color: #fff;
  position: relative;
  z-index: 10;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05); /* 微妙的阴影 */
}

.chat-with {
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.messages-list {
  flex: 1;
  overflow-y: auto !important;
  padding: 20px;
  background-color: #f5f7fa; /* 更柔和的背景色 */
  scrollbar-width: none; /* Firefox隐藏滚动条 */
  -ms-overflow-style: none; /* IE和Edge隐藏滚动条 */
  height: calc(100% - 130px) !important; /* 稍微调整高度 */
  background-image: linear-gradient(rgba(255, 255, 255, 0.7) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255, 255, 255, 0.7) 1px, transparent 1px);
  background-size: 20px 20px; /* 创建微妙的网格背景 */
  margin-bottom: 70px; /* 为固定定位的输入区域腾出空间 */
  display: flex;
  flex-direction: column;
}

/* 隐藏Chrome、Safari等浏览器的滚动条 */
.messages-list::-webkit-scrollbar {
  display: none;
}

.message-item {
  margin-bottom: 15px;
  max-width: 70%;
  display: flex;
  flex-direction: column;
  width: auto;
  position: relative;
}

.sent {
  align-self: flex-end !important;
  margin-right: 10px !important;
}

.received {
  align-self: flex-start !important;
  margin-left: 10px !important;
}

.system {
  align-self: center !important;
  max-width: 90%;
}

.message-bubble {
  padding: 12px 16px;
  border-radius: 18px;
  word-break: break-word;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.08);
  line-height: 1.4;
  max-width: 100%;
}

.sent .message-bubble {
  background-color: #409eff !important;
  color: white !important;
  border-bottom-right-radius: 4px;
  background-image: linear-gradient(135deg, #409eff 0%, #50b7ff 100%) !important;
}

.received .message-bubble {
  background-color: white !important;
  color: #333 !important;
  border-bottom-left-radius: 4px;
  border: 1px solid #eaedf3 !important;
}

/* 时间样式调整 */
.message-time {
  font-size: 12px;
  color: #94a3b8;
  margin-top: 5px;
}

.sent .message-time {
  text-align: right !important;
}

.received .message-time {
  text-align: left !important;
}

.message-input {
  display: flex;
  padding: 15px 20px;
  border-top: 1px solid #dce0e8;
  background-color: #fff;
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 20;
  height: 70px;
  box-shadow: 0 -4px 10px rgba(0, 0, 0, 0.05);
  border-radius: 0 0 12px 0;
  backdrop-filter: blur(5px);
  transition: all 0.3s ease;
  align-items: center;
  gap: 15px;
}

.message-textarea-container {
  position: relative;
  flex: 1;
}

.message-input textarea {
  width: 95%;
  resize: none;
  border: 1px solid #dce0e8;
  border-radius: 10px;
  padding: 12px 16px;
  height: 44px;
  font-family: inherit;
  font-size: 14px;
  transition: all 0.3s ease;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.05);
  background-color: #f8fafd;
}

.message-input textarea:focus {
  outline: none;
  border-color: #409eff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
  background-color: #fff;
}

.send-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
}

.send-button {
  width: 80px;
  height: 36px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  font-weight: 500;
  box-shadow: 0 2px 5px rgba(64, 158, 255, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
}

.send-button:hover {
  background-color: #3a8ee6;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(64, 158, 255, 0.4);
}

.attachment-buttons {
  display: flex;
  gap: 8px;
}

.attachment-button {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  background-color: #f0f7ff;
  color: #409eff;
  cursor: pointer;
  transition: all 0.2s;
}

.attachment-button:hover {
  background-color: #e0f0ff;
  transform: translateY(-1px);
}

.file-input {
  display: none;
}

/* 附件预览样式 */
.attachment-preview {
  position: absolute;
  bottom: 50px;
  left: 0;
  right: 0;
  background-color: #f0f7ff;
  border: 1px solid #dce0e8;
  border-radius: 10px;
  padding: 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
}

.preview-content {
  display: flex;
  align-items: center;
  max-width: calc(100% - 30px);
}

.image-preview {
  height: 60px;
  border-radius: 6px;
  overflow: hidden;
  margin-right: 10px;
}

.image-preview img {
  height: 100%;
  object-fit: contain;
}

.file-preview {
  display: flex;
  align-items: center;
  color: #409eff;
  font-size: 14px;
}

.file-preview .el-icon {
  margin-right: 8px;
  font-size: 20px;
}

.preview-close {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background-color: rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #666;
  transition: all 0.2s;
}

.preview-close:hover {
  background-color: rgba(0, 0, 0, 0.2);
  color: #333;
}

/* 消息气泡中的附件样式 */
.message-image {
  margin-top: 5px;
  border-radius: 8px;
  overflow: hidden;
}

.message-image img {
  max-width: 200px;
  max-height: 150px;
  border-radius: 8px;
}

.message-file {
  display: flex;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.8);
  padding: 8px 12px;
  border-radius: 8px;
  margin-top: 5px;
  border: 1px solid #dce0e8;
}

.message-file .el-icon {
  margin-right: 8px;
  color: #409eff;
}

.message-file a {
  color: #409eff;
  text-decoration: none;
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 180px;
}

.sent .message-file {
  background-color: rgba(255, 255, 255, 0.9);
}

.empty-state, .empty-chat, .empty-messages {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #94a3b8; /* 更柔和的颜色 */
  font-size: 14px;
  background-color: #f5f7fa; /* 与消息列表背景一致 */
}

.empty-chat-content {
  text-align: center;
  padding: 40px;
  background-color: rgba(255, 255, 255, 0.7); /* 半透明背景 */
  border-radius: 12px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
}

.empty-chat-content i {
  font-size: 48px;
  color: #cbd5e1;
  margin-bottom: 15px;
}

/* 添加平滑滚动效果 */
.conversation-list, .messages-list {
  scroll-behavior: smooth;
}

/* 响应式布局支持 */
@media (max-width: 768px) {
  .left-block {
    display: none;
  }
  
  .content-wrapper {
    width: 100%;
    margin-left: 0;
    padding: 0 10px;
    position: relative !important;
    top: 85px !important;
  }
  
  .messages-container {
    flex-direction: column;
  }
  
  .left-sidebar {
    width: 100%;
    height: 30%;
    border-right: none;
    border-bottom: 1px solid #eaeaea;
  }
  
  .chat-area {
    height: 70%;
  }
  
  .messages-list {
    height: calc(100% - 120px) !important;
  }
}

/* 转发对话框样式 */
.forward-dialog {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 320px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  overflow: hidden;
}

.forward-dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #eaedf3;
  font-weight: bold;
}

.dialog-close {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background-color: #f0f2f7;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.dialog-close:hover {
  background-color: #e6e9f0;
}

.forward-dialog-content {
  max-height: 70vh;
  overflow-y: auto;
}

.forward-tabs {
  display: flex;
  border-bottom: 1px solid #eaedf3;
}

.forward-tab {
  flex: 1;
  text-align: center;
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 14px;
  color: #606266;
}

.forward-tab:hover {
  color: #409eff;
}

.forward-tab.active {
  color: #409eff;
  border-bottom: 2px solid #409eff;
}

.tab-content {
  padding: 15px;
}

.contact-list {
  max-height: 300px;
  overflow-y: auto;
  margin-bottom: 15px;
}

.contact-item {
  display: flex;
  align-items: center;
  padding: 10px;
  border-radius: 8px;
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background-color: #f9fbfe;
}

.contact-item:hover {
  background-color: #edf5ff;
}

.contact-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  margin-right: 10px;
}

.contact-name {
  flex: 1;
  font-size: 14px;
}

.contact-checkbox {
  width: 20px;
  height: 20px;
  border-radius: 4px;
  border: 1px solid #dcdfe6;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.contact-checkbox.selected {
  background-color: #409eff;
  border-color: #409eff;
  color: white;
}

.action-button {
  width: 100%;
  padding: 10px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.action-button:hover {
  background-color: #3a8ee6;
}

.action-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.favorites-list {
  max-height: 300px;
  overflow-y: auto;
  margin-bottom: 15px;
}

.empty-favorites {
  text-align: center;
  color: #909399;
  padding: 20px 0;
}

.favorite-item {
  padding: 12px;
  border-radius: 8px;
  margin-bottom: 10px;
  background-color: #f5f7fa;
  border: 1px solid #eaedf3;
  cursor: pointer;
  transition: all 0.2s;
}

.favorite-item:hover {
  background-color: #f0f7ff;
  transform: translateY(-2px);
  box-shadow: 0 3px 8px rgba(64, 158, 255, 0.1);
}

.favorite-item.selected {
  background-color: #ecf5ff;
  border: 1px solid #409eff;
}

.favorite-title {
  font-weight: 500;
  font-size: 15px;
  margin-bottom: 5px;
  color: #303133;
}

.favorite-summary {
  font-size: 13px;
  color: #606266;
  margin-bottom: 5px;
  line-height: 1.4;
  word-break: break-word;
}

.favorite-date {
  font-size: 12px;
  color: #909399;
  text-align: right;
}

.contact-bio {
  font-style: italic;
  color: #8492a6;
  font-size: 12px;
}

/* 发送失败消息样式 */
.message-item.send-failed .message-bubble {
  position: relative;
  border: 1px solid #f56c6c;
  background-image: none !important;
  background-color: rgba(255, 229, 229, 0.8) !important;
}

.message-item.send-failed .message-bubble::after {
  content: "发送失败";
  position: absolute;
  right: 5px;
  bottom: 5px;
  font-size: 10px;
  color: #f56c6c;
}

.retry-button {
  margin-top: 5px;
  background-color: #f0f2f7;
  color: #f56c6c;
  border: none;
  border-radius: 4px;
  padding: 3px 8px;
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  width: fit-content;
  align-self: flex-end;
}

.retry-button:hover {
  background-color: #fef0f0;
}

/* 添加转发对话框的加载状态 */
.forward-dialog .loading {
  text-align: center;
  padding: 30px 0;
  color: #909399;
}

.forward-dialog .loading i {
  animation: spin 1s linear infinite;
  margin-right: 8px;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.message-bubble.failed {
  background-color: rgba(255, 232, 232, 0.9);
  border: 1px solid #ffb8b8;
}

.retry-button {
  margin-left: 5px;
  font-size: 12px;
  color: #f56c6c;
  background-color: #fff;
  border: 1px solid #f56c6c;
  padding: 2px 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.retry-button:hover {
  background-color: #f56c6c;
  color: white;
}

/* 系统消息样式 */
.system-message {
  background-color: rgba(245, 247, 250, 0.8);
  color: #606266;
  border-radius: 12px;
  padding: 8px 16px;
  font-size: 13px;
  text-align: center;
  margin: 15px auto;
  max-width: 80%;
  border: 1px dashed #dce0e8;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.system-message .message-time {
  align-self: center;
  margin-top: 4px;
  font-size: 11px;
  color: #a0aec0;
}

.message-item.system {
  align-self: center;
  max-width: 90%;
}

.conversation-content {
  display: flex;
  flex: 1;
  min-width: 0;
  align-items: center;
}

.conversation-info {
  flex: 1;
  min-width: 0;
  position: relative; /* 添加相对定位 */
}

.conversation-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px; /* 增加与最后消息的间距 */
}

.username {
  font-weight: 500;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 70%; /* 限制宽度，为时间留出空间 */
}

.time {
  font-size: 12px;
  color: #999;
  white-space: nowrap;
  position: absolute; /* 使用绝对定位 */
  bottom: -10px;
  right: -20px;

}

.last-message {
  font-size: 13px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  padding-right: 60px; /* 为时间预留空间 */
  margin-bottom: 15px; /* 为时间显示预留空间 */
}

.conversation-actions {
  display: flex;
  align-items: center;
  position: relative;
  opacity: 1 !important; /* 强制始终显示 */
}

/* 删除这个规则，它会影响未读徽章的显示 */
/* .conversation-item:hover .conversation-actions {
  opacity: 1;
} */

/* 添加额外的样式确保有未读消息的会话项有明显不同 */
.conversation-item:has(.unread-badge) {
  background-color: #f0f7ff;
  border-left: 3px solid #409eff;
}

.conversation-item:has(.unread-badge) .username {
  font-weight: 600;
  color: #303133;
}

.conversation-item:has(.unread-badge) .last-message {
  font-weight: 500;
  color: #303133;
}

.delete-conversation-btn {
  background: none;
  border: none;
  cursor: pointer;
  color: #909399;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s ease;
}

.delete-conversation-btn:hover {
  background-color: #f56c6c;
  color: white;
}

/* 消息项样式调整 */
.message-item {
  margin-bottom: 15px;
  max-width: 70%;
  display: flex;
  flex-direction: column;
  width: 100%;
  position: relative;
}

.sent {
  margin-left: auto !important; /* 这会使元素靠右对齐 */
  margin-right: 0 !important;
}

.received {
  margin-right: auto !important; /* 这会使元素靠左对齐 */
  margin-left: 0 !important;
}

/* 消息气泡样式调整 */
.message-bubble {
  padding: 12px 16px;
  border-radius: 18px;
  word-break: break-word;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.08);
  line-height: 1.4;
  max-width: 100%;
}

.sent .message-bubble {
  background-color: #409eff !important;
  color: white !important;
  border-bottom-right-radius: 4px;
  background-image: linear-gradient(135deg, #409eff 0%, #50b7ff 100%) !important;
  float: right !important; /* 确保内容靠右 */
}

.received .message-bubble {
  background-color: white !important;
  color: #333 !important;
  border-bottom-left-radius: 4px;
  border: 1px solid #eaedf3 !important;
  float: left !important; /* 确保内容靠左 */
}

/* 时间样式调整，确保正确跟随气泡位置 */
.sent .message-time {
  text-align: right !important;
  padding-right: 8px;
  clear: both;
}

.received .message-time {
  text-align: left !important;
  padding-left: 8px;
  clear: both;
}

/* 未读消息红点样式 */
.unread-badge {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  right: 32px; /* 调整右侧位置 */
  background-color: #f56c6c;
  color: white;
  border-radius: 10px;
  min-width: 20px;
  height: 20px;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 6px;
  box-shadow: 0 2px 4px rgba(245, 108, 108, 0.3);
  z-index: 5;
  opacity: 1 !important; /* 强制始终显示 */
}

.conversation-actions {
  display: flex;
  align-items: center;
  opacity: 1 !important; /* 强制始终显示 */
}

/* 只让删除按钮在悬停时显示 */
.delete-conversation-btn {
  opacity: 0;
  transition: opacity 0.2s ease;
}

.conversation-item:hover .delete-conversation-btn {
  opacity: 1;
}
</style> 