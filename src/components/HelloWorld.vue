<template>
  <div class="hello">
   
    <input type="button" value="登录" @click="handlePOST"/>
    <input type="button" value="注册" @click="handleGET"/>
    
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'HelloWorld',
  data() {
    return {
      username: '',
      password: '',
      token: ''
    };
  },
  methods: {
    handlePOST() {
      // axios 发送 post 请求
      axios.post('/api/admin/employee/login', {
        username: this.username,
        password: this.password
      })
      .then(res => {
        console.log(res.data);
      })
      .catch(error => {
        console.log(error.response);
      });
    },
    handleGET() {
      // 发送 get 请求
      axios.get('/api/', {
        headers: {
          token: this.token
        }
      })
      .then(res => {
        console.log(res.data);
      })
      .catch(error => {
        console.log(error.response);
      });
    }
  },
  props: {
    msg: String
  }
};
</script>

<style scoped>
/* 包裹样式规则 */


</style>    