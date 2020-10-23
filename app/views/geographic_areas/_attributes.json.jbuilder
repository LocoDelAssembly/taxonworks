json.extract! geographic_area, :id, :name, :level0_id, :level1_id, :level2_id,
  :parent_id, :geographic_area_type_id,
  :iso_3166_a2, :iso_3166_a3,
  :tdwgID, :data_origin,
  :created_by_id, :updated_by_id, :created_at, :updated_at

if params[:geo_json] 
  json.shape geographic_area.to_geo_json_feature
end

json.level0_name geographic_area.level0&.name
json.level1_name geographic_area.level1&.name
json.level2_name geographic_area.level2&.name

json.geographic_area_type do
  json.extract! geographic_area.geographic_area_type, :id, :name
end

json.parent do
  json.extract! geographic_area.parent, :name
end
