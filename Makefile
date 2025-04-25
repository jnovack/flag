include variables.mk
include go.mk

.PHONY: update

all: update

update:
	git clone --depth=1 --no-checkout https://github.com/golang/go third_party/go
	git submodule add https://github.com/golang/go/ third_party/go
	git submodule absorbgitdirs
	git -C third_party/go config core.sparseCheckout true
	cp test/sparse-checkout .git/modules/third_party/go/info/sparse-checkout
	git submodule update --force --checkout third_party/go

correct:
	@cp -R third_party/go/src/internal/* internal
ifeq ($(OS), Darwin)
	find internal/* -type f -name "*.go" | xargs -I {} sed -i '' -e "s/\"internal\//\"github.com\/jnovack\/flag\/internal\//g" {}
else
	find internal/* -type f -name "*.go" | xargs -I {} sed -i'' -e "s/\"internal\//\"github.com\/jnovack\/flag\/internal\//g" {}
endif
