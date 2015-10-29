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

if [ "${#}" -lt 2 ]; then
	echo "Usage: $(basename ${0}) <script> {usage|description|run} args..."
	exit 1
fi

function main() {
	local cmd=$(basename ${1})
	local prefix=${cmd/-*/}
	local ucprefix=$(echo ${prefix} | tr '[a-z]' '[A-Z]')
	local scripts_root=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)
	eval $(echo "export ${ucprefix}_SCRIPTS_PATH=\"\${${ucprefix}_SCRIPTS_PATH}:\${scripts_root}/scripts\"")

	if [ -f ${HOME}/.${prefix}config ]; then
		source ${HOME}/.${prefix}config
	fi
	unset cmd ucprefix prefix

	source ${scripts_root}/funcs.sh
	source ${1}

	case "${2}" in
	        description)
	            short_description
	            ;;
	        usage)
				local cmd=$(basename ${1})
				local prefix=${cmd/-*/}
				cmd=${cmd#${prefix}-}
				cmd="${prefix} ${cmd%.*}"
				unset prefix
	            usage
				unset cmd
	            ;;
	        run)
				eval "${3}"
	            main "${4}"
	            ;;
	        *)
				echo "Usage: $(basename ${0}) <script> {usage|description|run} args..."
	            exit 1
	esac
}

main "${@}"
