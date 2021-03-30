C_CYAN := \033[36m
C_GREEN := \033[32m
C_MAG := \033[35m
C_RESET := \033[0m
HOMEDIR := $(shell echo ~)


.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
	@for file in aliases bash_profile bash_prompt exports functions inputrc path tmux.conf vimrc; do \
	   ln -sfn $(HOMEDIR)/dotfiles/$$file $(HOMEDIR)/.$$file; \
	done
	@echo "$(C_GREEN)Created the following symbolic links:"
	@ls -lA $(HOMEDIR) | awk '/^l/ {print "\t$(C_MAG)" $$(NF-2) "$(C_RESET) -> " $$(NF)}'


.PHONY: test
test: ## Runs all the tests.
ifeq ($(shell [ -t 0 ] && echo 1 || echo 0), 1)	
# Required variables can be set here
	@echo "Session is interactive"
endif
	@echo $(HOMEDIR)


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(C_CYAN)%-30s$(C_RESET) %s\n", $$1, $$2}'
