
require 'spec_helper'

describe 'With default return values' do
  serializer do
    attribute :field
  end

  before do
    create_table{|t| t.string :field}
  end

  after { remove_table }

  context 'when no results are found' do
    it 'returns an empty array' do
      expect(json.first).to be_nil
    end
  end
end
