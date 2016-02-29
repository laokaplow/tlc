#ifndef PARSE_H_
#define PARSE_H_

#include "ast/ast.h"
#include <istream>

using ParseResult = AST::Node::Ptr;

ParseResult parse(std::istream &in);

#endif
