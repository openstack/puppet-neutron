#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# Advanced testing when using GRE
#

define neutron::plugins::ml2::validate_tunnel_id_ranges {
  $first_id = regsubst($name,'^(\d+):(\d+)$','\1') + 0
  $second_id = regsubst($name,'^(\d+):(\d+)$','\2') + 0
  if (($second_id - $first_id) > 1000000) {
    fail('tunnel id ranges are to large.')
  }
  if (($second_id - $first_id) < 0 ) {
    fail('tunnel id ranges are invalid.')
  }
}
