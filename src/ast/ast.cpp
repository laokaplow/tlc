#include <sstream>
#include <string>
#include <vector>
#include <iostream>

#include "ast/ast.h"

using namespace std;
using namespace AST;

template <class S, class V, class T>
string join(S open, S close, V &contents, T &&transform) {
  stringstream ss(open);
  bool first = true;
  for (auto &it : contents) {
    if (!first) {
      ss << ",";
    }
    first = false;
    transform(ss, it);
  }
  ss << close;
  return ss.str();
}

List::Ptr List::append(Node::Ptr el) {
  auto buffer = contents;
  buffer.push_back(el);
  return make<List>(move(buffer));
}

string List::to_json() const {
  stringstream ss;
  ss << "[";
  bool first = true;
  for (auto &it : contents) {
    if (!first) { ss << " , "; }
    first = false;
    ss << it->to_json();
  }
  ss << "]";
  return ss.str();
}

string Branch::to_json() const {
  stringstream ss;
  ss << "{\"type\":\"Branch\", \"children\":{";
  bool first = true;
  for (auto &it : contents) {
    if (!first) { ss << " , "; }
    first = false;
    ss << "\"" << it.first << "\":" << it.second->to_json();
  }
  ss << "}}";
  return ss.str();
}
