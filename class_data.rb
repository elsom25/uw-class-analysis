# =============================================================================
# Load dependencies
# -----------------------------------------------------------------------------
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

require 'net/http'
require 'csv'

# From a given term, using the api's from api.uwaterloo.ca, creates a csv of
#   all classes offered, the room, the professor, and the class size.
#
# - - - - - U S A G E - - - - -
#
# Initial Usage:
#
#   class_data = ClassData.new( TERM_STRING )
#
# Get the table to play with:
#
#    table = class_data.class_data_table
#
# Write the table out to file:
#
#   class_data.create_csv
#
class ClassData

  attr_reader :class_data_table

  def initialize(term, api_key)
    raise 'term must be an String.' unless term.is_a? String
    @term = term
    @api_key = api_key

    build_table
    import_term_data(@term)
  end

  def create_csv(file_name="__class_data_#{@term}.csv")
    CSV.open( file_name, 'w',
              write_headers: true,
              headers: @class_data_table.columns.map(&:to_s)
             ) do |csv_out|
      @class_data_table.each do |row|
        csv_out << row.to_a.transpose.last
      end
    end
  end

protected

  def api(api_code)
    uri = URI("https://api.uwaterloo.ca/v2/#{api_code}.json?key=#{@api_key}")
    http_response = Net::HTTP.get(uri)

    json_hash = Oj.load(http_response)
    response = RecursiveOpenStruct.new(json_hash, recurse_over_arrays: true )

    raise "#{response.meta.status}: #{response.meta.message}" if [401].include? response.meta.status
    response.data
  end

  def build_table
    @@DB = Sequel.sqlite
    @@DB.create_table :class_data do
      primary_key :id
      String :subject_code
      String :title

      String :section
      String :campus
      String :capacity
      String :enrollment
      String :location
      String :profs

      String :start_time
      String :end_time
      String :weekdays
    end
    @class_data_table = @@DB[:class_data]
  end

  def import_term_data(term)
    subject_list = api('codes/subjects').map(&:subject)

    subject_list.each do |subject|
      api("terms/#{term}/#{subject}/schedule").each do |course|
        course.classes.each do |lecture|
          next if lecture.dates.start_time.nil?

          next if course.campus.include? 'ABROAD'
          next unless course.section.include? 'LEC'

          @class_data_table.insert(
                 subject_code: course.subject,
                        title: course.title,

                      section: course.section,
                       campus: course.campus,
                     capacity: course.enrollment_capacity,
                   enrollment: course.enrollment_total,

                     location: "#{lecture.location.building} #{lecture.location.room}",
                        profs: lecture.instructors.join('; '),

                   start_time: lecture.dates.start_time,
                     end_time: lecture.dates.end_time,
                     weekdays: lecture.dates.weekdays
          )
        end
      end
    end
  end

end
