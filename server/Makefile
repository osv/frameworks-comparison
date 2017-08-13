.PHONY: clean build

build: node_modules/.sentinel

node_modules/.sentinel: package.json
	npm install --only=production --no-progress
	mkdir -p node_modules
	touch node_modules/.sentinel

clean:
	rm -rf node_modules
