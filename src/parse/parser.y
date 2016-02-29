/* C++ parser interface */
%skeleton "lalr1.cc"

/* require bison version */
%require "3.0.4"

/* add parser members (and associated constructor parameters) */
%parse-param {GENERATED::Scanner &scanner} {Parse::Tree::Node::Ptr &ast}

/* call yylex with a location */
%locations
%define api.location.type { Parse::Location }

/* increase usefulness of error messages and assert correct cleanup */
%define parse.error verbose
%define parse.assert

%define api.namespace {GENERATED}
%define parser_class_name {Parser}
%define api.value.type variant

%define api.token.constructor
%define api.token.prefix {T_}
/* Tokens */
%token
  END 0 "end of file"
  <Parse::Tree::Node::Literal::Ptr>   LET
  <Parse::Tree::Node::Literal::Ptr>   NAME
  <Parse::Tree::Node::Literal::Ptr>   OP
  <Parse::Tree::Node::Literal::Ptr>   EQ "="
  <Parse::Tree::Node::Literal::Ptr>   NUM
  <Parse::Tree::Node::Literal::Ptr>   SEMI ";"
  <Parse::Tree::Node::Literal::Ptr>   UNKNOWN
;

%type  <Parse::Tree::Node::Sequence::Ptr>       declarations
%type  <Parse::Tree::Node::Object::Ptr>         declaration
%type  <Parse::Tree::Node::Object::Ptr>         expr


%printer { yyoutput << $$; } <*>;

%start program

/* inserted near top of header + source file */
%code requires {
  #include <stdexcept>
  #include <string>

  #include "parse/tree.h"
  #include "parse/location.h"
  #include <iostream>

  namespace GENERATED {
    class Scanner;
  };

  #ifndef YY_NULLPTR
  #define YY_NULLPTR nullptr
  #endif
}

/* inserted near top of source file */
%code {
  #include "parse/scanner.h"
  #include <map>

  using namespace Parse::Tree;
  const bool PARSE_SUCCESS = true;

  using namespace std;

  // inform bison how the parser show call lex
  #undef yylex
  #define yylex scanner.lex


  // helper function for forwarding map literals
  map<string, Node::Ptr> _(initializer_list<pair<const string, Node::Ptr>> i) {
    return i;
  }

  #define O(...) make<Parse::Tree::Node::Object>(_({__VA_ARGS__}))
}

/* TODO: write special macro expander for this file
  turn (|໑|→|🌀) NodeType(val1, name2=val2, ...)
  into { $$ = make_unique<NodeType>(@$, {{"val1", $val1}, {"name2", $val2}, ...}); }

  could use unicode left-arrow as symbol

  or even better, write one to automatically generate bison.y file from nicer, custom EBNF-like DSL
  can integrate with json library and/or dump json
    can be integrated/verified with/by json_schema

  // example of preproccessor syntax
  declarations :
    : %empty                          → List()
    | declarations[self] declaration  → List(self, declaration)

  declaration
    : LET NAME "=" expr ";"           → (name=NAME, expr)
    | error ";"                       → ("invalid declaration")
    ;

  expr
    : NUM[lhs] OP NUM[rhs]            → (lhs, op=OP, rhs)
    | NUM                             → Literal(NUM)
    ;

    declarations = declaration{1:2, glue=','}
*/

%% // Grammar section

/* store ast */
program : declarations { ast = $declarations; return PARSE_SUCCESS; }

declarations
  : %empty                          { $$ = make<Node::Sequence>(); }
  | declarations[list] declaration  { $$ = $list->append($declaration); }

declaration
  : LET NAME "=" expr ";"           { $$ = O({"name", $NAME}, {"expr", $expr}); }
  /*: LET NAME "=" expr ";"           { $$ = 🌀(Branch, {"name", $NAME}, {"expr", $expr}); }*/
  /*| error ";"                       { $$ = make<Error<Branch>>("invalid declaration"); }*/
   /*should look into yyclearin and yyerrorok macros for clean error recovery */
  ;

expr
  : expr[lhs] OP NUM[rhs]           { $$ = O({"lhs", $lhs}, {"op", $OP}, {"rhs", $rhs}); }
  | NUM                             { $$ = O({"value",$NUM}); }
  ;


%%

void GENERATED::Parser::error(const Parser::location_type& loc, const std::string& msg)
{
    cout << "Error:" << msg << "\n";
    //throw Parser::syntax_error(loc, msg);
}
