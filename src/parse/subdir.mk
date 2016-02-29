PARSE_DIR := src/parse/
GEN_DIR = $(PARSE_DIR)GENERATED/

PARSE_SRCS = $(wildcard $(PARSE_DIR)*.cpp)
PARSE_OBJS = $(addprefix build/,  $(PARSE_SRCS:%.cpp=%.o) $(addprefix $(GEN_DIR), parser.o scanner.o))

DEP_FILES  += $(PARSE_OBJS:%.o=%.d)
CLEAN_LIST += $(GEN_DIR)

FLEX_OUTPUT := $(addprefix $(GEN_DIR), scanner.cxx scanner.hxx)
BISON_OUTPUT := $(addprefix $(GEN_DIR), parser.cxx parser.hxx position.hh location.hh stack.hh)

###
## rules
#

$(GEN_DIR):
	@mkdir -p $@

# must manually specify dependencies on generated headers
build/$(PARSE_DIR)parse.o: $(addprefix $(GEN_DIR), scanner.hxx parser.hxx)

# some object files are built from generated sources
build/%.o: %.cxx build/%.d
		@mkdir -p $(@D)
		$(COMPILE) $(DEPFLAGS) -c -o $@ $<

.INTERMEDIATE: .RUN.flex .RUN.bison

$(FLEX_OUTPUT): .RUN.flex;
.RUN.flex: $(PARSE_DIR)scanner.l | $(GEN_DIR)
	flex --outfile="$(GEN_DIR)scanner.cxx" --header-file="$(GEN_DIR)scanner.hxx" $<

$(BISON_OUTPUT): .RUN.bison;
.RUN.bison: $(PARSE_DIR)parser.y | $(GEN_DIR)
	bison --output="$(GEN_DIR)parser.cxx" --defines="$(GEN_DIR)parser.hxx" $<
