# A GeographicArea is a gazeteer entry for some political subdivision. GeographicAreas are presently
# limited to second level subdivisions (e.g. counties in the United States) or higher (i.e. state/country)
# * "Levels" are non-normalized values for convenience.
#
# There are multiple hierarchies stored in GeographicArea (e.g. TDWG, GADM2).  Only when those
# name "lineages" completely match are they merged.
#
# @!attribute name
#   @return [String]
#   The name of the geographic area
#
# @!attribute level0_id
#   @return [Integer]
#   The id of the GeographicArea *country* that this geographic area belongs to, self.id if self is a country
#
# @!attribute level1_id
#   @return [Integer]
#   The id of the first level subdivision (starting from country) that this geographic area belongs to, self if self is a first level subdivision
#
# @!attribute level2_id
#   @return [Integer]
#   The id of the second level subdivision (starting from country) that this geographic area belongs to, self if self is a second level subdivision
#
# @!attribute parent_id
#   @return [Integer]
#   The id of the parent of this geographic area, will never be self, may be null (for Earth). Generally, sovereign countries have 'Earth' as parent.
#
# @!attribute geographic_area_type_id
#   @return [Integer]
#   The id of the type of this geographic area, index of geographic_area_types
#
# @!attribute iso_3166_a2
#   @return [String]
#   Two alpha-character identification of country.
#
# @!attribute iso_3166_a3
#   @return [String]
#   Three alpha-character identification of country.
#
# @!attribute tdwgID
#   @return [String]
#   If derived from the TDWG hierarchy the tdwgID.  Should be accessed through self#tdwg_ids, not directly.
#
# @!attribute data_origin
#   @return [String]
#   Text describing the source of the data used for creation (TDWG, GADM, NaturalEarth, etc.).
#
class GeographicArea < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData
  include Shared::IsApplicationData

  has_closure_tree

  belongs_to :geographic_area_type, inverse_of: :geographic_areas
  belongs_to :level0, class_name: 'GeographicArea', foreign_key: :level0_id
  belongs_to :level1, class_name: 'GeographicArea', foreign_key: :level1_id
  belongs_to :level2, class_name: 'GeographicArea', foreign_key: :level2_id

  has_many :asserted_distributions, inverse_of: :geographic_area
  has_many :collecting_events, inverse_of: :geographic_area
  has_many :geographic_areas_geographic_items, -> { ordered_by_data_origin }, dependent: :destroy, inverse_of: :geographic_area
  has_many :geographic_items, through: :geographic_areas_geographic_items

  accepts_nested_attributes_for :geographic_areas_geographic_items

  validates :geographic_area_type, presence: true
  validates_presence_of :geographic_area_type_id

  validates :parent, presence: true, unless: -> {self.name == 'Earth'} # || ENV['NO_GEO_VALID']}
  validates :level0, presence: true, allow_nil: true, unless: -> {self.name == 'Earth'}
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true
  validates :name, presence: true, length: {minimum: 1}
  validates :data_origin, presence: true

  scope :descendants_of, -> (geographic_area) {with_ancestor(geographic_area)}
  scope :ancestors_of, -> (geographic_area) { joins(:descendant_hierarchies).order('geographic_area_hierarchies.generations DESC').where(geographic_area_hierarchies: {descendant_id: geographic_area.id}).where('geographic_area_hierarchies.ancestor_id != ?', geographic_area.id) }

  scope :self_and_ancestors_of, -> (geographic_area) {
    joins(:descendant_hierarchies)
      .where(geographic_area_hierarchies: {descendant_id: geographic_area.id})
  }

  # HashAggregate  (cost=24274.42..24274.79 rows=37 width=77)
  # this is subtly different, it includes self in present form
  # scope :ancestors_and_descendants_of, -> (geographic_area) {
  #   joins('LEFT OUTER JOIN geographic_area_hierarchies a ON geographic_areas.id = a.descendant_id '  \
  #     'LEFT JOIN geographic_area_hierarchies b ON geographic_areas.id = b.ancestor_id')
  #     .where("(a.ancestor_id = ?) OR (b.descendant_id = ?)", geographic_area.id, geographic_area.id)
  #     .uniq
  # }

  #  HashAggregate  (cost=100.89..100.97 rows=8 width=77)
  scope :ancestors_and_descendants_of, -> (geographic_area) do
    a = GeographicArea.self_and_ancestors_of(geographic_area)
    b = GeographicArea.descendants_of(geographic_area)
    GeographicArea.from("((#{a.to_sql}) UNION (#{b.to_sql})) as geographic_areas")
  end

  scope :with_name_like, lambda { |string|
    where(['name like ?', "#{string}%"])
  }

  # @param  [Array] of names of self and parent
  # @return [Scope]
  #  Matches GeographicAreas that have name and parent name.
  #  Call via find_by_self_and_parents(%w{Champaign Illinois}).
  scope :with_name_and_parent_name, lambda { |names|
    if names[1].nil?
      where(name: names[0])
    else
      joins('join geographic_areas ga on ga.id = geographic_areas.parent_id')
        .where(name: names[0]).where(['ga.name = ?', names[1]])
    end
  }

  # @param  [Array] names of self and parents
  # @return [Scope] GeographicAreas which have the names of self and parents
  # TODO: Test, or extend a general method
  # Matches GeographicAreas that match name, parent name, parent.parent name.
  # Call via find_by_self_and_parents(%w{Champaign Illinois United\ States}).
  scope :with_name_and_parent_names, lambda { |names|
    if names[2].nil?
      with_name_and_parent_name(names.compact)
    else
      joins('join geographic_areas ga on ga.id = geographic_areas.parent_id')
        .joins('join geographic_areas gb on gb.id = ga.parent_id')
        .where(name: names[0])
        .where(['ga.name = ?', names[1]])
        .where(['gb.name = ?', names[2]])
    end
  }


  before_destroy :check_for_children

  # @param array [Array] of strings of names for areas
  # @return [Scope] of GeographicAreas which match name and parent.name.
  # Route out to a scope given the length of the
  # search array.  Could be abstracted to
  # build nesting on the fly if we actually
  # needed more than three nesting levels.
  def self.find_by_self_and_parents(array)
    if array.length == 1
      where(name: array.first)
    elsif array.length == 2
      with_name_and_parent_name(array)
    elsif array.length == 3
      with_name_and_parent_names(array)
    else
      where { 'false' }
    end
  end

  # @return [Scope] GeographicAreas which are countries.
  def self.countries
    includes([:geographic_area_type]).where(geographic_area_types: {name: 'Country'})
  end

  # @param [GeographicArea]
  # @return [Scope] of geographic_areas
  def self.is_contained_by(geographic_area)
    pieces = nil
    if geographic_area.geographic_items.any?
      pieces = GeographicItem.is_contained_by('any_poly', geographic_area.geo_object)
      others = []
      pieces.each { |other|
        others.push(other.geographic_areas.to_a)
      }
      pieces = GeographicArea.where('id in (?)', others.flatten.map(&:id).uniq)
    end
    pieces
  end

  # @param [GeographicArea]
  # @return [Scope] geographic_areas which are 'children' of the supplied geographic_area.
  def self.are_contained_in(geographic_area)
    pieces = nil
    if geographic_area.geographic_items.any?
      pieces = GeographicItem.are_contained_in_item('any_poly', geographic_area.geo_object)
      others = []
      pieces.each { |other|
        others.push(other.geographic_areas.to_a)
      }
      pieces = GeographicArea.where('id in (?)', others.flatten.map(&:id).uniq)
    end
    pieces
  end

  # @param latitude [Double] Decimal degrees
  # @param longitude [Double] Decimal degrees
  # @return [Scope] all areas which contain the point specified.
  def self.find_by_lat_long(latitude = 0.0, longitude = 0.0)
    point        = "POINT(#{longitude} #{latitude})"
    where_clause = "ST_Contains(polygon::geometry, GeomFromEWKT('srid=4326;#{point}'))" \
      " OR ST_Contains(multi_polygon::geometry, GeomFromEWKT('srid=4326;#{point}'))"
    retval       = GeographicArea.joins(:geographic_items).where(where_clause)
    retval
  end

  # @return [Scope] of areas which have at least one shape
  def self.have_shape?
    joins(:geographic_areas_geographic_items).select('distinct(geographic_areas.id)')
  end

  # @return [Hash]
  #   a key valus pair that classifies this geographic
  #   area into country, state, county categories.
  #   !! This is an estimation, although likely highly accurate.  It uses assumptions about how data are stored in GeographicAreas
  #   to derive additional data, particularly for State
  def categorize
    n = geographic_area_type.name
    return {country: name} if GeographicAreaType::COUNTRY_LEVEL_TYPES.include?(n) || (id == level0_id)
    return {state: name} if GeographicAreaType::STATE_LEVEL_TYPES.include?(n) || (data_origin == 'ne_states') || (id == level1_id) || (!parent.nil? && (parent.try(:id) == parent.try(:level0_id)))
    return {county: name} if GeographicAreaType::COUNTY_LEVEL_TYPES.include?(n)
    {}
  end

  # @return [Hash]
  #   use the parent/child relationships of the this GeographicArea to return a country/state/county categorization
  def geographic_name_classification
    v = {}
    self_and_ancestors.each do |a|
      v.merge!(a.categorize)
    end
    v
  end

  # @return [Scope] all known level 1 children, generally state or province level.
  def children_at_level1
    GeographicArea.descendants_of(self).where('level1_id IS NOT NULL AND level2_id IS NULL')
  end

  # @return [Scope] all known level 2 children, generally county or prefecture level.
  def children_at_level2
    GeographicArea.descendants_of(self).where('level2_id IS NOT NULL')
  end

  # @param [String] geographic_area_type name of geographic_area_type (e.g., 'Country', 'State', 'City')
  # @return [Scope] descendants of this instance which have specific types, such as counties of a state.
  def descendants_of_geographic_area_type(geographic_area_type)
    GeographicArea.descendants_of(self).includes([:geographic_area_type])
      .where(geographic_area_types: {name: geographic_area_type})
  end

  # @param [Array] geographic_area_type_names names
  # @return [Scope] descendants of this instance which have specific types, such as cities and counties of a province.
  def descendants_of_geographic_area_types(geographic_area_type_names)
    GeographicArea.descendants_of(self).includes([:geographic_area_type])
      .where(geographic_area_types: {name: geographic_area_type_names})
  end

  # @return [Hash] keys point to each of the four level components of the ID.  Matches values in original data.
  def tdwg_ids
    {
      lvl1: tdwgID.slice(0),
      lvl2: tdwgID.slice(0, 2),
      lvl3: tdwgID.slice(2, 3),
      lvl4: tdwgID.slice(2, 6)
    }
  end

  # @return [String, nil] 1, 2, 3, 4 iff is TDWG data source
  def tdwg_level
    return nil unless data_origin =~ /TDWG/
    data_origin[-1]
  end

  def has_shape?
    geographic_items.any?
  end

  # @return [RGeo object] of the default GeographicItem
  def geo_object
    default_geographic_item
  end

  alias shape geo_object

  # @return [GeographicItem, nil]
  #   a "preferred" geographic item for this geographic area, where preference
  #   is based on an ordering of source gazeteers, the order being
  #   1) Natural Earth Countries
  #   2) Natural Earth States
  #   3) GADM
  #   4) everything else (at present, TDWG)
  def default_geographic_item
    geographic_items.joins(:geographic_areas_geographic_items).merge(GeographicAreasGeographicItem.ordered_by_data_origin).first # .merge on same line as joins()
  end

  # @return [Hash] of the pieces of a GeoJSON 'Feature'
  def to_geo_json_feature
    to_simple_json_feature.merge(
      'properties' => {
        'geographic_area' => {
          'id'  => id,
          'tag' => name
        }
      }
    )
  end

  # TODO: parametrize to include gazeteer
  #   i.e. geographic_areas_geogrpahic_items.where( gaz = 'some string')
  def to_simple_json_feature
    result = {
      'type'       => 'Feature',
      'properties' => {}
    }
    area               = geographic_items.order(:id)
    result['geometry'] = area.first.to_geo_json unless area.empty?
    result
  end

  # Find a centroid by scaling this object tree up to the first antecedent which provides a geographic_item, and
  # provide a point on which to focus the map.  Return 'nil' if there are no GIs in the chain.
  # @return [GeographicItem] a point.
  def geographic_area_map_focus
    item = nil
    if geographic_items.count == 0
      # this nil signals the top of the stack: Everything terminates at 'Earth'
      item = parent.geographic_area_map_focus unless parent.nil?
    else
      item = GeographicItem.new(point: geographic_items.first.st_centroid)
    end
    item
  end

  # @return [Hash]
  #   this instance's attributes applicable to GeoLocate
  def geolocate_attributes
    parameters = {
      'county'  => level2.try(:name),
      'state'   => level1.try(:name),
      'country' => level0.try(:name)
    }

    if item = geographic_area_map_focus # rubocop:disable Lint/AssignmentInCondition
      parameters['Longitude'] = item.point.x
      parameters['Latitude']  = item.point.y
    end

    parameters
  end

  def geolocate_ui_params
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_hash
  end

  # "http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?country=United States of
  # America&state=Illinois&locality=Champaign&
  # points=40.091622|-88.241179|Champaign|low|7000&georef=run|false|false|true|true|false|false|false|0&gc=Tester"
  # @return [String]
  def geolocate_ui_params_string
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_string
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  # @return [Hash]
  #   query_line => [Array of GeographicArea]
  # @params [text]
  #   one result set per line (\r\n)
  #   lines can have child:parent:parent name patterns
  def self.matching(text, has_shape = false, invert = false)
    if text.nil? || text.length == 0
      return Hash.new('No query provided!' => [])
    end

    text.gsub!(/\r\n/, "\n")

    result  = {}
    queries = text.split("\n")
    queries.each do |q|
      names = q.strip.split(':')
      names.reverse! if invert
      names.collect{|s| s.strip}
      r         = GeographicArea.with_name_and_parent_names(names)
      r         = r.joins(:geographic_items) if has_shape
      result[q] = r
    end
    result
  end

  protected

  before_destroy :check_for_children

  def check_for_children
    unless leaf?
      errors[:base] << "has attached names, delete these first"
      return false
    end
  end

end
