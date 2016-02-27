.DEFAULT_GOAL := all
.PHONY := all clean
.SUFFIXES: # leave empty to disable most default rules

SRC_DIR := src/
GEN_DIR := $(SRC_DIR)GENERATED/
OBJ_DIR := $(GEN_DIR)

CXX := clang++
CXXFLAGS := -std=c++14 -Wall -Werror -Wpedantic -O1
#address sanitizer
DEBUGFLAGS := -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls
COMPILE := $(CXX) $(CXXFLAGS) -I$(SRC_DIR) #$(DEBUGFLAGS)

all: bin/tlc

debug: CXXFLAGS += $(DEBUGFLAGS) # add flags for this rule only
debug: all

FLEX_OUTPUT := $(GEN_DIR)scanner.cxx $(GEN_DIR)scanner.hxx
BISON_OUTPUT := $(GEN_DIR)parser.cxx $(GEN_DIR)parser.hxx \
                $(GEN_DIR)position.hh $(GEN_DIR)location.hh $(GEN_DIR)stack.hh
PARSER_INTERMEDIATE := $(GEN_DIR)scanner.o $(GEN_DIR)parser.o

CLEAN_LIST += $(FLEX_OUTPUT) $(BISON_OUTPUT) $(PARSER_INTERMEDIATE)

.INTERMEDIATE: .RUN.flex .RUN.bison
.SECONDARY: $(GEN_DIR) $(FLEX_OUTPUT) $(BISON_OUTPUT) $(PARSER_INTERMEDIATE)

$(GEN_DIR):
	mkdir -p $@

$(FLEX_OUTPUT): .RUN.flex;
.RUN.flex: $(SRC_DIR)scanner.l $(SRC_DIR)scanner.h | $(GEN_DIR)
	flex --outfile="$(GEN_DIR)scanner.cxx" --header-file="$(GEN_DIR)scanner.hxx" $<

$(BISON_OUTPUT): .RUN.bison;
.RUN.bison: $(SRC_DIR)parser.y | $(GEN_DIR)
	bison --output="$(GEN_DIR)parser.cxx" --defines="$(GEN_DIR)parser.hxx" $<

$(PARSER_INTERMEDIATE): %.o: %.cxx $(FLEX_OUTPUT) $(BISON_OUTPUT) $(SRC_DIR)ast.h
	$(COMPILE) -c $< -o $@

# build .o from .cpp, .h
$(GEN_DIR)%.o: $(SRC_DIR)%.cpp $(SRC_DIR)%.h | $(GEN_DIR)
		$(COMPILE) -c $< -o $@


bin:
	@mkdir -p $@

bin/tlc: $(SRC_DIR)main.cpp $(GEN_DIR)ast.o $(PARSER_INTERMEDIATE) | bin
	$(COMPILE) $^ -o $@

clean:
	rm -rf tlc #$(CLEAN_LIST)
	rm -rf $(GEN_DIR)
	rm -rf src/*.o

.PHONY: test
test: tlc
	./tlc <tests/declaration.toyl | jsonpp
