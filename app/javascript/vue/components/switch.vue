<template>
  <div class="switch-radio">
    <template
      v-for="(item, index) in options.concat(addOption)">
      <template v-if="filter(item)">
        <input
          @click="$emit('input', item)"
          :value="item"
          :id="`switch-${name}-${index}`"
          :name="`switch-${name}-options`"
          type="radio"
          :checked="item === value"
          class="normal-input button-active"
        >
        <label
          :for="`switch-${name}-${index}`">{{ item }}
        </label>
      </template>
    </template>
  </div>
</template>
<script>
  export default {
    props: {
      options: {
        type: Array,
        required: true
      },
      value: {
        required: true
      },
      addOption: {
        type: Array,
        required: false,
        default: () => {
          return []
        }
      },
      name: {
        type: String,
        required: false,
        default: () => { return Math.random().toString(36).substr(2, 5) }
      },
      filter: {
        type: Function,
        default: () => {
          return true
        }
      }
    }
  }

</script>
<style scoped>
  label::first-letter {
    text-transform: capitalize;
  }
</style>
