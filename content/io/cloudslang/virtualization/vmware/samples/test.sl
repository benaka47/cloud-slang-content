namespace: io.cloudslang.virtualization.vmware.virtual_machines

imports:
  vms: io.cloudslang.virtualization.vmware.virtual_machines
  slp: io.cloudslang.base.utils
  prt: io.cloudslang.base.print
  str: io.cloudslang.base.strings
  tmc: io.cloudslang.base.os.linux.samples
  gip: io.cloudslang.virtualization.vmware.utils


flow:
  name: test
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









  workflow:
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
            - root_password: 'admin@123'
            - java_version: 'java-1.8.0'
            - download_url: 'http://www.eu.apache.org/dist/tomcat/tomcat-6/v6.0.45/bin/apache-tomcat-6.0.45.tar.gz'
            - file_name: 'apache-tomcat-6.0.45.tar.gz'
            - source_path: '/opt/apache-tomcat/bin'
            - script_file_name: 'startup.sh'

        publish:
          - return_result
          - standard_err
          - standard_out
          - return_code
          - command_return_code

        navigate:
          - SUCCESS: SUCCESS
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

  outputs:
    - return_result
    - error_message
    - return_code

  results:
    - SUCCESS
    - FAILURE
