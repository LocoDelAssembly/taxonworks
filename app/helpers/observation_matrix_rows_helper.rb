module ObservationMatrixRowsHelper

  # Display in app
  def observation_matrix_row_tag(observation_matrix_row)
    return nil if observation_matrix_row.nil?
    object_tag(observation_matrix_row.row_object)
  end

  def observation_matrix_row_link(observation_matrix_row)
    return nil if observation_matrix_row.nil?
    link_to(observation_matrix_row_tag(observation_matrix_row).html_safe, observation_matrix_row)
  end

  # @return [String]
  #  !! No HTML !!
  #    The label used in exports
  def observation_matrix_row_label(observation_matrix_row)
    return observation_matrix_row.name unless observation_matrix_row.name.blank?
    o = observation_matrix_row.row_object
    s = label_for(o) 
    s.gsub!(/[^\w]/, '_')
    s[0..11] + "_#{o.id}"
  end

  # ONLY CACHE IF count == 1 ?!
  # @return [ObservationMatrixRow#id, nil]
  #   if destroyable (represented by only a single OMRI of type Single) then return the ID
  def observation_matrix_row_destroyable?(observation_matrix_row)
    if !observation_matrix_row.cached_observation_matrix_row_item_id.blank? && observation_matrix_row.reference_count == 1
      return observation_matrix_row.cached_observation_matrix_row_item_id
    end
  end

end
