AST_DIR := src/ast/

AST_SRCS += $(wildcard $(AST_DIR)*.cpp)
AST_OBJS := $(AST_SRCS:%.cpp=build/%.o)

CLEAN_LIST += # nothing to add
