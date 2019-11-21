require 'rails_helper'

describe TaxonDetermination, type: :model do

  let(:taxon_determination) {TaxonDetermination.new}
  let(:otu) { Otu.create!(name: 'Foo')  }
  let(:specimen) { Specimen.create! }

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(taxon_determination).to respond_to(:otu)
      end

      specify 'biological_collection_object' do
        expect(taxon_determination).to respond_to(:biological_collection_object)
      end
    end

    context 'has_many' do
      specify 'determiners' do
        expect(taxon_determination).to respond_to(:determiners)
      end
    end
  end

  specify 'first determination has position "1"' do
    expect(FactoryBot.create(:valid_taxon_determination).position).to eq(1)
  end

  context 'multiple determinations' do
    let!(:a) {TaxonDetermination.create!(biological_collection_object: specimen, otu: otu) }
    let!(:b) {TaxonDetermination.create!(biological_collection_object: specimen, otu: otu) }

    specify 'two determinations, one deleted other has position "1"' do
      a.destroy!
      expect(b.reload.position).to eq(1)
    end

    specify 'two determinations, one deleted other has position "1", opposite' do
      b.destroy!
      expect(a.reload.position).to eq(1)
    end

    specify '#move_to_top is position 1' do
      expect(b.reload.position).to eq(1)
      a.move_to_top 
      expect(a.reload.position).to eq(1)
    end

    specify 'last created is position 1' do
      expect(b.reload.position).to eq(1)
      expect(a.reload.position).to eq(2)
    end

    specify '.historical' do
      expect(TaxonDetermination.historical.map(&:id)).to contain_exactly(a.id)
    end

    specify '.current' do
      expect(TaxonDetermination.current.map(&:id)).to contain_exactly(b.id)
    end
  end

  context 'acts_as_list ordering of determinations' do
    let(:otu1) { FactoryBot.create(:valid_otu) }
    let(:otu2) { FactoryBot.create(:valid_otu) }

    before do 
      specimen.taxon_determinations << TaxonDetermination.new(otu: otu)
    end 

    specify 'determinations are added to the bottom of the stack with <<' do
      t = TaxonDetermination.new(otu: otu1)
      specimen.taxon_determinations << t
      expect(specimen.taxon_determinations.last.otu).to eq(otu1)
    end

    specify 'move a determination to the "current" position with #move_to_top' do
      t = TaxonDetermination.new(otu: otu1)
      specimen.taxon_determinations << t
      specimen.taxon_determinations.last.move_to_top
      expect(specimen.current_taxon_determination.otu).to eq(otu1)
    end
  end

  context 'nested taxon determinations' do
    context 'combination of nested attributes and otu_id passes' do

      let(:nested_attributes) {
        {'taxon_determinations_attributes' => [
          {
            otu_id: otu.to_param,
            otu_attributes: {
              name: '',
              taxon_name_id: ''
            }}]}
      }

      let(:s) { Specimen.create(nested_attributes) }

      specify 'both otu_id and empty_otu_attributes works' do
        expect(s.taxon_determinations.reload.count).to eq(1)
        expect(s.otus.to_a).to contain_exactly(otu)
      end
    end

    specify 'with an empty otu_id does not raise or create' do
      expect(Specimen.create(taxon_determinations_attributes: [{otu_id: ''}])).to be_truthy
    end
  end

  specify '#print_label is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n" 
    taxon_determination.print_label = s
    taxon_determination.valid?
    expect(taxon_determination.print_label).to eq(s)
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'has_roles'
    it_behaves_like 'is_data'
  end

end
