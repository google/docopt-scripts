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

import (
	"bytes"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"fmt"
	"github.com/codegangsta/cli"
	"github.com/kardianos/osext"
	"github.com/docopt/docopt-go"
)

var APP_NAME string
var RUN_SCRIPT string = "run-script.sh"
var SCRIPT_PATH_SCRIPT string = "scripts/"+APP_NAME+"-print-scripts-path.sh"

func init() {
	exec_folder, _ := osext.ExecutableFolder()
	SCRIPT_PATH_SCRIPT = filepath.Join(exec_folder, SCRIPT_PATH_SCRIPT)
	RUN_SCRIPT = filepath.Join(exec_folder, RUN_SCRIPT)
	cli.CommandHelpTemplate = CommandHelpTemplate
	cli.AppHelpTemplate = AppHelpTemplate
	if len(os.Args) >= 2 {
		prepended := append([]string{"--"}, os.Args[2:]...)
		os.Args = append(os.Args[0:2], prepended...)
	}
}

func main() {
	app := cli.NewApp()
	app.EnableBashCompletion = true
	app.Name = APP_NAME
	app.Version = ""
	app.Usage = "Run a set of '"+APP_NAME+"' related scripts from a single command"
	app.Commands = addScripts(app)
	app.Run(os.Args)
}

func addScripts(app *cli.App) []cli.Command {
	cmds := []cli.Command{}
	dirs := parseScriptsPath(RunScriptSubCmd(SCRIPT_PATH_SCRIPT, "run"))
	scripts := getSortedScriptPaths(dirs)
	for _, s := range scripts {
		cmds = append(cmds, addOneScript(app, s.Path, s.Name))
	}
	return cmds
}

func getSortedScriptPaths(dirs []string) (Scripts) {
	scripts := Scripts{}
	for _, d := range dirs {
		files, _ := ioutil.ReadDir(d)
		for _, f := range files {
			s := filepath.Base(f.Name())
			if s[:len(APP_NAME) + 1] == APP_NAME + "-" &&
			   s[len(s) - 3:] == ".sh" {
				scripts = append(scripts, Script{s, d})
			}
		}
	}
	sort.Sort(scripts)
	return scripts
}

func addOneScript(app *cli.App, dir, script string) cli.Command {
	abspath, _ := filepath.Abs(filepath.Join(dir, script))
	name := script[len(APP_NAME) + 1:len(script)-len(filepath.Ext(script))]
	desc := fmtDescription(RunScriptSubCmd(abspath, "description"))
	usage := fmtUsage(RunScriptSubCmd(abspath, "usage"))

	return cli.Command{
		Name: name,
		Description: desc,
		Usage: usage,
		Action: func(c *cli.Context) {
			if InterceptBashAutocomplete() {
				args, _ := parseArgs(usage, name, os.Args[3:])
				for k := range args {
					if k[0] != '<' {
						fmt.Println(k)
					}
				}
				return
			}
			if InterceptHelp() {
				cli.ShowCommandHelp(c, name)
				return
			}
			args, err := parseArgs(usage, name, os.Args[3:])
			if _, ok := err.(*docopt.UserError); ok {
				fmt.Printf("Error: Illegal option, wrong argument, or missing argument\n\n")
				cli.ShowCommandHelp(c, name)
			} else if err != nil {
				fmt.Printf("Error: %s %s\n", APP_NAME, name)
				fmt.Printf("    %T\n", err)
				fmt.Printf("    %v\n", err)
			} else {
				err = RunScriptMain(abspath, args)
				if err != nil {
					fmt.Printf("\n")
					cli.ShowCommandHelp(c, name)
				}
			}
		},
	}
}

func InterceptHelp() bool {
	for _, b := range os.Args {
		if b == "--help" || b == "-h" {
			return true
		}
	}
	return false
}

func InterceptBashAutocomplete() bool {
	for i, b := range os.Args {
		if b == "--generate-bash-completion" {
			os.Args = append(os.Args[:i], os.Args[i+1:]...)
			return true
		}
	}
	return false
}

func RunScriptSubCmd(script, subcmd string) (output string) {
	r, w, _ := os.Pipe()
	cmd := exec.Command("/bin/bash", RUN_SCRIPT, script, subcmd)
	cmd.Stdout = w
	cmd.Stderr = w
	cmd.Run()

    outC := make(chan string)
    go func() {
        var buf bytes.Buffer
        io.Copy(&buf, r)
        outC <- buf.String()
		r.Close()
    }()
    w.Close()
    out := <-outC
	return out
}

func RunScriptMain(script string, args map[string]interface{}) error {
	cmdArgs := TranslateCmdArgsForBash(args)
	origArgs := strings.Join(os.Args[3:], " ")
	bashArgs := []string{RUN_SCRIPT, script, "run", cmdArgs, origArgs}
	cmd := exec.Command("/bin/bash", bashArgs...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func parseArgs(usage, name string, args []string) (val map[string]interface{}, err error) {
	stdout := os.Stdout
	os.Stdout = nil
	cmdUsage := strings.Replace(usage, APP_NAME+" "+name, APP_NAME+"-"+name, -1)
    val, err = docopt.Parse(cmdUsage, args, false, "", false, false)
	os.Stdout = stdout
	return
}

func TranslateCmdArgsForBash(args map[string]interface{}) string {
	str := ""
	for k, v := range args {
		k = strings.Replace(strings.TrimPrefix(k, "--"), "-", "_", -1)
		k = strings.Replace(k, "<", "", -1)
		k = strings.Replace(k, ">", "", -1)
		if v == nil {
			v = ""
		}
		str += fmt.Sprintf("local %v=%v;", k, v)
	}
	return str
}

func parseScriptsPath(path string) []string {
	array := strings.Split(path, ":")
	for i, s := range array {
		array[i] = strings.TrimSpace(s)
	}
	return array
}

func fmtUsage(usage string) string {
	return strings.TrimSpace(usage)
}

func fmtDescription(desc string) string {
	return strings.TrimSpace(desc)
}
