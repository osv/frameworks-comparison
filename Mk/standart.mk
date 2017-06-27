# This file can be included to make projects

# Side effects:
# DEPENDENCIES - dependencies for "build" target 
# Expect build/ directory

.PHONY: build clean dist-clean
PROJECT=$(shell basename $(CURDIR))
DIST_DIR=../../dist/$(PROJECT)
DIST_SENTINEL = $(DIST_DIR)/.sentinel

build: $(DIST_SENTINEL)

clean: $(CLEAN_DEPENDENCIES)

SOURCES += 	$(foreach s,$(SOURCE_DIRS),$(shell find $(s) -type f -print))

sources:
	@echo $(SOURCES)

$(DIST_SENTINEL): $(DEPENDENCIES) $(SOURCES)
	@for cmd in $(BUILD_COMMANDS); do \
	echo "===> $$cmd" && $$cmd ; \
	done

	mkdir -p $(DIST_DIR)
	cp -rv ./build/* $(DIST_DIR)/
	touch $(DIST_SENTINEL)


dist-clean:
	rm -rf $(DIST_DIR)
