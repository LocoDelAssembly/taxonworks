class CollectionProfilesController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_collection_profile, only: [:show, :edit, :update, :destroy]

  # GET /collection_profiles
  # GET /collection_profiles.json
  def index
    @collection_profiles = CollectionProfile.all
  end

  # GET /collection_profiles/1
  # GET /collection_profiles/1.json
  def show
  end

  # GET /collection_profiles/new
  def new
    @collection_profile = CollectionProfile.new
  end

  # GET /collection_profiles/1/edit
  def edit
  end

  # POST /collection_profiles
  # POST /collection_profiles.json
  def create
    @collection_profile = CollectionProfile.new(collection_profile_params)

    respond_to do |format|
      if @collection_profile.save
        format.html { redirect_to @collection_profile, notice: 'Collection profile was successfully created.' }
        format.json { render :show, status: :created, location: @collection_profile }
      else
        format.html { render :new }
        format.json { render json: @collection_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_profiles/1
  # PATCH/PUT /collection_profiles/1.json
  def update
    respond_to do |format|
      if @collection_profile.update(collection_profile_params)
        format.html { redirect_to @collection_profile, notice: 'Collection profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection_profile }
      else
        format.html { render :edit }
        format.json { render json: @collection_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_profiles/1
  # DELETE /collection_profiles/1.json
  def destroy
    @collection_profile.destroy
    respond_to do |format|
      format.html { redirect_to collection_profiles_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_profile
      @collection_profile = CollectionProfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_profile_params
      params[:collection_profile]
    end
end
