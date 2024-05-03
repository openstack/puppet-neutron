#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#         Martin Magr <mmagr@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Advanced validation for VLAN configuration
#
Puppet::Functions.create_function(:validate_network_vlan_ranges) do
  def validate_network_vlan_ranges(*args)
    value = args[0]
    if not value.kind_of?(Array)
      value = [value]
    end

    value.each do |range|
      if m = /^([^:]+):(\d+):(\d+)$/.match(range)
        # <physical network>:<min>:<max>
        first_id = Integer(m[-2])
        second_id = Integer(m[-1])
        if (first_id < 1) || (second_id > 4094)
          raise Puppet::Error, "invalid vlan ids are used in vlan ranges."
        end
        if second_id < first_id
          raise Puppet::Error, "network vlan ranges are invalid."
        end
      elsif m = /^([^:]+)$/.match(range)
        # Only name of physical network. This is also correct.
      else
        raise Puppet::Error, "network vlan ranges are invalid."
      end
    end
  end
end
