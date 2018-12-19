require 'spec_helper'

describe 'convert_to_json_string' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'hash to json string' do
    data = {:some => "data"}
    is_expected.to run.with_params(data).and_return('{"some":"data"}')
  end

  it 'array of strings with kv to json string' do
    data = ['mykey:myvalue', 'key2:val2']
    is_expected.to run.with_params(data).and_return('{"mykey":"myvalue","key2":"val2"}')
  end

  it 'array of strings to json strings' do
    data = ['val1', 'val2']
    is_expected.to run.with_params(data).and_return('["val1","val2"]')
  end
end
