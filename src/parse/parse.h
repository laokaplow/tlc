#ifndef PARSE_H_
#define PARSE_H_

#include "parse/tree.h"
#include <istream>

using ParseResult = Parse::Tree::Node::Ptr;

ParseResult parse(std::istream &in);

#endif
