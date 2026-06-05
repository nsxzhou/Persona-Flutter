SHELL := /bin/bash

.PHONY: get codegen run build prepare test analyze format check clean logs

RUN_DIR := .run

get:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter pub get 2>&1 | tee "$(RUN_DIR)/get.log"

codegen:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; dart run build_runner build --delete-conflicting-outputs 2>&1 | tee "$(RUN_DIR)/codegen.log"

run:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter run -d macos 2>&1 | tee "$(RUN_DIR)/run.log"

build:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter build macos --debug 2>&1 | tee "$(RUN_DIR)/build.log"
	@scripts/prepare_macos.sh debug

prepare:
	@scripts/prepare_macos.sh $(or $(MODE),debug)

test:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter test 2>&1 | tee "$(RUN_DIR)/test.log"

analyze:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter analyze 2>&1 | tee "$(RUN_DIR)/analyze.log"

format:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; dart format . 2>&1 | tee "$(RUN_DIR)/format.log"

check: format analyze test

clean:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter clean 2>&1 | tee "$(RUN_DIR)/clean.log"

logs:
	@mkdir -p "$(RUN_DIR)"
	@echo "依赖日志: $(RUN_DIR)/get.log"
	@echo "代码生成日志: $(RUN_DIR)/codegen.log"
	@echo "运行日志: $(RUN_DIR)/run.log"
	@echo "测试日志: $(RUN_DIR)/test.log"
	@echo "静态分析日志: $(RUN_DIR)/analyze.log"
	@echo "格式化日志: $(RUN_DIR)/format.log"
	@echo "清理日志: $(RUN_DIR)/clean.log"
