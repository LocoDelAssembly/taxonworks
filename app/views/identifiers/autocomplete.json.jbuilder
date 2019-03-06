json.array! @identifiers do |i|
  v = identifier_autocomplete_tag(i)
  json.id i.id
  json.label i.cached
  json.label_html v
  json.identifier_object_global_id i.identifier_object.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], i.id
    end
  end 
end
