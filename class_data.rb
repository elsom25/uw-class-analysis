# =============================================================================
# Load dependencies
# -----------------------------------------------------------------------------
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

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

  def initialize(term)
    raise 'term must be an String.' unless term.is_a? String

    build_table
    import_voter_lists(term)
  end

  def create_csv(file_name='__class_data.csv')
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

  def build_table
    @@DB = Sequel.sqlite
    @@DB.create_table :class_data do
      primary_key :id
      Integer :student_id, unique: true
      String  :user_id, unique: true

      String  :first_name
      String  :middle_name
      String  :last_name
      String  :email

      String  :program
      String  :academic_plan
      String  :term
      String  :campus

      String  :ip
      String  :vote_time
    end
    @class_data_table = @@DB[:class_data]
  end

  def import_voter_lists(voter_list_files)
    # need to nuke the first line, since it interfears with headers
    voter_list_files = voter_list_files.map do |input|
      output = "#{input}.tmp"
      system("tail -n +2 #{input} > #{output}") #kinda hacky
      output
    end

    voter_list_files.each do |f|
      CSV.foreach(f, headers: :first_row) do |row|
        @class_data_table.insert(
             student_id: row['Student ID'],
                user_id: row['User'],
             first_name: row['First Name'],
            middle_name: row['Middle'],
              last_name: row['Last'],
                  email: row['Email ID'],
                program: row['Program'],
          academic_plan: row['Acad Plan'],
                   term: row['Proj Level'],
                 campus: row['Campus']
        ) rescue next
      end
    end
    FileUtils.rm voter_list_files
  end

  def import_results_lists(file_results)
    file_results = file_results.map do |f|
      raw_string = open(f, &:read)
      results_arr = raw_string.scan(/ ([a-zA-Z]\w{3,11}  .*?) ((?= [a-zA-Z]\w{3,11}) | $) /mx).map(&:first)
    end

    file_results.each do |result|
      result.each do |data|
        user_id = find_user_id(data)
        ip = find_ip(data)
        vote_datetime = find_vote_datetime(data)

        @class_data_table.where('user_id = ?', user_id).update( ip: ip, vote_time: vote_datetime)
      end
    end
  end

  def find_user_id(str)
    str.match(/ [a-zA-Z]\w{3,11} /mx).to_s
  end

  def find_ip(str)
    raw_ip = str.match(/ \[ (.*) \] /mx)
    raw_ip[1].to_s if raw_ip
  end

  def find_vote_datetime(str)
    raw_vote_datetime = str.match(/ at\ (.*) /mx)
    DateTime.parse( raw_vote_datetime.to_s ) if raw_vote_datetime
  end

end
