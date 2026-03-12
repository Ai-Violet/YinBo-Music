import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import App from './App.vue'
import router from './router'
import './style.css'
import { useUserStore } from './stores/user'
import { useTheme } from './composables/useTheme'

const app = createApp(App)

// 初始化主题
useTheme()
const pinia = createPinia()

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(pinia)
app.use(router)
app.use(ElementPlus)

const userStore = useUserStore()
userStore.initAdminState().then(() => {
  app.mount('#app')
})
