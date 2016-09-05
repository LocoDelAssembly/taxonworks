require 'rails_helper'

RSpec.describe "origin_relationships/edit", type: :view do
  before(:each) do
    @origin_relationship = assign(:origin_relationship, OriginRelationship.create!(
      :old_object => "",
      :new_object => "",
      :position => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders the edit origin_relationship form" do
    render

    assert_select "form[action=?][method=?]", origin_relationship_path(@origin_relationship), "post" do

      assert_select "input#origin_relationship_old_object[name=?]", "origin_relationship[old_object]"

      assert_select "input#origin_relationship_new_object[name=?]", "origin_relationship[new_object]"

      assert_select "input#origin_relationship_position[name=?]", "origin_relationship[position]"

      assert_select "input#origin_relationship_created_by_id[name=?]", "origin_relationship[created_by_id]"

      assert_select "input#origin_relationship_updated_by_id[name=?]", "origin_relationship[updated_by_id]"

      assert_select "input#origin_relationship_project_id[name=?]", "origin_relationship[project_id]"
    end
  end
end
