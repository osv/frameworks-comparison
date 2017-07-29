# Use it for node js projects
# It manage package.json and add "npm run build" to build commands

include ../../Mk/vars.mk

DEPENDENCIES += node_modules/.sentinel
CLEAN_DEPENDENCIES += clean_node_modules

BUILD_COMMANDS += "npm run build"

SOURCE_DIRS ?= ./src
SOURCES ?= package.json

.PHONY: clean_node_modules

node_modules/.sentinel: package.json
	@echo "$(RUNCMD_COLOR)===> Init npm modules$(NO_COLOR)"
	npm install
	touch node_modules/.sentinel

clean_node_modules:
	rm -rf node_modules/
