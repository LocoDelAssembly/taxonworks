require 'rails_helper'

describe Tasks::AssertedDistributions::NewFromMapController, type: :controller do
  before(:each) {
    sign_in
  }

  let(:valid_otu) { FactoryBot.create(:valid_otu) }
  let(:valid_source) { FactoryBot.create(:valid_source) }

  describe 'GET new' do
    it 'returns http success' do
      get :new, params: {asserted_distribution: {otu_id: valid_otu.id, source_id: valid_source.id}}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET create' do
    it 'returns http success' do
      get :create, params: {}
      expect(response).to have_http_status(:success)
    end
  end

end
