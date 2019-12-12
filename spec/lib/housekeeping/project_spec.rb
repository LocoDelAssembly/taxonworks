require 'rails_helper'

describe 'Housekeeping::Project' do

  context 'Projects' do
    let(:instance) {
      stub_model HousekeepingTestClass::WithProject, id: 10
    }

    let!(:user) {FactoryBot.create(:valid_user, id: 1)}

    context 'associations' do
      specify 'belongs_to project' do
        expect(instance).to respond_to(:project)
      end
    end

    context 'Project extensions' do
      before(:all) {
        forced = HousekeepingTestClass::WithProject.new # Force Project extensions by instantiating an instance of the extended class
        Current.user_id = 1
      }

      let(:project) { Project.new(name: 'Foo', without_root_taxon_name: true) }

      specify 'has_many :related_instances' do
        expect(project).to respond_to(:with_projects)
      end

      context 'auto-population and validation' do
        let(:i) {  HousekeepingTestClass::WithProject.new }

        context 'when Current.project_id is set' do
          before(:each) {
            project.save!
            Current.project_id = project.id
          }

          specify 'project_id is set with before_validation' do
            i.valid?
            expect(i.project_id).to eq(project.id)  # see support/set_user_and_project
          end

          specify 'project is set from Current.project_id' do
            Current.project_id = nil # TODO: make a with_no_project method
            i.valid?
            expect(i.project_id.nil?).to be_truthy
            expect(i.errors.include?(:project)).to be_truthy
          end

          specify 'project must exist' do
            Current.project_id = 342432
            i.valid?  # even when set, it's not necessarily valid
            expect(i.errors.include?(:project)).to be_truthy  # there is no project with id 1 in the present paradigm
          end

          context 'belonging to a project' do
            let(:project1) {FactoryBot.create(:valid_project, id: 1) }
            let(:project2) {FactoryBot.create(:valid_project, id: 2) }

            specify 'scoped by a project' do
              @otu1 = Otu.create(project: project1, name: 'Fus')
              @otu2 = Otu.create(project: project2, name: 'Bus')

              expect(Otu.in_project(project1).to_a).to eq([@otu1])
              expect(Otu.with_project_id(project2.id).to_a).to eq([@otu2])
            end
          end
        end
      end
    end
  end
end

module HousekeepingTestClass
  class WithProject < ApplicationRecord
    include FakeTable
    include Housekeeping::Projects
  end
end
