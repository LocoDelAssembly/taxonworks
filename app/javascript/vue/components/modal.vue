<template>
  <transition name="modal">
    <div
      class="modal-mask"
      @click="$emit('close')"
      @key.esc="$emit('close')">
      <div class="modal-wrapper">
        <div
          class="modal-container"
          :class="containerClass"
          :style="containerStyle"
          @click.stop>
          <div class="modal-header">
            <div
              class="modal-close"
              @click="$emit('close')"/>
            <slot name="header">
              default header
            </slot>
          </div>
          <div class="modal-body">
            <slot name="body">
              default body
            </slot>
          </div>
          <div class="modal-footer">
            <slot name="footer"/>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
  export default {
    props: {
      containerClass: {
        type: Object,
        default: () => {
          return {}
        }
      },
      containerStyle: {
        type: Object,
        default: () => {
          return {}
        }
      }
    },
    mounted: function () {
      document.addEventListener('keydown', (e) => {
        if (e.keyCode === 27) {
          this.$emit('close')
        }
      })
    }
  }
</script>
