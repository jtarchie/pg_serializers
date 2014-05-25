require 'spec_helper'

describe "When the .attribute method is called" do

  before do
    create_table{|t| t.string :field }
    Example.create(field: 'value')
  end
  after { remove_table }


  context "with options" do
    context "that define a custom key" do
      serializer { attribute :field, key: "custom_key" }

      it "returns the value of the field under the specified key" do
        expect( json['custom_key'] ).to eq 'value'
      end

      it "does not contain the original field as a key" do
        expect( json ).to_not have_key('field')
      end
    end
    context "that define a custome key with mixed-cased letters" do
      serializer { attribute :field, key: "LostBoyz123" }

      it "returns the value of the field under the specified key" do
        expect( json['LostBoyz123'] ).to eq 'value'
      end

      it "does not contain the original field as a key" do
        expect( json ).to_not have_key('field')
      end
    end
  end

  context "with a custom attribute method" do
    context "that is a static value" do
      serializer do
        attribute :field

        def field
          "Hello World"
        end
      end

      it "returns the value from the method" do
        expect( json['field'] ).to eq "Hello World"
      end
    end

    context "that is SQL statement" do
      serializer do
        attribute :field

        def field
          Arel::SqlLiteral.new("'2013-11-14 00:00:00'::date")
        end
      end

      it "returns the value from the method" do
        expect( json['field'] ).to eq "2013-11-14"
      end
    end

    context "that is not a column name" do
      serializer do
        attribute :name

        def name
          "Tyler Durton"
        end
      end

      it "returns the value from the method" do
        expect( json['name'] ).to eq "Tyler Durton"
      end
    end
  end
end
