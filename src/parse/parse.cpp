#include "parse/parse.h"

#include "parse/GENERATED/parser.hxx"
#include "scanner.h"
#include <sstream>
#include <stdexcept>

using namespace std;

string stringify(istream &in) {
  stringstream buffer;
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
