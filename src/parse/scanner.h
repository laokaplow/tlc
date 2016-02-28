#ifndef SCANNER_H_
#define SCANNER_H_

// I want to remove this dependecy, equivalent to yy.tab.h ?
#include "parse/GENERATED/parser.hxx"


#undef yyFlexLexer // ugly hack, because <FlexLexer> is wonky
#include <FlexLexer.h>

#include <iostream>

// Tell flex how to define lexing fn
#undef YY_DECL
#define YY_DECL                                                                \
  int GENERATED::Scanner::lex(GENERATED::Parser::semantic_type *yylval,        \
                              GENERATED::Parser::location_type *yylloc)
// #define YY_DECL GENERATED::Parser::symbol_type GENERATED::Scanner::lex()

namespace GENERATED {
class Scanner : public yyFlexLexer {
public:
  explicit Scanner(std::istream *in = nullptr, std::ostream *out = nullptr);
  int lex(GENERATED::Parser::semantic_type *yylval,
          GENERATED::Parser::location_type *yylloc);
  // Parser::symbol_type lex();
};
}

#endif // include-guard
