<template>
  <RouterLink
    v-if="artistId"
    :to="'/singer/' + artistId"
    class="artist-link"
    @click.stop
  >{{ artistName }}</RouterLink>
  <RouterLink
    v-else-if="artistName"
    :to="'/artist?name=' + encodeURIComponent(artistName)"
    class="artist-link"
    @click.stop
  >{{ artistName }}</RouterLink>
  <span v-else class="artist-placeholder">未知歌手</span>
</template>

<script setup lang="ts">
defineProps<{
  artistId?: number
  artistName?: string
}>()
</script>

<style scoped>
.artist-link {
  color: var(--text-secondary);
  text-decoration: none;
  transition: color 0.2s;
}
.artist-link:hover {
  color: var(--accent, #7c3aed);
  text-decoration: underline;
}
.artist-placeholder {
  color: var(--text-muted);
}
</style>
