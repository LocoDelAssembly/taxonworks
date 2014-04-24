require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe GeographicAreasController do

  # This should return the minimal set of attributes required to create a valid
  # GeographicArea. As you add validations to GeographicArea, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "name" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GeographicAreasController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all geographic_areas as @geographic_areas" do
      geographic_area = GeographicArea.create! valid_attributes
      get :index, {}, valid_session
      assigns(:geographic_areas).should eq([geographic_area])
    end
  end

  describe "GET show" do
    it "assigns the requested geographic_area as @geographic_area" do
      geographic_area = GeographicArea.create! valid_attributes
      get :show, {:id => geographic_area.to_param}, valid_session
      assigns(:geographic_area).should eq(geographic_area)
    end
  end

  describe "GET new" do
    it "assigns a new geographic_area as @geographic_area" do
      get :new, {}, valid_session
      assigns(:geographic_area).should be_a_new(GeographicArea)
    end
  end

  describe "GET edit" do
    it "assigns the requested geographic_area as @geographic_area" do
      geographic_area = GeographicArea.create! valid_attributes
      get :edit, {:id => geographic_area.to_param}, valid_session
      assigns(:geographic_area).should eq(geographic_area)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new GeographicArea" do
        expect {
          post :create, {:geographic_area => valid_attributes}, valid_session
        }.to change(GeographicArea, :count).by(1)
      end

      it "assigns a newly created geographic_area as @geographic_area" do
        post :create, {:geographic_area => valid_attributes}, valid_session
        assigns(:geographic_area).should be_a(GeographicArea)
        assigns(:geographic_area).should be_persisted
      end

      it "redirects to the created geographic_area" do
        post :create, {:geographic_area => valid_attributes}, valid_session
        response.should redirect_to(GeographicArea.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved geographic_area as @geographic_area" do
        # Trigger the behavior that occurs when invalid params are submitted
        GeographicArea.any_instance.stub(:save).and_return(false)
        post :create, {:geographic_area => { "name" => "invalid value" }}, valid_session
        assigns(:geographic_area).should be_a_new(GeographicArea)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        GeographicArea.any_instance.stub(:save).and_return(false)
        post :create, {:geographic_area => { "name" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        # Assuming there are no other geographic_areas in the database, this
        # specifies that the GeographicArea created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        GeographicArea.any_instance.should_receive(:update).with({ "name" => "MyString" })
        put :update, {:id => geographic_area.to_param, :geographic_area => { "name" => "MyString" }}, valid_session
      end

      it "assigns the requested geographic_area as @geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        put :update, {:id => geographic_area.to_param, :geographic_area => valid_attributes}, valid_session
        assigns(:geographic_area).should eq(geographic_area)
      end

      it "redirects to the geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        put :update, {:id => geographic_area.to_param, :geographic_area => valid_attributes}, valid_session
        response.should redirect_to(geographic_area)
      end
    end

    describe "with invalid params" do
      it "assigns the geographic_area as @geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        GeographicArea.any_instance.stub(:save).and_return(false)
        put :update, {:id => geographic_area.to_param, :geographic_area => { "name" => "invalid value" }}, valid_session
        assigns(:geographic_area).should eq(geographic_area)
      end

      it "re-renders the 'edit' template" do
        geographic_area = GeographicArea.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        GeographicArea.any_instance.stub(:save).and_return(false)
        put :update, {:id => geographic_area.to_param, :geographic_area => { "name" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested geographic_area" do
      geographic_area = GeographicArea.create! valid_attributes
      expect {
        delete :destroy, {:id => geographic_area.to_param}, valid_session
      }.to change(GeographicArea, :count).by(-1)
    end

    it "redirects to the geographic_areas list" do
      geographic_area = GeographicArea.create! valid_attributes
      delete :destroy, {:id => geographic_area.to_param}, valid_session
      response.should redirect_to(geographic_areas_url)
    end
  end

end
