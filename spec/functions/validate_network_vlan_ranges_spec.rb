require 'spec_helper'

describe 'validate_network_vlan_ranges' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'fails with invalid first id max' do
    is_expected.to run.with_params('4095:4096').and_raise_error(Puppet::Error)
  end

  it 'fails with valid first id but invalid second id' do
    is_expected.to run.with_params('1024:4096').and_raise_error(Puppet::Error)
  end

  it 'fails with first range valid and second invalid' do
    is_expected.to run.with_params(['1024:1050', '4095:4096']).and_raise_error(Puppet::Error)
  end

  it 'fails with invalid vlan range' do
    is_expected.to run.with_params('2048:2000').and_raise_error(Puppet::Error)
  end

  it 'fails with invalid vlan range in array' do
    is_expected.to run.with_params(['2048:2000']).and_raise_error(Puppet::Error)
  end

  it 'works with valid vlan range' do
    is_expected.to run.with_params('1024:1048')
  end

  it 'works with valid vlan range in array' do
    is_expected.to run.with_params(['1024:1048', '1050:1060'])
  end

  it 'works with a physical net name' do
    is_expected.to run.with_params('physnet1')
  end

  it 'works with a single vlan' do
    is_expected.to run.with_params('1024')
  end
end
