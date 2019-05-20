class TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate < TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000086'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.gbif_status
    'legitimate'
  end

  def self.sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Legitimate')
  end
end
