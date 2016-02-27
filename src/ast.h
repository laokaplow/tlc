#ifndef AST_H_
#define AST_H_

#include <map>
#include <sstream>
#include <string>
#include <typeinfo>
#include <vector>

namespace AST {
using namespace std;

template <typename T> using PtrType = shared_ptr<T>;
template <typename T, typename... Args>
PtrType<T> make(Args&&... args) {
  return make_shared<T>(forward<Args>(args)...);
}

struct Node {
  using Ptr = PtrType<Node>;
  virtual string to_json() const = 0;
  virtual ~Node() = default;
};

struct List : public Node {
  using Ptr = PtrType<List>;
  List(vector<Node::Ptr> contents = {}) : contents(contents) {}
  const vector<Node::Ptr> contents;
  List::Ptr append(Node::Ptr);
  string to_json() const override;
};

struct Branch : public Node {
  using Ptr = PtrType<Branch>;
  Branch(map<string, Node::Ptr> contents = {}) : contents(move(contents)) {}
  const map<string, Node::Ptr> contents;
  string to_json() const override;
};

struct Literal : public Node {
  using Ptr = PtrType<Literal>;
  Literal(string value) : value(value) {}
  const string value;
  string to_json() const override { return "\"AST Literal: " + value + "\""; }
};

template <typename T>
struct Error : public T {
  using Ptr = PtrType<Error>;
  Error(string msg = {}) : msg(msg) {}
  const string msg;
  string to_json() const override { return "\"AST Error: " + msg + "\""; }
};

struct Missing : public Node {
  using Ptr = PtrType<Missing>;
  Missing(type_info *expected) : expected(expected) {}
  const type_info *expected;
};
}

#endif
