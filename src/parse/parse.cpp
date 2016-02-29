#include "parse/parse.h"

#include "parse/GENERATED/parser.hxx"
#include "scanner.h"
#include <stdexcept>

using namespace std;

ParseResult parse(std::istream &in) {
  ParseResult res;
  GENERATED::Scanner scanner(&in);
  GENERATED::Parser parser(scanner, res);

  if (!parser.parse()) {
    throw std::runtime_error("Unknown parsing error");
  }

  return res;
}
