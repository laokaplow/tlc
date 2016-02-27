###
## make settings
#
.DEFAULT_GOAL = all
.SUFFIXES: # disables most default rules
.SECONDEXPANSION: # allow prereqs to reference targets


###
## compilation settings
#
CXX = clang++
CXXFLAGS = -std=c++14 -Wall -Werror -pedantic $(INCLUDE_DIRS:%,-I%)
DEPFLAGS = -MMD -MP
DEBUGFLAGS = -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls
COMPILE = $(CXX) $(CXXFLAGS) $(DEPFLAGS)  #$(DEBUGFLAGS)


###
## project structure
#
SRCS := $(wildcard src/*.cpp)

INCLUDE_DIRS = src vendor
OUTPUT_DIRS = build bin


###
## rules
#
.PHONY: all program clean

all: program
program: bin/tlc

# build the main executeable
bin/tlc: $(addprefix  build/src/, main.o)
	@mkdir -p $(@D) # ensure output directory exists
	$(COMPILE) $^ -o $@

# build object and dependency files
build/%.o : %.cpp
	@echo building $@ from "<" $^ ">"
	@mkdir -p $(@D) # ensure output directory exists
	$(COMPILE) $< -c -o $@

clean:
	rm -rf $(OUTPUT_DIRS)


###
## auto-dependencies
#
-include $(SRCS:%.cpp=build/%.d)
