<template>
  <AppLayout />
</template>

<script setup lang="ts">
import { defineAsyncComponent } from 'vue'

const AppLayout = defineAsyncComponent(() => import('./layouts/AppLayout.vue'))
</script>
