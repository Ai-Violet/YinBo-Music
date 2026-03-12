import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  esbuild: {
    charset: 'utf8' // 确保中文等非 ASCII 字符正确编译，避免乱码
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 8081,
    host: '0.0.0.0',
    strictPort: false,
    open: 'http://localhost:8081'
  }
})
