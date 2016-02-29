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
  <Parse::Tree::Node::Literal::Ptr>   NUMBER
  <Parse::Tree::Node::Literal::Ptr>   LAMBDA      "λ"
  <Parse::Tree::Node::Literal::Ptr>   EQ          "="
  <Parse::Tree::Node::Literal::Ptr>   COMMA       ","
  <Parse::Tree::Node::Literal::Ptr>   COLON       ":"
  <Parse::Tree::Node::Literal::Ptr>   SEMICOLON   ";"
  <Parse::Tree::Node::Literal::Ptr>   OPEN_PAREN  "("
  <Parse::Tree::Node::Literal::Ptr>   CLOSE_PAREN ")"
  <Parse::Tree::Node::Literal::Ptr>   OPEN_CURLY  "{"
  <Parse::Tree::Node::Literal::Ptr>   CLOSE_CURLY "}"
  <Parse::Tree::Node::Literal::Ptr>   RIGHT_ARROW "->"
  <Parse::Tree::Node::Literal::Ptr>   LEFT_ARROW  "<-"
  <Parse::Tree::Node::Literal::Ptr>   PLUS        "+"
  <Parse::Tree::Node::Literal::Ptr>   STAR        "*"

  <Parse::Tree::Node::Literal::Ptr>   UNKNOWN
  <Parse::Tree::Node::Literal::Ptr>   FFF
;

%type  <Parse::Tree::Node::Sequence::Ptr>       declarations
%type  <Parse::Tree::Node::Sequence::Ptr>       scope
%type  <Parse::Tree::Node::Sequence::Ptr>       statements optional_statements
%type  <Parse::Tree::Node::Sequence::Ptr>       type_specifiers optional_type_specifiers
%type  <Parse::Tree::Node::Sequence::Ptr>       args optional_args
%type  <Parse::Tree::Node::Sequence::Ptr>       parameters optional_parameters

%type  <Parse::Tree::Node::Ptr>                 declaration
%type  <Parse::Tree::Node::Ptr>                 expr
%type  <Parse::Tree::Node::Ptr>                 statement
%type  <Parse::Tree::Node::Ptr>                 infix_expr
%type  <Parse::Tree::Node::Ptr>                 arg
%type  <Parse::Tree::Node::Ptr>                 function_call
%type  <Parse::Tree::Node::Ptr>                 type_specifier
%type  <Parse::Tree::Node::Ptr>                 function_type_specifier
%type  <Parse::Tree::Node::Ptr>                 function_literal
%type  <Parse::Tree::Node::Ptr>                 optional_initilization
%type  <Parse::Tree::Node::Ptr>                 optional_type_specifier
%type  <Parse::Tree::Node::Ptr>                 var_decl
%type  <Parse::Tree::Node::Ptr>                 literal

%left "+"
%precedence "("

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

  #define O(...) \
  make<Parse::Tree::Node::Object>(_({__VA_ARGS__}))
  #define TYPESPEC(x) {"type", make<}
  #define Q(typename, ...) \
  make<Parse::Tree::Node::Object>(_({{"type", make<Node::Literal>(#typename)}, __VA_ARGS__}))

  /*
    TODO: look into using error in rules
      should look into yyclearin and yyerrorok macros for clean error recovery
  */
}

%% // Grammar section

/* store ast */
program : declarations { ast = $declarations; return PARSE_SUCCESS; }

declarations
  : %empty                          { $$ = make<Node::Sequence>(); }
  | declarations[list] declaration  { $$ = $list->append($declaration); }
  ;

declaration
  : LET var_decl ";"                { $$ = $var_decl; }
  ;

var_decl
  : NAME ":" optional_type_specifier optional_initilization       { $$ = Q(declaration, {"type_spec", $3}, {"init",$4}); }
  ;

optional_type_specifier
  : %empty                          { $$ = O(); }
  | type_specifier
  ;

optional_initilization
  : %empty                          { $$ = O(); }
  | "=" expr                        { $$ = $expr; }
  ;

expr
  : NAME                          { $$ = O(); }
  | literal                       { $$ = O(); }
  | "(" expr ")"                  { $$ = O(); }
  | infix_expr                    { $$ = O(); }
  | function_call                 { $$ = O(); }
  ;

infix_expr
  : expr "+" expr                 { $$ = O(); }
  ;

literal
  : NUMBER                  { $$ = O(); }
  | function_literal        { $$ = O(); }
  ;

function_literal
  : LAMBDA "(" optional_parameters ")" "->" "{" optional_statements "}"       { $$ = O(); }
  ;

optional_parameters
  : %empty                            { $$ = make<Node::Sequence>(); }
  | parameters                        { $$ = make<Node::Sequence>(); }
  ;

parameters
  : NAME ":" type_specifier            { $$ = make<Node::Sequence>(); }
  | parameters "," var_decl            { $$ = make<Node::Sequence>(); }
  ;

type_specifier
  : NAME                          { $$ = O(); }
  | function_type_specifier       { $$ = O(); }
  ;

function_type_specifier
  : LAMBDA "(" optional_type_specifiers ")" "->" type_specifier { $$ = O(); }
  ;

optional_type_specifiers
  : %empty                      { $$ = make<Node::Sequence>(); }
  | type_specifiers             { $$ = make<Node::Sequence>(); }
  ;

type_specifiers
  : type_specifier                      { $$ = make<Node::Sequence>(); }
  | type_specifiers "," type_specifier  { $$ = make<Node::Sequence>(); }
  ;

function_call
  : expr "(" optional_args ")"          { $$ = O(); }
  ;

optional_args
  : %empty              { $$ = make<Node::Sequence>(); }
  | args                { $$ = make<Node::Sequence>(); }
  ;

args
  : arg                      { $$ = make<Node::Sequence>(); }
  | args[list] "," arg       { $$ = make<Node::Sequence>(); }
  ;

arg
  : NAME "=" expr       { $$ = O(); }
  ;

optional_statements
  : %empty                    { $$ = make<Node::Sequence>(); }
  | statements                { $$ = make<Node::Sequence>(); }
  ;

statements
  : statement                   { $$ = make<Node::Sequence>(); }
  | statements statement        { $$ = make<Node::Sequence>(); }
  ;

statement
  : NAME "<-" expr ";"       { $$ = O(); }
  | expr "->" NAME ";"       { $$ = O(); }
  | function_call ";"        { $$ = O(); }
  | declaration              { $$ = O(); }
  | scope                    { $$ = O(); }
  ;

scope
  : "{" optional_statements "}"  { $$ = make<Node::Sequence>(); }
  ;

%%

void GENERATED::Parser::error(const Parser::location_type& loc, const std::string& msg)
{
    //cerr << "Error:" << msg << "\n";
    throw syntax_error(loc, msg);
}
