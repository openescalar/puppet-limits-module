# vim: ts=2 sw=2 expandtab
# Copyright 2014 Miguel Zuniga ( miguel-zuniga at hotmail.com )
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.#
#
# Adapted from
# http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas
#
# Defines:
#   limits::conf
#
# Manages /etc/security/limits.conf
#
# Examples:
#
#   limits::conf {
#     'oracle soft nofile': value => 131072;
#     'grid soft nofile':   value => 131072';
#   }
#
#

define limits::conf($value) {
  $array  = split($name, ' +')

  $domain = $array[0]
  $type   = $array[1]
  $item   = $array[2]

  if ($domain == '' or $type == '' or $item == '' or $value == '') {
    fail('Argument Error: incorrect number of arguments (4 are required)')
  }

  # guid of this entry
  $key        = "${domain}/${type}/${item}"
  $path_list  = "domain[.=\"${domain}\"][./type=\"${type}\" and ./item=\"${item}\"]"
  $path_exact = "domain[.=\"${domain}\"][./type=\"${type}\" and ./item=\"${item}\" and ./value=\"${value}\"]"

  if $item == 'nproc' and $osfamily == 'RedHat' and $operatingsystemrelease =~ /^6/ {
    $context = '/files/etc/security/limits.d/90-nproc.conf'
  }
  else {
    $context = '/files/etc/security/limits.conf'
  }


  augeas { "limits_conf/${key}":
    context => $context,
    # commenting the line below until puppet 2.7 is in place
    # onlyif  => "match ${path_exact} size != 1",
    changes => [
      # remove all matching to the $domain, $type, $item, for any $value
      "rm ${path_list}",
      # insert new node at the end of tree
      "set domain[last()+1] ${domain}",
      # assign values to the new node
      "set domain[last()]/type ${type}",
      "set domain[last()]/item ${item}",
      "set domain[last()]/value ${value}",
    ],
  }
}
