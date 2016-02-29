#include "parse/tree.h"
#include <sstream>

using namespace std;
using namespace Parse::Tree;

Node::~Node() {}

string Node::Sequence::to_json() const {
  stringstream ss;
  ss << "[";
  bool first = true;
  for (auto &it : contents) {
    if (!first) {
      ss << " , ";
    }
    first = false;
    ss << it->to_json();
  }
  ss << "]";
  return ss.str();
}

Node::Sequence::Ptr Node::Sequence::append(Node::Ptr node) const {
  auto it = make<Node::Sequence>(contents);
  it->contents.push_back(node);
  return it;
}

string Node::Object::to_json() const {
  stringstream ss;
  ss << "{";
  bool first = true;
  for (auto &it : contents) {
    if (!first) {
      ss << " , ";
    }
    first = false;
    ss << "\"" << it.first << "\":" << it.second->to_json();
  }
  ss << "}";
  return ss.str();
}

string Node::Literal::to_json() const { return "\"" + value + "\""; }
