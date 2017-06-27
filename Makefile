PROJECTS = $(sort $(dir $(wildcard ./projects/*/)))
CLEAN_PROJECTS = $(PROJECTS:%=clean-%)
.PHONY: all $(PROJECTS) clean dist-clean help

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

clean: $(CLEAN_PROJECTS)

dist-clean:
	rm -rf dist
