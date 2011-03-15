#!/usr/bin/env ruby
#
# odbc-export.rb
#
# Connect to an ODBC Data Source Name and export a table to CSV.
#
# See this blog post for more information:
#   http://anthonylewis.com/2011/03/08/exploring-odbc-with-ruby-dbi/
#
# Author:: Anthony Lewis
# Copyright:: Copyright (c) 2011 Anthony Lewis
# License:: Distributed under the same terms as Ruby
#
require 'CSV'
require 'DBI'

class ODBCExport
  def self.export_table(dsn, table)
    # grab a time stamp
    time_stamp = Time.now.strftime("%Y%m%d-%H%M%S")

    # connect to database
    DBI.connect("DBI:ODBC:#{dsn}") do |dbh|
      # query for data
      sth = dbh.prepare("SELECT * FROM #{table}")
      sth.execute

      # open csv file
      CSV.open("#{table}-#{time_stamp}.csv", "wb") do |csv|
        # output column names
        csv << sth.column_names

        # read and export data
        sth.fetch do |row|
          csv << row
        end
      end
      sth.finish
    end
  end

  def self.list_tables(dsn)
    # connect to database
    DBI.connect("DBI:ODBC:#{dsn}") do |dbh|
      # print tables
      dbh.tables.each { |t| puts t }
    end
  end
end

if __FILE__ == $0
  if ARGV.length == 2
    # export a table
    ODBCExport.export_table ARGV[0], ARGV[1]
  elsif ARGV.length == 1
    # list tables
    ODBCExport.list_tables ARGV[0]
  else
    # print usage
    puts "Usage: odbc-export.rb dsn [table]"
    puts "    dsn    The ODBC Data Source Name to use. If no table"
    puts "           is specified, list all tables and exit."
    puts "    table  The name of the table to export."
  end
end

