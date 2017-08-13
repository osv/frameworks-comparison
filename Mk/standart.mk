# This file can be included to make projects

# Side effects:
# DEPENDENCIES - dependencies for "build" target
# Expect build/ directory

include ../../Mk/vars.mk

.PHONY: build clean dist-clean test
PROJECT=$(shell basename $(CURDIR))
DIST_DIR=../../dist/$(PROJECT)
DIST_SENTINEL = $(DIST_DIR)/.sentinel

build: $(DIST_SENTINEL)
	@echo -n "$(OK_COLOR)-----------------------------------\r"
	@echo "---[ $(PROJECT) ] $(NO_COLOR)"
	@$(BUILD_CMD)

test: $(TEST_DEPENDENCIES)
	@for cmd in $(TEST_COMMANDS); do \
	echo "$(RUNCMD_COLOR)===> $$cmd $(NO_COLOR)" && $$cmd ; \
	done
	@$(BUILD_CMD)

clean: $(CLEAN_DEPENDENCIES)
	rm -rf ./build/
	@$(BUILD_CMD)

SOURCES += 	$(foreach s,$(SOURCE_DIRS),$(shell find $(s) -type f -print))

sources:
	@echo "Source list:"
	@echo $(SOURCES)

$(DIST_SENTINEL): $(DEPENDENCIES) $(SOURCES)
	@for cmd in $(BUILD_COMMANDS); do \
	echo "$(RUNCMD_COLOR)===> $$cmd $(NO_COLOR)" && $$cmd ; \
	done

	mkdir -p $(DIST_DIR)
	cp -r ./build/* $(DIST_DIR)/
	touch $(DIST_SENTINEL)

dist-clean:
	rm -rf $(DIST_DIR)
