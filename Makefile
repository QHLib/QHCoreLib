.PHONY: lint, release

lint:
	pod lib lint --verbose --sources="https://github.com/CocoaPods/Specs.git,https://github.com/QHLib/QHLibSpecs.git"

release:
	pod repo push qhlib --verbose
