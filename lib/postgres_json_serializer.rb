require "postgres_json_serializer/version"

module PostgresJsonSerializer
  Attribute = Struct.new(:field, :options) do
    def to_sql(serializer)
      connection = serializer.scope.connection
      if serializer.respond_to?(field)
        value = serializer.send(field)
        case value
          when Arel::SqlLiteral
            value = value.to_s
          else
            value = connection.quote(value)
        end
      end

      sql = "#{value || field}"
      sql += " AS #{options.try(:[], :key) || field}"
      sql
    end
  end

  class Serializer < Struct.new(:scope)
    def self.attribute(field, options = {})
      @attributes ||= []
      @attributes << Attribute.new(field, options)
    end

    def self.attributes(*fields)
      @attributes ||= []
      @attributes += fields.collect{|f| Attribute.new(f) }
    end

    def to_json
      connection = scope.connection
      attributes_select = self.class.attributes.collect do |a|
        a.to_sql(self)
      end
      connection.select_value("SELECT array_to_json(array_agg(row_to_json(t))) FROM (#{scope.select(attributes_select).to_sql}) t")
    end
  end
end
