require 'spec_helper'

describe "When the .attributes method is called" do
  before do
    create_table do |t|
      t.string :field
      t.string :field1
    end
    Example.create(field: 'value', field1: 'another')
  end
  after { remove_table }

  context "with multiple attributes" do
    serializer { attributes :field, :field1 }

    it 'returns only the defined fields' do
      expect( json.first ).to eq({'field' => 'value', 'field1' => 'another'})
    end
  end
end

