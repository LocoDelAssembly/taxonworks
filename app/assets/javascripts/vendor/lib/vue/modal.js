Vue.component('modal', {
  template: '<transition name="modal"> \
              <div class="modal-mask"> \
                <div class="modal-wrapper"> \
                  <div class="modal-container"> \
                    <div class="modal-header"> \
                    <div class="modal-close" @click="$emit(\'close\')"></div> \
                      <slot name="header"> \
                        default header \
                      </slot> \
                    </div> \
                    <div class="modal-body"> \
                      <slot name="body"> \
                        default body \
                      </slot> \
                    </div> \
                    <div class="modal-footer"> \
                      <slot name="footer"> \
                      </slot> \
                    </div> \
                  </div> \
                </div> \
              </div> \
            </transition>'
});