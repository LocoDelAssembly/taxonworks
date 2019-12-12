module TaxonDeterminationsHelper

  # @return [String, nil]
  #    a descriptor, contains name only (if you want to include the identifier use collection_object_tag) 
  def taxon_determination_tag(taxon_determination) 
    return nil if taxon_determination.nil?
    ['determined as', determination_tag(taxon_determination) ].join(' ').html_safe
  end

  # @return [String]
  #   as for taxon_determination_tag but does not reference collection object
  def determination_tag(taxon_determination)
    return nil if taxon_determination.nil?
    [ otu_tag(taxon_determination.otu),
      taxon_determination_by(taxon_determination),
      taxon_determination_on(taxon_determination)
    ].join(' ').html_safe
  end
  # 
  # @return [String]
  #   as for taxon_determination_tag but does not reference collection object, links to OTU
  def taxon_determination_link(taxon_determination)
    [ link_to(determination_tag(taxon_determination), taxon_determination.otu),
      taxon_determination_by(taxon_determination),
      taxon_determination_on(taxon_determination)
    ].join(' ').html_safe
  end

  # @return [String]
  #   the "by" clause of the determination
  def taxon_determination_by(taxon_determination)
    names = taxon_determination.determiners.collect{|d| d.last_name }.to_sentence
    names.blank? ? nil : "by #{names}"
  end

  # @return [String]
  #   the date clause of the determination
  def taxon_determination_on(taxon_determination)
    !taxon_determination.date.blank? ? "on #{taxon_determination.date}" : nil
  end

end
