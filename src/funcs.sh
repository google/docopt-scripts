#!/usr/bin/env bash
#
# Copyright 2015 Google Inc. All Rights Reserved.
# Kevin Klues <klueska@google.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function check_cond() {
	local cond="$1"
	local errstr="$2"
	local errors=""
	for var in "${@:3}"; do
		eval "
		if [ ${cond} ]; then
			if [ \"\${errors}\" == \"\" ]; then
				errors=\"${errstr}\"
			else
				errors=\"\${errors}\n${errstr}\"
			fi
		fi
		"
	done
	if [ "${errors}" != "" ]; then
		echo -e "${errors}\n"
		exit 1
	fi
}

function check_vars() {
	local cond="\"\${!var}\" == \"\""
	local errstr="Error: \${var} not set"
	check_cond "${cond}" "${errstr}" ${@}
}

check_dirs() {
	local cond="! -d \"\${!var}\""
	local errstr="Error: \${var} \\\"\${!var}\\\" does not exist as a directory"
	check_cond "${cond}" "${errstr}" ${@}
}

check_files() {
	local cond="! -f \"\${!var}\""
	local errstr="Error: \${var} \\\"\${!var}\\\" does not exist as a file"
	check_cond "${cond}" "${errstr}" ${@}
}

check_execs() {
	local cond="\"\$(which \${!var} 2>/dev/null)\" == \"\""
	local errstr="Error: \${!var} not in PATH"
	check_cond "${cond}" "${errstr}" ${@}
}

#function build_cmd_line_vars() {
#	echo "for i in \"\${@}\"; do"
#	echo "case \$i in"
#
#	for i in "${@}"; do
#		local var=${i%=*}
#		local flag="${var//_/-}"
#		if [ "${i#${var}}" != "" ]; then
#			echo "    --${flag}=*)"
#	    	echo "        ${var}=\"x\${i#*=}\""
#		else
#			echo "    --${flag})"
#	    	echo "        ${var}=\"xtrue\""
#		fi
#		echo "        shift;"
#	    echo "        ;;"
#	done
#	echo "    -h|--help)"
#	echo "        usage"
#	echo "        exit 1"
#	echo "        ;;"
#	echo "    *)"
#	echo "        echo \"Unknown option: \${i}\""
#	echo "        usage"
#	echo "        exit 1"
#	echo "        ;;"
#	echo "esac"
#	echo "done"
#
#	for i in "${@}"; do
#		local var=${i%=*}
#		local val=${i#*=}
#		echo ": \${${var}:=x${val}}"
#		echo "${var}=\${${var}#x}"
#	done
#}
#
#scriptcmd=${_}
#if [ "${SCRIPTS_ROOT}" == "" ]; then
#	akpath=$(which ak 2>/dev/null)
#	if [ "${akpath}" == "" ]; then
#		echo "Error:"
#		echo "    This script requires a valid 'ak-scripts' installation"
#		echo "    Download it from http://github.com/klueska/ak-scripts"
#		exit 1
#	else
#		SCRIPTS_ROOT=$(dirname ${akpath})
#	fi
#	unset akpath
#fi
#source ${SCRIPTS_ROOT}/env.sh
#export SCRIPTS_ROOT
#
## If we are invoked directly (i.e. not sourced), then execute main
#if [ "${scriptcmd}" == "${0}" ]; then
#	main ${@}
#fi
