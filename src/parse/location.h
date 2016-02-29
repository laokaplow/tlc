#ifndef PARSE_LOCATION_H_
#define PARSE_LOCATION_H_

#include <iostream>

namespace Parse {

struct Location {

  struct Position {
    int line, column;
    Position() : line(1), column(1){};
  };

  Position begin, end;

  void step();
  void new_line();

  Location() : begin(), end(){};
};

std::ostream &operator<<(std::ostream &, const Location::Position &);
std::ostream &operator<<(std::ostream &, const Location &);
}

#endif
