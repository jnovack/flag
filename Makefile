include variables.mk
include go.mk

.PHONY: update clean correct test

all: update

clean:
	git restore --staged third_party/go || true
	rm -rf third_party/go internal/** flag_test.go .git/modules/third_party .gitmodules
	mkdir -p internal

update: clean
	git clone --depth=1 --no-checkout https://github.com/golang/go third_party/go
	git submodule add -f https://github.com/golang/go/ third_party/go
	git submodule absorbgitdirs
	git -C third_party/go config core.sparseCheckout true
	cp test/sparse-checkout .git/modules/third_party/go/info/sparse-checkout
	git submodule update --force --checkout third_party/go
	cp third_party/go/src/flag/flag_test.go .

correct:
	@cp -R third_party/go/src/internal/* internal
ifeq ($(shell uname -s), Darwin)
	find internal/* -type f -name "*.go" | xargs -I {} sed -i '' -e "s/\"internal\//\"github.com\/jnovack\/flag\/internal\//g" {}
	sed -i '' -e "s/\"internal\//\"github.com\/jnovack\/flag\/internal\//g" flag_test.go
	sed -i '' -e "s/\. \"flag\"/. \"github.com\/jnovack\/flag\"/g" flag_test.go
else
	find internal/* -type f -name "*.go" | xargs -I {} sed -i'' -e "s/\"internal\//\"github.com\/jnovack\/flag\/internal\//g" {}
	sed -i'' -e "s/\"internal\//\"github.com\/jnovack\/flag\/internal\//g" flag_test.go
	sed -i'' -e "s/\. \"flag\"/. \"github.com\/jnovack\/flag\"/g" flag_test.go
endif

test:
	go test -v