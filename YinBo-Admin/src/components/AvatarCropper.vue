<template>
  <el-dialog
    v-model="dialogVisible"
    title="编辑头像"
    :width="500"
    :close-on-click-modal="false"
    @close="handleClose"
    class="dark-dialog"
    modal-class="dark-modal"
  >
    <div class="cropper-container">
      <div class="cropper-wrapper">
        <img ref="imageRef" :src="imageUrl" alt="crop image" />
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <div class="cropper-controls">
          <el-button-group>
            <el-button @click="zoomIn" title="放大">
              <el-icon><ZoomIn /></el-icon>
            </el-button>
            <el-button @click="zoomOut" title="缩小">
              <el-icon><ZoomOut /></el-icon>
            </el-button>
            <el-button @click="rotateLeft" title="左旋转">
              <el-icon><RefreshLeft /></el-icon>
            </el-button>
            <el-button @click="rotateRight" title="右旋转">
              <el-icon><RefreshRight /></el-icon>
            </el-button>
            <el-button @click="flipHorizontal" title="水平翻转">
              <el-icon><Sort /></el-icon>
            </el-button>
            <el-button @click="flipVertical" title="垂直翻转">
              <el-icon><ArrowUp /></el-icon>
            </el-button>
            <el-button @click="reset" title="重置">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </el-button-group>
        </div>
        <div class="cropper-tips">
          <span>拖动调整位置，滚轮缩放</span>
        </div>
        <div class="dialog-buttons">
          <button class="btn-cancel" @click="handleClose">取消</button>
          <button class="btn-confirm" @click="handleConfirm">确认</button>
        </div>
      </div>
    </template>
  </el-dialog>
</template>

<script lang="ts">
export default {
  name: 'AvatarCropper'
}
</script>

<script setup lang="ts">
import { ref, watch, nextTick, onBeforeUnmount } from 'vue'
import Cropper from 'cropperjs'
import 'cropperjs/dist/cropper.css'
import {
  ZoomIn,
  ZoomOut,
  RefreshLeft,
  RefreshRight,
  Sort,
  ArrowUp,
  Refresh
} from '@element-plus/icons-vue'

interface Props {
  modelValue: boolean
  imageUrl: string
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void
  (e: 'confirm', blob: Blob): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const dialogVisible = ref(false)
const imageRef = ref<HTMLImageElement>()
let cropper: Cropper | null = null

watch(
  () => props.modelValue,
  (val) => {
    dialogVisible.value = val
    if (val) {
      nextTick(() => {
        initCropper()
      })
    }
  }
)

watch(dialogVisible, (val) => {
  emit('update:modelValue', val)
})

const initCropper = () => {
  if (!imageRef.value) return

  if (cropper) {
    cropper.destroy()
  }

  cropper = new Cropper(imageRef.value, {
    aspectRatio: 1,
    viewMode: 1,
    dragMode: 'move',
    autoCropArea: 1,
    restore: false,
    guides: true,
    center: true,
    highlight: false,
    cropBoxMovable: true,
    cropBoxResizable: true,
    toggleDragModeOnDblclick: true,
    minCanvasWidth: 100,
    minCanvasHeight: 100,
    minCropBoxWidth: 50,
    minCropBoxHeight: 50,
    background: false,
    zoom: (e) => {
      if (e.detail.ratio > 5) {
        e.preventDefault()
        cropper?.zoomTo(5)
      }
      if (e.detail.ratio < 0.1) {
        e.preventDefault()
        cropper?.zoomTo(0.1)
      }
    }
  })
}

const zoomIn = () => {
  cropper?.zoom(0.1)
}

const zoomOut = () => {
  cropper?.zoom(-0.1)
}

const rotateLeft = () => {
  cropper?.rotate(-90)
}

const rotateRight = () => {
  cropper?.rotate(90)
}

const flipHorizontal = () => {
  const data = cropper?.getData()
  if (data) {
    cropper?.scaleX(data.scaleX === 1 ? -1 : 1)
  }
}

const flipVertical = () => {
  const data = cropper?.getData()
  if (data) {
    cropper?.scaleY(data.scaleY === 1 ? -1 : 1)
  }
}

const reset = () => {
  cropper?.reset()
}

const handleConfirm = () => {
  if (!cropper) return

  const canvas = cropper.getCroppedCanvas({
    width: 300,
    height: 300,
    imageSmoothingQuality: 'high'
  })

  canvas.toBlob(
    (blob) => {
      if (blob) {
        emit('confirm', blob)
        handleClose()
      }
    },
    'image/jpeg',
    0.9
  )
}

const handleClose = () => {
  if (cropper) {
    cropper.destroy()
    cropper = null
  }
  dialogVisible.value = false
}

onBeforeUnmount(() => {
  if (cropper) {
    cropper.destroy()
  }
})
</script>

<style scoped>
.cropper-container {
  width: 100%;
  height: 350px;
  background: #1a1a2e;
  border-radius: 8px;
  overflow: hidden;
}

.cropper-wrapper {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cropper-wrapper img {
  max-width: 100%;
  max-height: 100%;
  display: block;
}

:deep(.cropper-container) {
  max-height: 350px;
}

:deep(.cropper-modal) {
  background-color: rgba(0, 0, 0, 0.6);
}

:deep(.cropper-view-box) {
  outline: 2px solid #667eea;
  outline-offset: -2px;
  border-radius: 50%;
}

:deep(.cropper-face) {
  background-color: transparent;
}

:deep(.cropper-line) {
  background-color: #667eea;
}

:deep(.cropper-point) {
  background-color: #667eea;
  width: 8px;
  height: 8px;
}

.dialog-footer {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cropper-controls {
  display: flex;
  justify-content: center;
}

.cropper-controls :deep(.el-button-group) {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.cropper-controls :deep(.el-button) {
  padding: 8px 12px;
}

.cropper-tips {
  text-align: center;
  font-size: 12px;
  color: #999;
}

.dialog-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.btn-cancel {
  padding: 10px 24px;
  background: rgba(255, 255, 255, 0.1);
  border: none;
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: rgba(255, 255, 255, 0.15);
}

.btn-confirm {
  padding: 10px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  color: #ffffff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-confirm:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}
</style>

<style>
.dark-modal .el-dialog {
  background: #1a1c2e !important;
  border-radius: 12px !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
}

.dark-modal .el-dialog__header {
  padding: 16px 20px !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
}

.dark-modal .el-dialog__title {
  color: #ffffff !important;
  font-size: 16px !important;
  font-weight: 500 !important;
}

.dark-modal .el-dialog__headerbtn .el-dialog__close {
  color: rgba(255, 255, 255, 0.6) !important;
}

.dark-modal .el-dialog__headerbtn:hover .el-dialog__close {
  color: #ffffff !important;
}

.dark-modal .el-dialog__body {
  padding: 20px !important;
  color: #ffffff !important;
}

.dark-modal .el-dialog__footer {
  padding: 16px 20px !important;
  border-top: 1px solid rgba(255, 255, 255, 0.08) !important;
}

.dark-modal .el-button {
  background: rgba(255, 255, 255, 0.1) !important;
  border-color: rgba(255, 255, 255, 0.15) !important;
  color: rgba(255, 255, 255, 0.8) !important;
}

.dark-modal .el-button:hover {
  background: rgba(255, 255, 255, 0.15) !important;
  border-color: rgba(255, 255, 255, 0.2) !important;
}
</style>
