include ../Mk/vars.mk

.PHONY: clean build

build: node_modules/.sentinel
	@echo -n "$(OK_COLOR)-----------------------------------\r"
	@echo "---[ server ] $(NO_COLOR)"
	@$(BUILD_CMD)

node_modules/.sentinel: package.json
	npm install --only=production --no-progress
	mkdir -p node_modules
	touch node_modules/.sentinel

clean:
	rm -rf node_modules
	@$(BUILD_CMD)
