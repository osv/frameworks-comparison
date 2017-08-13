# Use it for node js projects
# It manage package.json and add "npm run build" to build commands

include ../../Mk/vars.mk

DEPENDENCIES += node_modules/.sentinel
TEST_DEPENDENCIES += node_modules/.dev-sentinel
CLEAN_DEPENDENCIES += clean_node_modules

BUILD_COMMANDS += "npm run build"
TEST_COMMANDS += "npm test"

SOURCE_DIRS ?= ./src
SOURCES ?= package.json

.PHONY: clean_node_modules

node_modules/.sentinel: package.json
	@echo "$(RUNCMD_COLOR)===> Init production npm modules$(NO_COLOR)"
	npm install --only=production --no-progress
	mkdir -p node_modules
	touch node_modules/.sentinel

node_modules/.dev-sentinel: package.json
	@echo "$(RUNCMD_COLOR)===> Init dev npm modules$(NO_COLOR)"
	npm install --no-progress
	mkdir -p node_modules
	touch node_modules/.dev-sentinel

clean_node_modules:
	rm -rf node_modules/
