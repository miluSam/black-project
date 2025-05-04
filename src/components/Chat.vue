<template>
  <div class="chat-window">
    <div class="messages">
      <div v-for="m in messages" :key="m.id" class="message">
        <strong>{{ m.senderName }}:</strong> {{ m.content }}
      </div>
    </div>
    <div class="input-area">
      <input
        v-model="input"
        placeholder="输入消息…"
        @keyup.enter="sendChat(targetUserId)"
      />
      <button @click="sendChat(targetUserId)">发送</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import SockJS from 'sockjs-client'
import Stomp from 'stompjs'

// 接收要聊天的用户 ID
const { targetUserId } = defineProps({
  targetUserId: {
    type: [String, Number],
    required: true
  }
})

const token = localStorage.getItem('jwt')
let stompClient = null

const messages = ref([])
const input = ref('')

onMounted(() => {
  // 建立 SockJS 连接并通过 STOMP 使用 JWT 验证
  const socket = new SockJS('/ws')
  stompClient = Stomp.over(socket)

  stompClient.connect(
    { Authorization: 'Bearer ' + token },
    (frame) => {
      // 订阅点对点消息
      stompClient.subscribe('/user/queue/messages', (msg) => {
        const body = JSON.parse(msg.body)
        messages.value.push(body)
      })
    },
    (err) => {
      console.error('STOMP 连接失败', err)
    }
  )
})

onBeforeUnmount(() => {
  stompClient && stompClient.disconnect()
})

function sendChat(receiverId) {
  if (!stompClient) return
  stompClient.send(
    '/app/chat.send',
    {},
    JSON.stringify({ receiverId, content: input.value })
  )
  input.value = ''
}
</script>

<style scoped>
.chat-window {
  border: 1px solid #ccc;
  padding: 10px;
  width: 300px;
}
.messages {
  max-height: 200px;
  overflow-y: auto;
  margin-bottom: 10px;
}
.input-area {
  display: flex;
  gap: 5px;
}
input {
  flex: 1;
  padding: 5px;
}
button {
  padding: 5px 10px;
}
</style> 