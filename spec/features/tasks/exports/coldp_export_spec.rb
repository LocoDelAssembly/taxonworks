require 'rails_helper'

describe 'tasks/exports/coldp', type: :feature, group: [:collection_objects] do
  include ActiveJob::TestHelper

  context 'with test file' do
    let(:page_title) {'CoLDP exports'}
    let(:index_path) {export_coldp_task_path}

    it_behaves_like 'a_login_required_and_project_selected_controller'

    # after(:all) {GeoBuild.clean_slate_geo}

    context 'signed in as a user' do
      before(:each) {
        sign_in_user_and_select_project
      }

      describe 'triggering the export process', js: true do

        before do
          @root = FactoryBot.create(:root_taxon_name, by: @user, project: @project)
          #@taxon_name = FactoryBot.create(:valid_taxon_name, by: @user, project: @project)
          @taxon_name = Protonym.create!(name: "Testidae", rank_class: Ranks.lookup(:iczn, 'Family'), parent: @project.root_taxon_name,
                                          by: @user, project: @project)
          @otu = FactoryBot.create(:valid_otu, by: @user, project: @project, taxon_name: @taxon_name)
          visit(index_path)
        end

        context 'when selecting an OTU and hitting download' do
          xit 'show the download is being created' do
            fill_autocomplete('otu_id_for_coldp', with: @otu.name, select: @otu.id)
            
            # TODO: Cannot find a way to have the job queued and run later, so currently generating directly...
            perform_enqueued_jobs do
              click_on('Download')
            end
            expect(page).to have_content('Status: Download creation is in progress...')

            click_on('Download', exact: true)
          end
        end
      end
    end
  end
end
