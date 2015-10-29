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

function short_description() {
	echo "Print the PATH of all dirs we search for scripts"
}

function usage() {
	echo "Usage: ${cmd}"
}

function main() {
	local prefix="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
	prefix=${prefix/-*/}
	prefix=$(echo ${prefix} | tr '[a-z]' '[A-Z]')
	eval "echo \"\${${prefix}_SCRIPTS_PATH}\""
}
