# (c) Copyright 2015 Liran Tal
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
# The Apache License is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#!!
#! @description: Checks out a git branch.
#! @input host: hostname or IP address
#! @input port: optional - port number for running the command
#! @input username: username to connect as
#! @input password: optional - password of user
#! @input git_branch: optional - git branch to checkout
#! @input git_repository_localdir: optional - target directory where a git repository exists and git_branch should be checked out to - Default: /tmp/repo.git
#! @input git_pull_remote: optional - if git_pull is set to true then specify the remote branch to pull from - Default: origin
#! @input sudo_user: optional - true or false, whether the command should execute using sudo - Default: false
#! @input private_key_file: optional - path to private key file
#! @output return_result: STDOUT of the remote machine in case of success or the cause of the error in case of exception
#! @output standard_out: STDOUT of the machine in case of successful request, null otherwise
#! @output standard_err: STDERR of the machine in case of successful request, null otherwise
#! @output exception: contains the stack trace in case of an exception
#! @output command_return_code: return code of remote command corresponding to the SSH channel. The return code is
#!                              only available for certain types of channels, and only after the channel was closed
#!                              (more exactly, just before the channel is closed).
#!                              Examples: '0' for a successful command, '-1' if the command was not yet terminated (or this
#!                              channel type has no command), '126' if the command cannot execute
#! @output return_code: return code of the command
#!!#
####################################################
namespace: io.cloudslang.git

imports:
  ssh: io.cloudslang.base.remote_command_execution.ssh
  strings: io.cloudslang.base.strings

flow:
  name: git_checkout_branch

  inputs:
    - host
    - port:
        required: false
    - username
    - password:
        required: false
    - git_branch:
        required: true
    - git_repository_localdir: "/tmp/repo.git"
    - git_pull_remote:
        default: "origin"
        required: false
    - sudo_user:
        default: false
        required: false
    - private_key_file:
        required: false

  workflow:
    - git_clone:
        do:
          ssh.ssh_flow:
            - host
            - port
            - sudo_command: ${ 'echo ' + password + ' | sudo -S ' if bool(sudo_user) else '' }
            - git_pull: ${ ' && git pull ' + git_pull_remote + ' ' + git_branch }
            - command: ${ sudo_command + 'cd ' + git_repository_localdir + ' && ' + ' git checkout ' + git_branch + ' ' + git_pull + ' && echo GIT_SUCCESS' }
            - username
            - password
            - private_key_file
        publish:
          - return_result
          - standard_out
          - standard_err
          - exception
          - command_return_code
          - return_code

    - check_result:
        do:
          strings.string_occurrence_counter:
            - string_in_which_to_search: ${ standard_out }
            - string_to_find: "GIT_SUCCESS"

  outputs:
    - return_result
    - standard_out
    - standard_err
    - exception
    - command_return_code
    - return_code
