#   (c) Copyright 2016 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################################
#!!
#! @description: Performs a VMware vSphere command in order to clone an existing virtual machine.
#!
#! @prerequisites: vim25.jar
#!   How to obtain the vim25.jar:
#!     1. Go to https://my.vmware.com/web/vmware and register.
#!     2. Go to https://my.vmware.com/group/vmware/get-download?downloadGroup=MNGMTSDK600 and download the VMware-vSphere-SDK-6.0.0-2561048.zip.
#!     3. Locate the vim25.jar in ../VMware-vSphere-SDK-6.0.0-2561048/SDK/vsphere-ws/java/JAXWS/lib.
#!     4. Copy the vim25.jar into the ClodSlang CLI folder under /cslang/lib.
#!
#! @input host: VMware host or IP
#!              example: 'vc6.subdomain.example.com'
#! @input port: port to connect through
#!              optional
#!              examples: '443', '80'
#!              default: '443'
#! @input protocol: connection protocol
#!                  optional
#!                  valid: 'http', 'https'
#!                  default: 'https'
#! @input username: VMware username to connect with
#! @input password: password associated with <username> input
#! @input trust_everyone: if 'True', will allow connections from any host, if 'False', connection will be
#!                        allowed only using a valid vCenter certificate
#!                        optional
#!                        default: True
#!                        Check https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.dsg.doc_50%2Fsdk_java_development.4.3.html
#!                        to see how to import a certificate into Java Keystore and
#!                        https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.dsg.doc_50%2Fsdk_sg_server_certificate_Appendix.6.4.html
#!                        to see how to obtain a valid vCenter certificate.
#! @input virtual_machine_name: name of virtual machine that will be cloned
#! @input clone_name: name that will be assigned to the cloned virtual machine
#! @input folder_name: name of the folder where the cloned virtual machine will reside. If not provided then the top parent
#!                     folder will be used
#!                     optional
#!                     default: ''
#! @input clone_host: the host for the cloned virtual machine. If not provided then the same host of the virtual machine
#!                    that will be cloned will be used
#!                    optional
#!                    default: ''
#!                    example: 'host123.subdomain.example.com'
#! @input clone_resource_pool: the resource pool for the cloned virtual machine. If not provided then the parent resource
#!                             pool will be used
#!                             optional
#!                             default: ''
#! @input clone_data_store: datastore where disk of newly cloned virtual machine will reside. If not provided then the
#!                          datastore of the cloned virtual machine will be used
#!                          optional
#!                          default: ''
#!                          example: 'datastore2-vc6-1'
#! @input thick_provision: whether the provisioning of the cloned virtual machine will be thick or not
#!                         optional
#!                         default: False
#! @input is_template: whether the cloned virtual machine will be a template or not
#!                     optional
#!                     default: False
#! @input num_cpus: number that indicates how many processors the newly cloned virtual machine will have
#!                  optional
#!                  default: '1'
#! @input cores_per_socket: number that indicates how many cores per socket the newly cloned virtual machine will have
#!                          optional
#!                          default: '1'
#! @input memory: amount of memory (in Mb) attached to cloned virtual machined
#!                optional
#!                default: '1024'
#! @input clone_description: description of virtual machine that will be cloned
#!                           optional
#!                           default: ''
#! @output return_result: contains the exception in case of failure, success message otherwise
#! @output return_code: '0' if operation was successfully executed, '-1' otherwise
#! @output error_message: error message if there was an error when executing, empty otherwise
#! @result SUCCESS: virtual machine was successfully cloned
#! @result FAILURE: an error occurred when trying to clone an existing virtual machine
#!!#
########################################################################################################################

namespace: io.cloudslang.virtualization.vmware.virtual_machines

imports:
  vms: io.cloudslang.virtualization.vmware.virtual_machines
  slp: io.cloudslang.base.utils
  str: io.cloudslang.base.strings
  tmc: io.cloudslang.base.os.linux.samples
  gip: io.cloudslang.virtualization.vmware.utils
  prt: io.cloudslang.base.print

