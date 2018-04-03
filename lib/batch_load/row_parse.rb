# The result of parsing a row.
class BatchLoad::RowParse

  # Whether the row was parsed not
  attr_accessor :parsed

  attr_accessor :parse_errors

  # A bucket of all the objects created, indexed by class
  attr_accessor :objects


  # @return [Ignored]
  def initialize
    @created      = false
    @parsed       = false
    @parse_errors = []
    @objects      = {}
  end

  # @return [Boolean]
  def has_parse_errors?
    parse_errors.size > 0
  end

  # @return [Boolean]
  def has_object_errors?
    objects.select { |o| !o.valid? } > 0
  end

  # @return [Array]
  def persisted_objects
    objects.collect { |type, objs| objs.select { |o| o.persisted? } }.flatten
  end

  # @return [Boolean]
  def has_persisted_objects?
    persisted_objects.size > 0
  end

  # @return [Boolean]
  def has_errored_objects?
    errored_objects.size > 0
  end

  # @return [Array]
  def errored_objects
    objects.collect { |type, objs| objs.select { |o| !o.valid? } }.flatten
  end

  # @return [Array]
  def all_objects
    objects.collect { |type, objs| objs }.flatten
  end

  # @return [Integer]
  def total_objects
    all_objects.size
  end

  # @return [Boolean]
  def has_valid_objects?
    valid_objects.size > 0
  end

  # @return [Array]
  def valid_objects
    objects.collect { |type, objs| objs.select { |o| o.valid? } }.flatten
  end

end
