/* Copyright 2015 Google Inc. All Rights Reserved.
 * Kevin Klues <klueska@google.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

var AppHelpTemplate =
`{{.Usage}}

Usage:
   {{.Name}} {{if .Flags}}[options]{{end}}{{if .Commands}} command [command options]{{end}} [arguments...]
{{if .Commands}}
Commands:
   {{range .Commands}}{{join .Names ", "}}{{ "\t" }}{{.Description}}
   {{end}}{{end}}{{if .Flags}}
Options:
   {{range .Flags}}{{.}}
   {{end}}{{end}}
`

var CommandHelpTemplate =
`{{.Description}}

{{.Usage}}
`

type Script struct {
	Name string
	Path string
}
type Scripts []Script

func (slice Scripts) Len() int {
    return len(slice)
}

func (slice Scripts) Less(i, j int) bool {
    return slice[i].Name < slice[j].Name;
}

func (slice Scripts) Swap(i, j int) {
    slice[i], slice[j] = slice[j], slice[i]
}
