import Vue from 'vue'
import App from './app.vue'

function init (){
  new Vue({
    el: '#vue-task-manage-controlled-vocabulary',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-manage-controlled-vocabulary')) {
    init()
  }
})