require 'spec_helper'

describe 'validate_vxlan_udp_port' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'fails with port too high integer' do
    is_expected.to run.with_params(65536).and_raise_error(Puppet::Error)
  end

  it 'fails with a well known port integer' do
    is_expected.to run.with_params(90).and_raise_error(Puppet::Error)
  end

  it 'fails with a well known port string' do
    is_expected.to run.with_params('90').and_raise_error(Puppet::Error)
  end

  it 'fails with port too high string' do
    is_expected.to run.with_params('65536').and_raise_error(Puppet::Error)
  end

  it 'works with default port integer' do
    is_expected.to run.with_params(4789)
  end

  it 'works with default port string' do
    is_expected.to run.with_params('4789')
  end

  it 'works with a private port integer' do
    is_expected.to run.with_params(49155)
  end

  it 'works with a private port string' do
    is_expected.to run.with_params('49155')
  end
end
