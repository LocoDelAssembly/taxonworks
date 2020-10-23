import { createTaxonStatus } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ dispatch, commit, state }, status) {
  var position = state.taxonStatusList.findIndex(item => {
    if (item.type === status.type) {
      return true
    }
  })
  if (position < 0) {
    const newClassification = {
      taxon_name_classification: {
        taxon_name_id: state.taxon_name.id,
        type: status.type
      }
    }
    return new Promise(function (resolve, reject) {
      createTaxonStatus(newClassification).then(response => {
        Object.defineProperty(response.body, 'type', { value: status.type })
        Object.defineProperty(response.body, 'object_tag', { value: status.name })
        commit(MutationNames.AddTaxonStatus, response.body)
        dispatch('loadSoftValidation', 'taxon_name')
        dispatch('loadSoftValidation', 'taxonStatusList')
        dispatch('loadSoftValidation', 'taxonRelationshipList')
        dispatch('loadSoftValidation', 'original_combination')
        return resolve(response.body)
      }, response => {
        return reject(response.body)
      })
    })
  }
}
