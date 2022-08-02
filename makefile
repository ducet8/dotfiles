AUTH_KEY := "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLHD2wQOu7sV6TXpNMw5GCp5vFwCUH21HnG/gBKeblXIJYocaYk3cdFjAQ9136zPsOba0PqsSvVgY9vS4XfwnM//bGba9l6oL1/p+Zp0BZnBkNZ8+1DAwkBPgD1Vgptd4ZjjExLxDHNMQr7nUj8az/hDu8y0dFHKOBnI0GAG941rLd4TmxvIV2HJXRscCUgCys9Sn/3S2kfHRQ6MQ6tG7D8zufHv8GHYiOQ8arpCxMBrqqr0upM7K3NvUpdcQhveqk69ipnlDKrKFy25vVGqBfHVLnPjCfxB1lD6K1dlQRsSwYKsv0e4z8g4PmSj3ysn8oLLPsQOMGyuFYVXjgW5hhF8TaFbSarnx2obW2+wIZivejU2miWjOcJoNNdLcXLn3Tt02miVM+7nNJOtp0cGnWjjIn72Z7sQxUKhIzXJnciDe1d8XUKlusvvCS0PyBrSecYUOvykabQ56gjaKze0EYILO26ZVDDrPjRLWlgDL5hCIYnCUCTYlrBOuAPpHd3eBtfAfAtlt9Zl30kWW3U2HVIgRX96AT8V0grXSlce8UeJlpUycptSXzZ1V5oMX3aXGbhiPyv6TS2L3xfbfavC1M21JqKmFWCgck1+MiIoTOENZXh7S0jZyy5ldaFYB0PbS8ZxNwB6PFWVWbEv/xPLA1JEPAcYE/q4TIwUgBnn5kSQ== duce@tatemac1.local"
C_CYAN := \033[36m
C_GREEN := \033[32m
C_MAG := \033[35m
C_RED := \033[31m
C_RESET := \033[0m
DOTFILES := aliases bash_profile bash_prompt bash_prompt_dt exports functions inputrc tmux.conf vimrc
HOMEDIR := $(shell echo ~)
LBINFILES := elog pawk rif test-loop


.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
	@for file in $(DOTFILES); do \
	   ln -sfn $(HOMEDIR)/dotfiles/$$file $(HOMEDIR)/.$$file; \
	done
	@echo "$(C_GREEN)Created the following symbolic links:"
	@ls -lA $(HOMEDIR) | awk '/^l/ {print "\t$(C_MAG)" $$(NF-2) "$(C_RESET) -> " $$(NF)}'


.PHONY: duce
duce: dotfiles etc ssh


.PHONY: etc
etc: # Sets up ~/etc
	@if [ ! -d "$(HOMEDIR)/etc" ] && [ ! -L "$(HOMEDIR)/etc" ]; then \
		ln -sfn $(HOMEDIR)/dotfiles/etc $(HOMEDIR)/etc; \
		echo "$(C_GREEN)Linked $(HOMEDIR)/etc to $(HOMEDIR)/dotfiles/etc"; \
	fi


.PHONY: local
local: # Sets up ~/local
	@mkdir -p $(HOMEDIR)/local/bin
	@for file in $(LBINFILES); do \
		ln -sfn $(HOMEDIR)/dotfiles/local/bin/$$file $(HOMEDIR)/local/bin/$$file; \
	done
	@echo "$(C_GREEN)Created the following symbolic links:"
	@ls -lA $(HOMEDIR)/local/bin | awk '/^l/ {print "\t$(C_MAG)" $$(NF-2) "$(C_RESET) -> " $$(NF)}'


.PHONY: ssh
ssh:  ## Sets up the authorized_keys
	@mkdir -p $(HOMEDIR)/.ssh
	@echo $(AUTH_KEY) >> $(HOMEDIR)/.ssh/authorized_keys
	@sort -u $(HOMEDIR)/.ssh/authorized_keys -o $(HOMEDIR)/.ssh/authorized_keys
	@chmod 700 $(HOMEDIR)/.ssh
	@chmod 600 $(HOMEDIR)/.ssh/authorized_keys
	@echo "$(C_GREEN)Created: $(HOMEDIR)/.ssh/authorized_keys"


.PHONY: test
test:  ## Runs all the tests.
ifeq ($(shell [ -t 0 ] && echo 1 || echo 0), 1)
# Required variables can be set here
	@echo "Session is interactive"
endif
	@echo $(HOMEDIR)


.PHONY: update
update:  ## Cleans up and redoes the current required setup
	@if [ -d "$(HOMEDIR)/local" ] && [ ! -L "$(HOMEDIR)/local" ]; then \
		for file in $$(find $(HOMEDIR)/local/bin -type l); do \
			ls -l $$file | awk '{print $$(NF)}' | grep -i dotfiles >>/dev/null; \
		if [ "$$?" -eq 0 ]; then \
				unlink $$file; \
				echo "$(C_RED)Unlinked: $$file$(C_RESET)"; \
			fi; \
		done; \
	fi


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(C_CYAN)%-30s$(C_RESET) %s\n", $$1, $$2}'
