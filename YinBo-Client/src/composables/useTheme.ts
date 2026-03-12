import { ref, watchEffect } from 'vue'

const STORAGE_KEY = 'yinbo_theme'

type Theme = 'dark' | 'light'

const theme = ref<Theme>((localStorage.getItem(STORAGE_KEY) as Theme) || 'light')

watchEffect(() => {
  document.documentElement.setAttribute('data-theme', theme.value)
  localStorage.setItem(STORAGE_KEY, theme.value)
})

export function useTheme() {
  const toggle = () => {
    theme.value = theme.value === 'dark' ? 'light' : 'dark'
  }

  const isDark = () => theme.value === 'dark'

  return { theme, toggle, isDark }
}
