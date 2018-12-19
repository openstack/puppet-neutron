require 'spec_helper'

describe 'validate_tunnel_id_ranges' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'fails with invalid input' do
    is_expected.to run.with_params('??!!!').and_raise_error(Puppet::Error)
  end

  it 'fails with invalid range' do
    is_expected.to run.with_params('4096').and_raise_error(Puppet::Error)
  end

  it 'fails with invalid range in array' do
    is_expected.to run.with_params(['4096']).and_raise_error(Puppet::Error)
  end

  it 'fails with invalid range max' do
    is_expected.to run.with_params('2048:1024').and_raise_error(Puppet::Error)
  end

  it 'fails with invalid range max in array' do
    is_expected.to run.with_params(['2048:1024']).and_raise_error(Puppet::Error)
  end

  it 'fails when range is too large' do
    is_expected.to run.with_params('10:1100000').and_raise_error(Puppet::Error)
  end

  it 'works with valid range' do
    is_expected.to run.with_params('1024:2048')
  end

  it 'works with valid array of ranges' do
    is_expected.to run.with_params(['1024:2048', '4096:8296'])
  end
end
