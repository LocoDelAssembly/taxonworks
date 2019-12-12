require 'rails_helper'

describe 'New taxon name', type: :feature, group: :nomenclature do

  context 'when signed in and a project is selected' do

    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      let!(:root) { @project.send(:create_root_taxon_name) }

      before { visit new_taxon_name_task_path }

      specify 'add a name' do
        fill_in "taxon-name", with: 'Qurious'
        find('#parent-name input').fill_in(with: 'Root')
        find('li', text: 'Root nomenclatural rank').hover.click 
        find('label', text: 'ICZN').click
        find('label', text: 'Genus').click
        click_button 'Create'
        expect(page).to have_text('Edit taxon name')
      end

      context "#{OS.mac? ? 'ctrl': 'alt'}-t navigation" do
        let!(:genus) { Protonym.create!(by: @user, project: @project, parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus)) }
        before { visit new_taxon_name_task_path(taxon_name_id: genus.id) }

        specify "#{OS.mac? ? 'ctrl': 'alt'}-t navigates to Browse taxon name task" do
          expect(page).to have_text('Edit taxon name')
          find('body').send_keys([OS.mac? ? :control : :alt, 't'])
          expect(page).to have_text('Browse nomenclature')
        end
      end

    end
  end
end
