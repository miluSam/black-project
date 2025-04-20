<template>
  <div class="unread-message-badge" v-if="totalUnread > 0">
    {{ totalUnread > 99 ? '99+' : totalUnread }}
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import axios from 'axios';
import { eventBus } from '@/plugins/eventBus';

const totalUnread = ref(0);
let intervalId = null;

const fetchUnreadCount = async () => {
  try {
    const jwtToken = localStorage.getItem('jwtToken') || sessionStorage.getItem('jwtToken');
    const response = await axios.get('http://localhost:7070/api/messages/conversations', {
      headers: {
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    
    if (response.status === 200) {
      const conversations = response.data.data || [];
      totalUnread.value = conversations.reduce((sum, conv) => sum + (conv.unreadCount || 0), 0);
    }
  } catch (error) {
    console.error('获取未读消息数失败:', error);
  }
};

// 消息已读事件处理函数
const handleMessageRead = () => {
  console.log('收到消息已读事件，立即更新未读消息数');
  fetchUnreadCount();
};

onMounted(() => {
  fetchUnreadCount();
  // 每30秒更新一次未读消息数
  intervalId = setInterval(fetchUnreadCount, 30000);
  
  // 监听消息已读事件
  eventBus.on('message:read', handleMessageRead);
});

onBeforeUnmount(() => {
  if (intervalId) {
    clearInterval(intervalId);
  }
  
  // 移除事件监听
  eventBus.off('message:read', handleMessageRead);
});
</script>

<style scoped>
.unread-message-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background-color: #f56c6c;
  color: white;
  border-radius: 10px;
  /* min-width: 20px;
  height: 20px; */
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 6px;
  box-shadow: 0 2px 4px rgba(245, 108, 108, 0.3);
  z-index: 1;
}
</style> 