# Makefile to run Verilator
BINARY_NAME := func_test
VERILOG_SRC := src/func_test.v
VERILATOR_CMD := verilator
OBJ_DIR := ./obj_dir
VERILATOR_FLAGS := -Isrc --binary -Wno-WIDTHEXPAND

# Build target
build_test: $(VERILOG_SRC)
	$(VERILATOR_CMD) $(VERILATOR_FLAGS) $(VERILOG_SRC)

# Run target
run_test: $(OBJ_DIR)/V$(BINARY_NAME)
	./$(OBJ_DIR)/V$(BINARY_NAME)

all: build_test run_test

.PHONY: build_test run_test
