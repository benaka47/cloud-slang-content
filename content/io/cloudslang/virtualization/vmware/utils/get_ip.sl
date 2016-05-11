#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#!!
#! @description: Gets values from maps.
#! @input map: map  - Example: {'laptop': 1000, 'docking station':200, 'monitor': 500, 'phone': 100}
#! @output result: keys from map.
#!!#
####################################################

namespace: io.cloudslang.virtualization.vmware.utils

operation:
  name: get_ip
  inputs:
    - map
  action:
    python_script: |
      data= eval(map)
      item = data.get('ipAddress')
  outputs:
    - result: ${item}
