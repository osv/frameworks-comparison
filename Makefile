PROJECTS = $(sort $(dir $(wildcard ./prj/*/)))
CLEAN_PROJECTS = $(PROJECTS:%=clean-%)
TEST_PROJECTS = $(PROJECTS:%=test-%)
.PHONY: all server $(PROJECTS) $(TEST_PROJECTS) $(CLEAN_PROJECTS) clean clean-server dist-clean help

help:
	@echo "all - build and install to ./dist all projects"
	@echo "dist-clean - clear "

all: server $(PROJECTS)
	@echo "Project distributions are in ./dist"

# build project
$(PROJECTS):
	$(MAKE) -C $@ build

$(CLEAN_PROJECTS):
	-$(MAKE) -C $(@:clean-%=%) clean

test: $(TEST_PROJECTS)

$(TEST_PROJECTS):
	-$(MAKE) -C $(@:test-%=%) test

clean: $(CLEAN_PROJECTS) clean-server

dist-clean:
	rm -rf dist

server:
	$(MAKE) -C server build

clean-server:
	$(MAKE) -C server clean
