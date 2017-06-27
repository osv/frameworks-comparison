# Use it for node js projects
# It manage package.json and add "npm run build" to build commands

DEPENDENCIES += node_modules/.sentinel
CLEAN_DEPENDENCIES += clean_node_modules

BUILD_COMMANDS += "npm run build"

SOURCE_DIRS ?= ./src

.PHONY: clean_node_modules

node_modules/.sentinel: package.json
	@echo "==> Init npm modules"
	npm install
	touch node_modules/.sentinel

clean_node_modules:
	rm -rf node_modules/