flow:
  name: clone_and_start_vm_deploy_tomcat
  inputs:
    - host
    - port
    - protocol
    - username
    - password
    - trust_everyone
    - virtual_machine_name
    - clone_name
    - folder_name
    - root_password
    - java_version
    - download_url
    - file_name
    - source_path
    - script_file_name



  workflow:
    - clonevm:
        do:
          vms.clone_virtual_machine:
            - host: ${host}
            - port: ${port}
            - protocol: ${protocol}
            - username: ${username}
            - password: ${password}
            - trust_everyone: ${trust_everyone}
            - virtual_machine_name: ${virtual_machine_name}
            - clone_name: ${clone_name}
            - folder_name: ${folder_name}

        publish:
          - return_result
          - error_message
          - return_code
        navigate:
          - SUCCESS: startvm
          - FAILURE: FAILURE

    - startvm:
        do:
          vms.power_on_virtual_machine:
            - host: ${host}
            - port: ${port}
            - protocol: ${protocol}
            - username: ${username}
            - password: ${password}
            - trust_everyone: ${trust_everyone}
            - virtual_machine_name: ${clone_name}

        publish:
          - return_result
          - error_message
          - return_code
        navigate:
          - SUCCESS: wait_for_vmtools
          - FAILURE: FAILURE


    - wait_for_vmtools:
        do:
          slp.sleep:
            - seconds: '90'


    - get_vm_details:
        do:
          vms.print_virtual_machine_details:
            - host: ${host}
            - port: ${port}
            - protocol: ${protocol}
            - username: ${username}
            - password: ${password}
            - trust_everyone: ${trust_everyone}
            - virtual_machine_name: ${clone_name}
            - folder_name: ${folder_name}

        publish:
          - return_result
          - error_message
          - return_code

        navigate:
          - SUCCESS: get_vm_ip
          - FAILURE: FAILURE


    - get_vm_ip:
        do:
          gip.get_ip:
            - map: ${return_result}
        publish:
          - result

    - print_ip:
        do:
          prt.print_text:
            - text: ${result}


    - deploy_tomcat:
        do:
          tmc.deploy_tomcat_on_RHEL:
            - host: ${result}
            - root_password: ${root_password}
            - java_version: ${java_version}
            - download_url: ${download_url}
            - file_name: ${file_name}
            - source_path: ${source_path}
            - script_file_name: ${script_file_name}

        publish:
          - return_result
          - standard_err
          - standard_out
          - return_code
          - command_return_code

        navigate:
          - SUCCESS: print_url
          - INSTALL_JAVA_FAILURE: FAILURE
          - SSH_VERIFY_GROUP_EXIST_FAILURE: FAILURE
          - CHECK_GROUP_FAILURE: FAILURE
          - ADD_GROUP_FAILURE: FAILURE
          - ADD_USER_FAILURE: FAILURE
          - CREATE_DOWNLOADING_FOLDER_FAILURE: FAILURE
          - DOWNLOAD_TOMCAT_APPLICATION_FAILURE: FAILURE
          - UNTAR_TOMCAT_APPLICATION_FAILURE: FAILURE
          - CREATE_SYMLINK_FAILURE: FAILURE
          - INSTALL_TOMCAT_APPLICATION_FAILURE: FAILURE
          - CHANGE_TOMCAT_FOLDER_OWNERSHIP_FAILURE: FAILURE
          - CHANGE_DOWNLOAD_TOMCAT_FOLDER_OWNERSHIP_FAILURE: FAILURE
          - CREATE_INITIALIZATION_FOLDER_FAILURE: FAILURE
          - UPLOAD_INIT_CONFIG_FILE_FAILURE: FAILURE
          - CHANGE_PERMISSIONS_FAILURE: FAILURE
          - START_TOMCAT_APPLICATION_FAILURE: FAILURE

    - print_url:
        do:
          prt.print_text:
            - text: ${'http://' + result + ':8080'}
  outputs:
    - return_result
    - error_message
    - return_code

  results:
    - SUCCESS
    - FAILURE
