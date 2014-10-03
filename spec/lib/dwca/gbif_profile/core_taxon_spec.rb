require 'rails_helper'

 # Some co

describe 'TaxonWorks to DwC-A core mapping' do
  let (:citation) { 'Defaut (2006) Révision préliminaire des Oedipoda ouest-paléarctiques (Caelifera, Acrididae, Oedipodinae). Matériaux Orthoptériques et Entomocénotiques 11, 23–48.' }

  let(:core) {
    
    #source = nil
    #VCR.use_cassette('example dwc source') do
    # Doesn't resolve and returns non-bibtex, which doesn't work, but you see the coolness potential 
    #  source = Source.new_from_citation(citation: citation )
    #end

    source = Source::Bibtex.new(
      bibtex_type: 'article',
      year: '2006',
      author: 'Defaut',
      title: 'Révision préliminaire des Oedipoda ouest-paléarctiques (Caelifera, Acrididae, Oedipodinae)',
      volume: '11',
      pages: '23-48',
      journal: 'Matériaux Orthoptériques et Entomocénotiques'
    )

    source.save!

    r = FactoryGirl.create(:root_taxon_name)
    g = TaxonName.create(name: 'Oedipoda', rank_class: Ranks.lookup(:iczn, 'genus'), parent: r)
    s = TaxonName.create(name: 'caerulescens', rank_class: Ranks.lookup(:iczn, 'species'), parent: g)
    ss = TaxonName.create(name: 'sardeti', rank_class: Ranks.lookup(:iczn, 'subspecies'), parent: s, source: source)
  
    ss.identifiers << Identifier::Global::Lsid.create(identifier: 'urn:lsid:Orthoptera.speciesfile.org:TaxonName:67404')

    otu = Otu.create(taxon_name: ss)
  
    # I went ahead and created a "method"
    otu.dwca_core 
  }
  
  context 'When name is governed by ICZN' do
        
    context 'When taxon is validly published' do
      # Build example models here and populate the hash. Please when doing so, also
      # show how would you retrieve the required model instances from the DB instead 
      # of just fulfilling the hash with the source models in isolation (e.g. building 
      # a citation and then just assigning its text representation to namePublishedIn
      # without showing how the name relates to the model is an incorrect example)
   
      specify 'taxonomicStatus' do
        # NOTE: Although SFS currently uses 'accepted' as is the preferred term in 
        # http://rs.gbif.org/vocabulary/gbif/taxonomic_status.xml, 'valid' could be used as well.
        # Decide which is best.
        expect(core[:taxonomicStatus]).to eq('accepted')
      end
      
      # http://rs.gbif.org/vocabulary/gbif/nomenclatural_status.xml  
      # We need to map Nomen to this, task for @proceps
      specify 'nomenclaturalStatus' do
        expect(core[:nomenclaturalStatus]).to eq('available')
      end
      
      specify 'scientificName' do
        expect(core[:scientificName]).to eq('Oedipoda caerulescens sardeti')
      end
      
      specify 'scientificNameAuthorship' do
        expect(core[:scientificNameAuthorship]).to eq('Defaut, 2006')
      end
      
      specify 'scientificNameID' do
        # NOTE: LSID must be supported, but not necessarily should be a requirement for all projects where this term
        # could be either be built from something else or not be used at all.
        expect(core[:scientificNameID]).to eq('urn:lsid:Orthoptera.speciesfile.org:TaxonName:67404')
      end
      
      specify 'taxonRank' do
        expect(core[:taxonRank]).to eq('subspecies')
      end
      
      specify 'namePublishedIn' do
        expect(core[:namePublishedIn]).to eq(citation)
      end
    end
  end

end
