# vim: ft=make
# 2023.03.08 - ducet8@outlook.com

AUTH_KEY_4K := "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLHD2wQOu7sV6TXpNMw5GCp5vFwCUH21HnG/gBKeblXIJYocaYk3cdFjAQ9136zPsOba0PqsSvVgY9vS4XfwnM//bGba9l6oL1/p+Zp0BZnBkNZ8+1DAwkBPgD1Vgptd4ZjjExLxDHNMQr7nUj8az/hDu8y0dFHKOBnI0GAG941rLd4TmxvIV2HJXRscCUgCys9Sn/3S2kfHRQ6MQ6tG7D8zufHv8GHYiOQ8arpCxMBrqqr0upM7K3NvUpdcQhveqk69ipnlDKrKFy25vVGqBfHVLnPjCfxB1lD6K1dlQRsSwYKsv0e4z8g4PmSj3ysn8oLLPsQOMGyuFYVXjgW5hhF8TaFbSarnx2obW2+wIZivejU2miWjOcJoNNdLcXLn3Tt02miVM+7nNJOtp0cGnWjjIn72Z7sQxUKhIzXJnciDe1d8XUKlusvvCS0PyBrSecYUOvykabQ56gjaKze0EYILO26ZVDDrPjRLWlgDL5hCIYnCUCTYlrBOuAPpHd3eBtfAfAtlt9Zl30kWW3U2HVIgRX96AT8V0grXSlce8UeJlpUycptSXzZ1V5oMX3aXGbhiPyv6TS2L3xfbfavC1M21JqKmFWCgck1+MiIoTOENZXh7S0jZyy5ldaFYB0PbS8ZxNwB6PFWVWbEv/xPLA1JEPAcYE/q4TIwUgBnn5kSQ=="
AUTH_KEY_ED := "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1tMWGNlG03eoiyS5lmSZXZT8BDOhFy6xUcvDlvtdYv"
AUTH_KEY_4K_M := "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/HpbrHiUvuP38I5zx3YzYOkFpbJ19FCgePilLwAE5crh/2TjdRNJiLtsn7lxWtruJQHkB6uZL3UooCjrCdfuWUjsnnJ7vJuVBMS6ZDki13qrFLkhFMIk19kPMFtIo6kgZsv7KXB0lm0vRHqpwdYZLTkOEkvZqvyiIUhn9UytGpAvD9qdDMnl7ooAHen/9cW7U189otuFVUKYmzCBdgp6VfRAHOWWqCU7oo+2Ba3LVbfHobRTX8mX9A80MHjK38vOF+i8cTDzc0rYBpp9Dt/9glZgAFiqJSa88sBXTHfQfQPnu0hjYKK1NCDXdqEFd8iC1/Dhe+QuhYAd6dLea3KeVBC/i1KCLIohn9XkEWaMi3LNLwBd0ylVTDNZ8br8nJIp4DlEf2GqO3yJO+FynCW5Zsw89N1CFPuDV30MY6noI41VlR5/7idOoyOstJcgrCpkxWg/n0fsMIMEwLvCfXsD9mdlgBg7nIvc5Oc1Fa9YfMQE667LiqWDH1OjUcO2IfiD5g4w6NJzQlsrWccIAGKHFX+uWwztHeWTuBklfB9RNA2VWFFOEYrHog+0EMDg+5zt3y+ofCtLW2Wjl8BipVI3g2//0YIQLQZHx+IpGZZOBGi3scBlcOxmpgbhmODUNU8Le3vv6jBVF4ksRsFRSJEZzNz5hU1fJwHARkr4Ywcokbw=="
AUTH_KEY_ED_M := "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDRITDpnnqtlWpdgmtTIt+372LKcCShjWiJUpgzViRH"
AUTH_KEY_ED_C := "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCeTImcLtzsjuFgmxBaiMQBwn+KR74EUZyc7SQc1a+L"
C_CYAN := \033[36m
C_GREEN := \033[32m
C_MAG := \033[35m
C_RED := \033[31m
C_RESET := \033[0m
DOTFILES := bash_profile inputrc tmux.conf vimrc
HOMEDIR := $(shell echo ~)
LBINFILES := elog pawk rif test-loop
UNLINK_FILES := aliases bash_prompt bash_prompt_dt exports functions


.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
	@for file in $(DOTFILES); do \
	   ln -sfn $(HOMEDIR)/dotfiles/$$file $(HOMEDIR)/.$$file; \
	done
	@echo "$(C_GREEN)Created the following symbolic links:"
	@ls -lA $(HOMEDIR) | awk '/^l/ {print "\t$(C_MAG)" $$(NF-2) "$(C_RESET) -> " $$(NF)}'


.PHONY: duce
duce: dotfiles etc


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


.PHONY: nvim
nvim: # Sets up ~/.config/nvim
# ifeq ($(shell ! type -P neovim &>/dev/null && echo 1 || echo 0), 0)
# 	@mkdir -p $(HOMEDIR)/.config/nvim/lua; \
# 	mkdir -p $(HOMEDIR)/.config/nvim/plugin; \
# 	ln -sfn $(HOMEDIR)/dotfiles/.config/nvim/init.lua $(HOMEDIR)/.config/nvim/init.lua; \
# 	ln -sfn $(HOMEDIR)/dotfiles/.config/nvim/lua/user $(HOMEDIR)/.config/nvim/lua/user; \
# 	echo ; \
# 	echo "$(C_GREEN)Linked $(HOMEDIR)/.config/nvim/init.lua to $(HOMEDIR)/dotfiles/.config/nvim/init.lua"; \
# 	echo "$(C_GREEN)Linked $(HOMEDIR)/.config/nvim/lua/user to $(HOMEDIR)/dotfiles/.config/nvim/lua/user"; \
# 	echo "$(C_CYAN)NOTICE: nvim needs python (pip install pynvim) and possibly node (npm i -g neovim) setup$(C_RESET)"; \
# 	echo
# else ifeq ($(! type -P nvim &>/dev/null && echo 1 || echo 0), 0)
	@mkdir -p $(HOMEDIR)/.config/nvim/lua; \
	mkdir -p $(HOMEDIR)/.config/nvim/plugin; \
	ln -sfn $(HOMEDIR)/dotfiles/.config/nvim/init.lua $(HOMEDIR)/.config/nvim/init.lua; \
	ln -sfn $(HOMEDIR)/dotfiles/.config/nvim/lua/user $(HOMEDIR)/.config/nvim/lua/user; \
	echo ; \
	echo "$(C_GREEN)Linked $(HOMEDIR)/.config/nvim/init.lua to $(HOMEDIR)/dotfiles/.config/nvim/init.lua"; \
	echo "$(C_GREEN)Linked $(HOMEDIR)/.config/nvim/lua/user to $(HOMEDIR)/dotfiles/.config/nvim/lua/user"; \
	echo "$(C_CYAN)NOTICE: nvim needs python (pip install pynvim) and possibly node (npm i -g neovim) setup$(C_RESET)"; \
	echo
# endif


.PHONY: ssh_4k
ssh_4k:  ## Sets up the authorized_keys
	@mkdir -p $(HOMEDIR)/.ssh
	@echo $(AUTH_KEY_4K) >> $(HOMEDIR)/.ssh/authorized_keys
	@sort -u $(HOMEDIR)/.ssh/authorized_keys -o $(HOMEDIR)/.ssh/authorized_keys
	@chmod 700 $(HOMEDIR)/.ssh
	@chmod 600 $(HOMEDIR)/.ssh/authorized_keys
	@echo "$(C_GREEN)Created: $(HOMEDIR)/.ssh/authorized_keys"


.PHONY: ssh_ed
ssh_ed:  ## Sets up the authorized_keys
	@mkdir -p $(HOMEDIR)/.ssh
	@echo $(AUTH_KEY_ED) >> $(HOMEDIR)/.ssh/authorized_keys
	@sort -u $(HOMEDIR)/.ssh/authorized_keys -o $(HOMEDIR)/.ssh/authorized_keys
	@chmod 700 $(HOMEDIR)/.ssh
	@chmod 600 $(HOMEDIR)/.ssh/authorized_keys
	@echo "$(C_GREEN)Created: $(HOMEDIR)/.ssh/authorized_keys"


.PHONY: ssh_4k_m
ssh_4k_m:  ## Sets up the authorized_keys
	@mkdir -p $(HOMEDIR)/.ssh
	@echo $(AUTH_KEY_4K_M) >> $(HOMEDIR)/.ssh/authorized_keys
	@sort -u $(HOMEDIR)/.ssh/authorized_keys -o $(HOMEDIR)/.ssh/authorized_keys
	@chmod 700 $(HOMEDIR)/.ssh
	@chmod 600 $(HOMEDIR)/.ssh/authorized_keys
	@echo "$(C_GREEN)Created: $(HOMEDIR)/.ssh/authorized_keys"


.PHONY: ssh_ed_m
ssh_ed_m:  ## Sets up the authorized_keys
	@mkdir -p $(HOMEDIR)/.ssh
	@echo $(AUTH_KEY_ED_M) >> $(HOMEDIR)/.ssh/authorized_keys
	@sort -u $(HOMEDIR)/.ssh/authorized_keys -o $(HOMEDIR)/.ssh/authorized_keys
	@chmod 700 $(HOMEDIR)/.ssh
	@chmod 600 $(HOMEDIR)/.ssh/authorized_keys
	@echo "$(C_GREEN)Created: $(HOMEDIR)/.ssh/authorized_keys"


.PHONY: ssh_ed_c
ssh_ed_c:  ## Sets up the authorized_keys
	@mkdir -p $(HOMEDIR)/.ssh
	@echo $(AUTH_KEY_ED_C) >> $(HOMEDIR)/.ssh/authorized_keys
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
	@for file in $(UNLINK_FILES); do \
		if [ -L "$(HOMEDIR)/.$$file" ]; then \
			unlink "$(HOMEDIR)/.$$file"; \
			echo "$(C_RED)Removed the following symbolic links:"; \
			echo "    $(C_MAG)$(HOMEDIR)/.$$file"; \
		fi; \
	done
	


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(C_CYAN)%-30s$(C_RESET) %s\n", $$1, $$2}'
