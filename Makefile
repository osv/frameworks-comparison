PROJECTS = $(sort $(dir $(wildcard ./prj/*/)))
CLEAN_PROJECTS = $(PROJECTS:%=clean-%)
TEST_PROJECTS = $(PROJECTS:%=test-%)
.PHONY: all $(PROJECTS) $(TEST_PROJECTS) $(CLEAN_PROJECTS) clean dist-clean help

help:
	@echo "all - build and install to ./dist all projects"
	@echo "dist-clean - clear "

all: $(PROJECTS)
	@echo "Project distributions are in ./dist"

# build project
$(PROJECTS):
	$(MAKE) -C $@ build

$(CLEAN_PROJECTS):
	-$(MAKE) -C $(@:clean-%=%) clean

test: $(TEST_PROJECTS)

$(TEST_PROJECTS):
	-$(MAKE) -C $(@:test-%=%) test

clean: $(CLEAN_PROJECTS)

dist-clean:
	rm -rf dist
