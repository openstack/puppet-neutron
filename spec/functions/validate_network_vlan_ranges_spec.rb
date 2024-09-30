require 'spec_helper'

describe 'validate_network_vlan_ranges' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  context 'with valid values' do
    [
      # only physnet
      'datecentre',
      # physnet:<min>:<max>
      'datecentre:1:100',
      'datecentre:100:100', # min = max should be accepted
      # array
      ['datacentre', 'datacentre2:1:100'],
    ].each do |value|
      it { is_expected.to run.with_params(value) }
    end
  end

  context 'with invalid values' do
    [
      '', # empty string
      '1:100', # missing physnet
      'datecentre:1:', # missing max
      'datecentre::100', # missing min
      'datecentre:a:100', # min is not integer
      'datecentre:1:b', # max is not integer
      'datecentre:1', # not enough fields
      'datecentre:1:100:1000', # too many fields
      'datecentre:1:4095', # max is too large
      'datecentre:0:4094', # min is too small
      'datecentre:101:100', # min > max
    ].each do |value|
      it { is_expected.to run.with_params(value).and_raise_error(Puppet::Error) }
    end
  end
end
