class Predicate < ControlledVocabularyTerm

  has_many :internal_attributes, inverse_of: :predicate, foreign_key: :controlled_vocabulary_term_id

  scope :used_on_klass, -> (klass) { joins(:internal_attributes).where(data_attributes: {attribute_subject_type: klass}) } 

  # @return [Scope]
  #    the max 10 most recently used predicates 
  def self.used_recently(user_id, project_id, klass)
    i = InternalAttribute.arel_table
    p = Predicate.arel_table

    # i is a select manager
    i = i.project(i['controlled_vocabulary_term_id'], i['created_at']).from(i)
      .where(i['created_at'].gt( 1.weeks.ago ))
      .where(i['created_by_id'].eq(user_id))
      .where(i['project_id'].eq(project_id))
      .order(i['created_at'].desc)

    # z is a table alias 
    z = i.as('recent_t')

    Predicate.used_on_klass(klass).joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['controlled_vocabulary_term_id'].eq(p['id'])))
    ).pluck(:id).uniq
  end

  def self.select_optimized(user_id, project_id, klass)
    r = used_recently(user_id, project_id, klass)
    h = {
        quick: [],
        pinboard: Predicate.pinned_by(user_id).where(project_id: project_id).to_a,
        recent: []
    }

    if r.empty?
      h[:quick] = Predicate.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Predicate.where('"controlled_vocabulary_terms"."id" IN (?)', r.first(10) ).order(:name).to_a
      h[:quick] = (Predicate.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          Predicate.where('"controlled_vocabulary_terms"."id" IN (?)', r.first(4) ).order(:name).to_a).uniq
    end

    h
  end

end
