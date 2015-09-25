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

SRCDIR=$(PWD)/src
SCRIPTSDIR=$(PWD)/scripts
THIRDPARTYCLIDIR=$(PWD)/third_party/github.com/codegangsta/cli
BINDIR=$(PWD)/bin
SRCS=main.go util.go
EXEC?=ak

MAKEFLAGS += -rR --no-print-directory

usage:
	@echo "Usage: make <subcmd>"
	@echo "    Valid subcommands are: 'install', 'clean'"
	@echo "    You can set the value of EXEC to change the name of the resulting binary"
	@echo ""
	@echo "Subcommands:"
	@echo "    install  Install all programs packaged with this distribution"
	@echo "             into:  $(BINDIR)"
	@echo "    clean    Remove all programs packaged with this distribution"
	@echo "             from:  $(BINDIR)"

print-install-success:
	@echo "    Your '$(EXEC)' specific installation of 'docopt-scripts' is ready!"
	@echo "    Don't forget to set your PATH before using '$(EXEC)'."
	@echo "    You'll likely want to add the following to your ~/.bashrc file:"
	@echo ""
	@echo "        export PATH=\"$(BINDIR):\$$PATH\""
	@echo ""
	@echo "    To enable bash completion, copy the 'bin/bash_autocomplete' file"
	@echo "    into '/etc/bash_completion.d', renaming it to '$(EXEC)' and sourcing"
	@echo "    it as follows:"
	@echo ""
	@echo "        sudo cp bin/bash_autocomplete /etc/bash_completion.d/$(EXEC)"
	@echo "        source /etc/bash_completion.d/$(EXEC)"
	@echo ""
	@echo "    For convenience, you can create a .$(EXEC)config file in your \$$HOME"
	@echo "    directory with any bash configuration you want to make available"
	@echo "    to '$(EXEC)' while executing. This includes environment variables,"
	@echo "    helper functions, etc. For example, you can update the value of"
	@echo "    \$$SCRIPTS_PATH in this file to update the list of directories"
	@echo "    where your '$(EXEC)' specific 'docopt-scripts' are located. You"
	@echo "    can append to it as desired. See the README for more info."

pass-checks: check-goenv

check-goenv:
	@eval $(go env); \
	errstr="You must build natively, i.e. GOOS == GOHOSTOS and GOARCH == GOHOSTARCH"; \
	if [ "$${GOOS}" = "" ] && [ "$${GOARCH}" = "" ]; then \
		true; \
	else \
		if [ "$${GOOS}" != "$${GOHOSTOS}" ] || \
		   [ "$${GOARCH}" != "$${GOHOSTARCH}" ]; then \
			echo $${errstr}; \
			exit 1; \
		fi; \
	fi

go-get: pass-checks
	@go get -u github.com/codegangsta/cli
	@go get -u github.com/kardianos/osext
	@go get -u github.com/docopt/docopt-go

install-scripts: pass-checks
	@mkdir -p $(BINDIR)
	@mkdir -p $(BINDIR)/scripts
	@cp $(THIRDPARTYCLIDIR)/bash_autocomplete $(BINDIR)
	@cp $(SRCDIR)/*.sh $(BINDIR)
	@cd $(SCRIPTSDIR); \
	for i in $$(ls *.sh); do \
		cp $$i $(BINDIR)/scripts/$(EXEC)-$$i; \
	done

install: go-get install-scripts
	@CURRDIR=$$PWD; \
	cd $(SRCDIR); \
	go build -o $(BINDIR)/$(EXEC) -ldflags "-X main.APP_NAME=$(EXEC)" $(SRCS); \
	RET=$$?; \
	cd - > /dev/null; \
	if [ "$$RET" == "0" ]; then \
		$(MAKE) print-install-success; \
	fi;

clean:
	rm -rf $(BINDIR)/*
