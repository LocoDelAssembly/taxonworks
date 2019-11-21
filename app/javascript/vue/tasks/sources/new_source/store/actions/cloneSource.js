import { CloneSource, LoadSoftValidation } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  CloneSource(state.source.id).then(response => {
    commit(MutationNames.SetSource, response.body)

    let authors = state.source.author_roles
    let editors = state.source.editor_roles
    let people = authors.concat(editors)

    commit(MutationNames.SetRoles, people)

    LoadSoftValidation(response.body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body.validations.soft_validations)
    })
    
    setParam('/tasks/sources/new_source', 'source_id', response.body.id)
    TW.workbench.alert.create('Source was successfully cloned.', 'notice')
  })
}