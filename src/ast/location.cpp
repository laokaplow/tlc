#include "ast/location.h"
#include <iostream>

namespace AST {

using namespace std;

void Location::step() {
  begin = end;
}

void Location::new_line() {
  end.line += 1;
  end.column = 1;
}

std::ostream &operator<<(std::ostream &o, const Location::Position &p) {
  o << p.line << ":" << p.column;
  return o;
}

std::ostream &operator<<(std::ostream &o, const Location &l) {
  o << "[" << l.begin << "," << l.end << "]";
  return o;
}

}
