class TaxonNameRelationship::Typification::Genus::Subsequent < TaxonNameRelationship::Typification::Genus

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Typification::Genus::Original,
                                                 TaxonNameRelationship::Typification::Genus::Tautonomy,) +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus)
  end

  def object_status
    'type of genus by subsequent designation or monotypy'
  end

  def subject_status
    'type species by subsequent designation or monotypy'
  end

  def self.assignment_method
    :type_of_genus_by_subsequent_designation_or_monotypy
  end

  def self.inverse_assignment_method
    :type_species_by_subsequent_designation_or_monotypy
  end

end