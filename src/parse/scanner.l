%option c++ 8bit warn nodefault
/* %option yylineno ?*/

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
#define YY_USER_ACTION yylloc->columns(YYLeng());

#define YYSTR std::string(YYText(), YYLeng())
#define NEW_NODE(s) AST::make<AST::Literal>(s))
#define RET(x) return Parser::token::T_##x
#define 🌀 std::cout << ">>> this is a test\n";
#define DEBUG(msg) /*std::cerr << "Found: " << msg << std::endl;*/

#define YIELD(tok)                                                             \
  {                                                                            \
    DEBUG(YYSTR)                                                               \
    yylval->build<AST::Literal::Ptr>(NEW_NODE(YYSTR);                          \
    RET(tok);                                                                  \
  }
%}

%%

%{ // before matching any pattern, update the the current location
  yylloc->step();
%}

"let"                          YIELD(LET)
[a-zA-Z]([_\-]?[a-zA-Z0-9])*   YIELD(NAME)
"="                            YIELD(EQ)
"+"                            YIELD(OP)
[0-9]+                         YIELD(NUM)
";"                            YIELD(SEMI)

"//".*$                        {/* eat comments */}
[ \t]                          {/* eat whitespace */}

\n                             yylloc->lines(1);

                                /* forward everything else, even invalid
                                 * tokens - making use of bison's automatic
                                 * error messages */
.                               YIELD(UNKNOWN)

%%

// Flex generates the code for `GENERATED::Scanner::lex` (see YY_DECL).

// The following must be defined manually to prevent linker errors:
GENERATED::Scanner::Scanner(std::istream *in, std::ostream *out) : yyFlexLexer(in, out) {}
int yyFlexLexer::yywrap() { return 1; }
int yyFlexLexer::yylex() {
  throw std::logic_error(
      "The yylex() exists for technical reasons and must not be used.");
}
