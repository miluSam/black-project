module.exports = {
  env: {
      browser: true
  },
  extends: [
      'eslint:recommended',
      'plugin:vue/essential'
  ],
  parserOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module'
  },
  plugins: [
      'vue'
  ]
};