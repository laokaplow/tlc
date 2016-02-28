%option c++ 8bit warn nodefault
%option yylineno
%option yyclass = "GENERATED::Scanner"

/*
  must not enable %option noyywrap, otherwise flex will emit duplicate
  definitions for yywrap :/
*/

%{
  #include "parse/GENERATED/parser.hxx" // equivalent of yy.tab.h
  #include "parse/scanner.h"
  #include <cstdlib>
  #include <iostream>
  #include <stdexcept>

  // before executing an action, set the length of the location from
  // the length of the matched pattern:
  #define YY_USER_ACTION location.end.column += YYLeng();

  #define YYSTR std::string(YYText(), YYLeng())
  #define NEW_NODE(s) AST::make<AST::Literal>(s)
  #define DEBUG(msg) //std::cerr << "Found: " << msg << " @ " << location << std::endl;

#define YIELD(tok)                                                             \
  {                                                                            \
    DEBUG(YYSTR)                                                               \
    return GENERATED::Parser::make_##tok(NEW_NODE(YYSTR), location);           \
  }
#define SKIP(thing)                                                            \
  {                                                                            \
    DEBUG(#thing + YYSTR)                                                      \
    location.step();                                                           \
  }

%}

%%

%{
  // code run each time before lex is called
  /*before matching any pattern, update the the current location*/
  location.begin = location.end; // advance past last location
%}

"let"                           YIELD(LET)
[a-zA-Z]([_\-]?[a-zA-Z0-9])*    YIELD(NAME)
"="                             YIELD(EQ)
"+"                             YIELD(OP)
[0-9]+                          YIELD(NUM)
";"                             YIELD(SEMI)

"//".*$                         SKIP(comments)
[ \t]                           SKIP(whitespace)

\n                              location.new_line();

                                /* forward everything else, even invalid
                                 * tokens - making use of bison's automatic
                                 * error messages */
.                               YIELD(UNKNOWN)
<<EOF>> return GENERATED::Parser::make_END(location);

%%

// Flex generates the code for `GENERATED::Scanner::lex` (see YY_DECL).

// The following must be defined manually to prevent linker errors:
GENERATED::Scanner::Scanner(std::istream *in, std::ostream *out) : yyFlexLexer(in, out) {}
int yyFlexLexer::yywrap() { return 1; }
