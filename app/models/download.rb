# A Download represents an expirable file (mostly ZIP files) users can download.
#
# @!attribute name
#   @return [String]
#   The name for this download (not file name).
#
# @!attribute description
#   @return [String]
#   A description for this download.
#
# @!attribute filename
#   @return [String]
#   The filename of this download.
#
# @!attribute request
#   @return [String]
#   The request URI path this download was generated from. This attribute may be used for caching.
#
# @!attribute expires
#   @return [Datetime]
#   The date and time this download is elegible for removal.
#
# @!attribute times_downloaded
#   @return [Integer]
#   The number of times the file was downloaded.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Download < ApplicationRecord
  include Housekeeping

  default_scope { where('expires >= ?', Time.now) }

  after_save :save_file
  after_destroy :delete_file

  validates_presence_of :name
  validates_presence_of :filename
  validates_presence_of :expires


  # Gets the downloads storage path
  def self.storage_path
    STORAGE_PATH
  end

  # Used as argument for :new.
  def source_file_path=(path)
    @source_file_path = path
  end

  # @return [Pathname]
  #   Retrieves the full-path of stored file
  def file_path
    dir_path.join(filename)
  end

  def file
    File.read(file_path)
  end

  # @return [Boolean]
  #   Tells whether the download expiry date has been surpassed.
  def expired?
    expires < Time.now
  end

  # @return [Boolean]
  #   Tells whether the download is ready to be downloaded.
  def ready?
    !expired? && file_path.exist?
  end

  # Deletes associated file from storage
  def delete_file
    path = dir_path
    raise "Download: dir_path not pointing inside storage path! Aborting deletion" unless path.to_s.start_with?(STORAGE_PATH.to_s)

    FileUtils.rm_rf(path)
  end

  private

  STORAGE_PATH = Rails.root.join(Rails.env.test? ? 'tmp' : '', 'downloads').freeze

  def dir_path
    str = id.to_s.rjust(9, '0')
    STORAGE_PATH.join(str[-str.length..-7], str[-6..-4], str[-3..-1])
  end

  def save_file
    FileUtils.mkdir_p(dir_path)
    FileUtils.cp(@source_file_path, file_path) if @source_file_path
  end
end
