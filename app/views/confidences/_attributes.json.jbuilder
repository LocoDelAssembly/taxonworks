json.extract! confidence, :id, :confidence_object_id, :confidence_object_type, :confidence_level_id, :position, :created_by_id, :updated_by_id, :project_id

json.partial! '/shared/data/all/metadata', object: confidence
json.annotated_object_global_id confidence.confidence_object.to_global_id.to_s

json.confidence_level do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: confidence.confidence_level
end
