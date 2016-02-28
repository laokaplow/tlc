#ifndef PARSE_H_
#define PARSE_H_

#include "ast/ast.h"
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>

#include "parse/GENERATED/parser.hxx"
#include "parse/GENERATED/scanner.hxx"
#include "parse/scanner.h"

std::string stringify(std::istream &in) {
  std::stringstream buffer;
  buffer << in.rdbuf();
  return buffer.str();
}

AST::Node::Ptr parse(std::istream &in) {
  AST::Node::Ptr res;
  GENERATED::Scanner scanner(&in);
  GENERATED::Parser parser(scanner, res);

  if (!parser.parse()) {
    throw std::runtime_error("Unknown parsing error");
  }

  return res;
}

#endif
