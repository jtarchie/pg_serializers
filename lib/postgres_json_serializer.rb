require "postgres_json_serializer/version"

module PostgresJsonSerializer
  Attribute = Struct.new(:field, :options) do
    def custom_key(key)
      (options.try(:[], :key) || key).to_s
    end

    def to_arel(serializer)
      connection = serializer.scope.connection
      if serializer.respond_to?(field)
        value = serializer.send(field)
        value = Arel.sql(connection.quote(value)) unless value.is_a?(Arel::SqlLiteral)
      else
        model = serializer.scope.model
        value = model.arel_table[field]
      end

      value.as(connection.quote_column_name(custom_key(field)))
    end
  end

  class Serializer
    attr_reader :scope

    def initialize(scope)
      @scope = scope.dup
    end

    def self.attribute(field, options = {})
      add_attribute Attribute.new(field, options)
    end

    def self.attributes(*fields)
      add_attribute *fields.collect{|f| Attribute.new(f) }
    end

    def self.add_attribute(*attributes)
      @attributes ||= []
      @attributes += attributes
    end

    def to_json(*)
      connection = scope.connection
      attributes_select = self.class.attributes.collect do |a|
        a.to_arel(self)
      end
      connection.select_value("SELECT COALESCE(array_to_json(array_agg(row_to_json(t))), '[]') FROM (#{scope.select(attributes_select).to_sql}) t")
    end
  end
end

