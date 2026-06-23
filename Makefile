SHELL := /bin/bash

.PHONY: get codegen run dev build prepare test analyze format check clean logs stop status

RUN_DIR := .run
APP_NAME := persona_flutter
APP_PATH := build/macos/Build/Products/Debug/$(APP_NAME).app
APP_BIN := $(APP_PATH)/Contents/MacOS/$(APP_NAME)
PID_FILE := $(RUN_DIR)/app.pid
RUN_LOG := $(RUN_DIR)/run.log

get:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; flutter pub get 2>&1 | tee "$(RUN_DIR)/get.log"

codegen:
	@mkdir -p "$(RUN_DIR)"
	@set -o pipefail; dart run build_runner build --delete-conflicting-outputs 2>&1 | tee "$(RUN_DIR)/codegen.log"

run:
	@mkdir -p "$(RUN_DIR)"
	@echo "检查应用状态..."
	@if pgrep -x "$(APP_NAME)" >/dev/null 2>&1; then \
		echo "应用已在运行，跳过启动"; \
	else \
		if [ ! -x "$(APP_BIN)" ]; then \
			echo "应用未构建，正在构建..."; \
			$(MAKE) build; \
		fi; \
		echo "应用未运行，正在后台启动..."; \
		: >"$(RUN_LOG)"; \
		nohup "$(APP_BIN)" >"$(RUN_LOG)" 2>&1 & \
		echo $$! >"$(PID_FILE)"; \
		for i in $$(seq 1 10); do \
			if pgrep -x "$(APP_NAME)" >/dev/null 2>&1; then break; fi; \
			sleep 1; \
		done; \
		if pgrep -x "$(APP_NAME)" >/dev/null 2>&1; then \
			echo "应用启动完成，日志: $(RUN_LOG)"; \
		else \
			echo "应用启动失败，请检查日志: $(RUN_LOG)"; \
			exit 1; \
		fi; \
	fi

dev:
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

stop:
	@stopped=0; \
	if [ -f "$(PID_FILE)" ]; then \
		pid=$$(cat "$(PID_FILE)"); \
		if kill "$$pid" >/dev/null 2>&1; then \
			echo "已停止应用 (PID $$pid)"; \
			stopped=1; \
		fi; \
		rm -f "$(PID_FILE)"; \
	fi; \
	if pgrep -x "$(APP_NAME)" >/dev/null 2>&1; then \
		pkill -x "$(APP_NAME)"; \
		echo "已停止应用"; \
		stopped=1; \
	fi; \
	if [ "$$stopped" -eq 0 ]; then \
		echo "应用未运行"; \
	fi

status:
	@echo "== 应用状态 =="
	@if pgrep -x "$(APP_NAME)" >/dev/null 2>&1; then \
		echo "应用: running (PID $$(pgrep -x '$(APP_NAME)' | tr '\n' ' '))"; \
	else \
		echo "应用: stopped"; \
	fi
	@echo "运行日志: $(RUN_LOG)"
	@if [ -f "$(PID_FILE)" ]; then \
		echo "PID 文件: $(PID_FILE) ($$(cat '$(PID_FILE)'))"; \
	fi

logs:
	@mkdir -p "$(RUN_DIR)"
	@echo "依赖日志: $(RUN_DIR)/get.log"
	@echo "代码生成日志: $(RUN_DIR)/codegen.log"
	@echo "运行日志: $(RUN_LOG) (make run 后台 / make dev 前台)"
	@echo "PID 文件: $(PID_FILE)"
	@echo "测试日志: $(RUN_DIR)/test.log"
	@echo "静态分析日志: $(RUN_DIR)/analyze.log"
	@echo "格式化日志: $(RUN_DIR)/format.log"
	@echo "清理日志: $(RUN_DIR)/clean.log"
