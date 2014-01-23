require 'benchmark'
require 'oj'
require 'postgres_json_serializer'
require_relative '../spec/support/db'

n = 100000


connection = Example.connection
connection.create_table(:examples) {|t| t.integer :number }

n.times{|i| Example.create(number: i)}

ActiveRecord::Base.logger = Logger.new(STDOUT)

class Serializer < PostgresJsonSerializer::Serializer
  attribute :number
end

Benchmark.bm do |x|
  x.report("to_json") { Example.all.to_json }
  x.report("serializer") { Serializer.new(Example.all).to_json }
end
