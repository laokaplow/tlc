#ifndef PARSE_H_
#define PARSE_H_

#include "ast/ast.h"
#include <istream>

AST::Node::Ptr parse(std::istream &in);

#endif
