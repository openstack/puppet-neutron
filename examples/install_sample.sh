modpath=$HOME/modules/
git clone https://github.com/ekarlso/puppet-vswitch $modpath/vswitch
git clone https://github.com/cprice-puppet/puppetlabs-inifile $modpath/inifile
git clone https://github.com/EmilienM/openstack-quantum-puppet $modpath/quantum
git clone git://github.com/puppetlabs/puppetlabs-stdlib.git $modpath/stdlib
git clone -b folsom git://github.com/puppetlabs/puppetlabs-keystone.git $modpath/keystone
puppet apply --modulepath $modpath $(dirname $0)/quantum.pp --debug
