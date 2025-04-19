<router-link to="/messages" class="nav-item" title="私信">
  <i class="el-icon-message"></i>
  <UnreadMessageBadge />
</router-link>

<script setup>
import UnreadMessageBadge from './UnreadMessageBadge.vue';
</script>

<style scoped>
.nav-item {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  transition: background-color 0.3s;
}

.nav-item:hover {
  background-color: rgba(255, 255, 255, 0.1);
}
</style> 