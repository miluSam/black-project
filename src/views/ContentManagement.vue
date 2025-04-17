<template>
  <div>
    
  </div>
</template>

<script>
import { defineComponent, ref } from 'vue';

export default defineComponent({
  name: 'ContentManagement',
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

</style>