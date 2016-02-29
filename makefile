###
## make settings
#

# don't worry about ordering of rules
.DEFAULT_GOAL = all
# disable (most) default rules
.SUFFIXES:
# allow prereqs to reference targets
.SECONDEXPANSION:


###
## compilation settings
#
CXX = clang++
DEPFLAGS = -MMD -MP
CXXFLAGS = -std=c++14 -Wall -Werror -pedantic $(INCLUDE_DIRS:%=-I%)
DEBUGFLAGS = -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls
COMPILE = $(CXX) $(CXXFLAGS) #$(DEBUGFLAGS)


###
## build vars
#
SRCS := $(wildcard src/*.cpp)
INCLUDE_DIRS = src vendor
OUTPUT_DIRS = build bin
CLEAN_LIST = $(OUTPUT_DIRS)

TARGET := bin/tlc


###
## Rules
#
.PHONY: all program test clean example

all: program

program: $(TARGET)

clean:
	rm -rf $(CLEAN_LIST)

# include subcomponents
COMPONENTS = parse
include $(COMPONENTS:%=src/%/subdir.mk)

# build the main executeable
$(TARGET): $(addprefix  build/src/, main.o) $(AST_OBJS) $(PARSE_OBJS)
	@mkdir -p $(@D) # ensure output directory exists
	$(COMPILE) -o $@ $^

example: $(TARGET)
		$(TARGET) < tests/declaration.toyl | jsonpp


###
## auto-dependencies
#

# build object and dependency files
build/%.o : %.cpp build/%.d
	@#echo ">>" building $@ from $^
	@mkdir -p $(@D) # ensure output directory exists
	$(COMPILE) $(DEPFLAGS) -c -o $@ $<

# dependency files are created alongside object files
build/%.d: ;
.PRECIOUS: build/%.d # don't delete dependency files

# must include these last
-include $(SRCS:%.cpp=build/%.d)
