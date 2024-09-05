#!/bin/bash

export INSTALL_DOCS=false
export INSTALL_ROS=true
export INSTALL_ARDUINO=false
export INSTALL_WEB=false   # TODO: Currently broken
export INSTALL_PYTHON=false
export INSTALL_JUPYTER=false
export EXPIRE_PASSWD=true
export INSTALL_NETWORK=true
export INSTALL_PROVISIONING=false
export INSTALL_VSCODE=true
export INSTALL_PAM=true
export MIRTE_TYPE="default"
export EXTRA_SCRIPTS=(
	# "testExtra.sh"
	# "testExtra2.sh"
)
export PARALLEL=true
