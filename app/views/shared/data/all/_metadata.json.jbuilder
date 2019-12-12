json.object_tag object_tag(object)
json.object_label label_for(object)
json.global_id object.persisted? ? object.to_global_id.to_s : nil
json.base_class object.class.base_class.name
json.url_for url_for(only_path: false, format: :json)
json.object_url url_for(metamorphosize_if(object))

# TODO - this block has to go, and be loaded with the base of the object if needed, not with metadata, particularly
# bad with citations
if object.respond_to?(:origin_citation) && object.origin_citation
  json.origin_citation do
    json.id object.origin_citation.id
    json.pages object.origin_citation.pages

    json.partial! '/shared/data/all/metadata', object: object.origin_citation

    json.source do 
      json.partial! '/sources/attributes', source: object.origin_citation.source
    end
  end
end

json.partial! '/pinboard_items/pinned', object: object

