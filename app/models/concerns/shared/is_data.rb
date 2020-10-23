# Shared code for a classes that are "data" sensu TaxonWorks (things like Projects, users, and preferences are not data).
#
# !! This module must in included last !!
#
module Shared::IsData

  extend ActiveSupport::Concern

  included do
    include Pinnable
    include Levenshtein
    include Annotation
    include Scopes
    include Navigation
  end

  module ClassMethods

    # @return [Boolean]
    def is_community?
      self < Shared::SharedAcrossProjects ? true : false
    end

    # @return [Array] of strings of only the non-cached and non-housekeeping column names
    def data_attributes
      column_names.reject { |c| %w{id project_id created_by_id updated_by_id created_at updated_at}
        .include?(c) || c =~ /^cached/ }
    end

    # @return [Boolean]
    #   use update vs. a set of ids, but require the update to pass for all or none
    def batch_update_attribute(ids: [], attribute: nil, value: nil)
      return false if ids.empty? || attribute.nil? || value.nil?
      begin
        self.transaction do
          self.where(id: ids).each do |li|
            li.update(attribute => value)
          end
        end
      rescue
        return false
      end
      true
    end

=begin
---------------------------
             1   2   3   4       s returned for similar
---------------------------
1    |abc |  C   s   si  s       i returned for identical
---------------------------
2    |abcd|  s   C   s   s       C returned if class method, identical or similar
---------------------------
3    |abc |  si  s   C   s
---------------------------
4    | bc |              C
---------------------------
=end

    # @param [Hash] attr of matchable attributes
    # @return [Scope]
    def similar(attr)
      klass = self
      attr  = Stripper.strip_similar_attributes(klass, attr)
      attr  = attr.select { |_kee, val| val.present? }

      scope = klass.where(attr)
      scope
    end

    # @param [Hash] attr of matchable attributes
    # @return [Scope]
    def identical(attr)
      klass = self
      attr  = Stripper.strip_identical_attributes(klass, attr)

      scope = klass.where(attr)
      scope
    end

  end  # END CLASS METHODS

  # Returns whether it is permissible to try to destroy
  # they record based on it's relationships to projects
  # the user is in.  I.e. false if it is related to data in
  # a project in which they user is not a member.
  # !! Does not look at :dependendant assertions
  # @return [Boolean]
  #   true - there is at least some related data in another projects
  # @param user [user_id or User]
  #   an id or User object
  def is_destroyable?(user)
    user = User.find(user) if !user.kind_of?(User)
    return true if user.is_administrator?

    p = user.projects.pluck(:id)
    self.class.reflect_on_all_associations(:has_many).each do |r|
      if r.klass.column_names.include?('project_id')
        # If this has any related data in another project, we can't destroy it
        #    if !send(r.name).nil?
        return false if send(r.name).where.not(project_id: p).count(:all) > 0
        #     end
      end
    end

    self.class.reflect_on_all_associations(:has_one).each do |r|
      if is_community? # *this* object is community, others we don't care about
        if o = t.send(r.name)
          return false if o.respond_to(:project_id) && !p.include?(o.project)
        end
      end
    end
    true
  end


  def is_editable?(user)
    user = User.find(user) if !user.kind_of?(User)
    return true if user.is_administrator? || is_community?
    return false if !is_in_users_projects?(user)
    true
  end

  def is_in_users_projects?(user)
    user.projects.pluck(:id).include?(project_id)
  end

  # @return [Boolean]
  # @params exclude [Array]
  #   of symbols
  # @params only [Array]
  #   of symbols
  # !! provide only exclude or only
  def is_in_use?(exclude = [], only = [])
    if only.empty?
      self.class.reflect_on_all_associations(:has_many).each do |r|
        next if exclude.include?(r.name)
        return true if self.send(r.name).count(:all) > 0
      end

      self.class.reflect_on_all_associations(:has_one).each do |r|
        next if exclude.include?(r.name)
        return true if self.send(r.name).count(:all) > 0
      end
    else
      only.each do |r|
        return true if self.send(r.to_s).count(:all) > 0
      end
    end

    false
  end

  # @return [Boolean]
  def is_community?
    self.class < Shared::SharedAcrossProjects ? true : false
  end

  # @return [Object]
  #   the same object, but namespaced to the base class
  #   used many places, might be good target for optimization
  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end

  # @param [Symbol] keys
  # @return [Hash]
  def errors_excepting(*keys)
    valid?
    keys.each do |k|
      errors.delete(k)
    end
    errors
  end

  # @return [Scope]
  def similar
    klass = self.class
    attr  = Stripper.strip_similar_attributes(klass, attributes)
    # matching only those attributes from the instance which are not empty
    attr = attr.select{ |_kee, val| val.present? }
    if id
      scope = klass.where(attr).not_self(self)
    else
      scope = klass.where(attr)
    end
    scope
  end

  # @return [Scope]
  def identical
    klass = self.class
    attr  = Stripper.strip_identical_attributes(klass, attributes)
    if id
      scope = klass.where(attr).not_self(self)
    else
      scope = klass.where(attr)
    end
    scope
  end

  # @param [Symbol] keys
  # @return [Array]
  def full_error_messages_excepting(*keys)
    errors_excepting(*keys).full_messages
  end

end
