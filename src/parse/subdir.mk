###
## Parser makefile
#

PARSE_DIR:= src/parse/
GEN_DIR:= $(PARSE_DIR)GENERATED/
PARSER_OBJECTS = $(addprefix build/, $(PARSE_DIR)parse.o $(addprefix $(GEN_DIR), parser.o scanner.o))

CLEAN_LIST += $(GEN_DIR)

$(GEN_DIR):
	@mkdir -p $@

FLEX_OUTPUT := $(addprefix $(GEN_DIR), scanner.cxx scanner.hxx)
BISON_OUTPUT := $(addprefix $(GEN_DIR), parser.cxx parser.hxx position.hh location.hh stack.hh)
PARSER_INTERMEDIATE := $(addprefix build/$(GEN_DIR), parser.o scanner.o)

build/$(GEN_DIR)%.o: $(addprefix $(GEN_DIR), %.cxx %.hxx) # src/ast.h ??
		@mkdir -p $(@D)
		$(COMPILE) -c -o $@ $<

.INTERMEDIATE: .RUN.flex .RUN.bison

$(FLEX_OUTPUT): .RUN.flex;
.RUN.flex: $(PARSE_DIR)scanner.l $(PARSE_DIR)scanner.h | $(GEN_DIR)
	flex --outfile="$(GEN_DIR)scanner.cxx" --header-file="$(GEN_DIR)scanner.hxx" $<

$(BISON_OUTPUT): .RUN.bison;
.RUN.bison: $(PARSE_DIR)parser.y | $(GEN_DIR)
	bison --output="$(GEN_DIR)parser.cxx" --defines="$(GEN_DIR)parser.hxx" $<
