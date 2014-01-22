require 'spec_helper'

describe 'When serializing data types' do
  serializer do
    attribute :field
  end

  before do
    create_table{|t| t.send(field, :field)}
    Example.create(:field => value)
  end

  after { remove_table }

  context 'for text fields' do
    let(:field) { :text }
    let(:value) { 'My awesome string' }

    it 'returns a JSON string' do
      expect( json['field'] ).to eq value
    end
  end

  context 'for string fields' do
    let(:field) { :string }
    let(:value) { 'My awesome string' }

    it 'returns a JSON string' do
      expect( json['field'] ).to eq value
    end
  end

  context 'for integer fields' do
    let(:field) { :integer }
    let(:value) { 12345 }

    it 'returns a JSON integer' do
      expect( json['field'] ).to eq value
    end
  end

  context 'for float fields' do
    let(:field) { :float }
    let(:value) { 3.14159 }

    it 'returns a JSON float' do
      expect( json['field'] ).to eq value
    end
  end

  context 'for decimal fields' do
    let(:field) { :decimal }
    let(:value) { 3.14159 }

    it 'returns a JSON float' do
      expect( json['field'] ).to eq value
    end
  end

  context 'for datetime fields' do
    let(:field) { :datetime }
    let(:value) { DateTime.new(2012, 12, 11, 5, 18, 23) }

    it 'returns a JSON ISO datetime' do
      expect( json['field'] ).to eq "2012-12-11 05:18:23"
    end
  end

  context 'for timestamp fields' do
    let(:field) { :timestamp }
    let(:value) { DateTime.new(2012, 12, 11, 5, 18, 23) }

    it 'returns a JSON ISO datetime' do
      expect( json['field'] ).to eq "2012-12-11 05:18:23"
    end
  end

  context 'for date fields' do
    let(:field) { :date }
    let(:value) { Date.new(2012, 12, 23) }

    it 'returns a JSON ISO date' do
      expect( json['field'] ).to eq "2012-12-23"
    end
  end

  context 'for boolean fields' do
    let(:field) { :boolean }
    let(:value) { true }

    it 'returns a JSON true' do
      expect( json['field'] ).to eq value
    end
  end
end
