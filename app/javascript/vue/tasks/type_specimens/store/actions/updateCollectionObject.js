import { MutationNames } from '../mutations/mutations'
import { UpdateTypeMaterial, UpdateCollectionObject } from '../../request/resources'

export default function ({ commit, state }, data) {
  commit(MutationNames.SetSaving, true)
  delete data.type_material.material_attributes
  UpdateTypeMaterial(data.type_material.id, data).then(response => {
    commit(MutationNames.AddTypeMaterial, response)
    commit(MutationNames.SetTypeMaterial, response)

    UpdateCollectionObject(state.type_material.collection_object.id, data.type_material.collection_object).then(response => {
      commit(MutationNames.SetCollectionObject, response)
      LoadSoftvalidation(state.type_material.global_id).then(response => {
        let validation = response.validations.soft_validations
        LoadSoftvalidation(state.type_material.collection_object.global_id).then(response => {
          commit(MutationNames.SetSoftValidation, validation.concat(response.validations.soft_validations))
        })
      })
      TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
      commit(MutationNames.SetSaving, false)
    })
  })
};
