#ifndef PARSE_TREE_H_
#define PARSE_TREE_H_

#include <map>
#include <memory>
#include <string>
#include <vector>

namespace Parse {
namespace Tree {
using namespace std;

template <typename T> using Ptr = shared_ptr<T>;
template <typename T, typename... Args> Ptr<T> make(Args &&... args) {
  return make_shared<T>(forward<Args>(args)...);
}

struct Node {
  using Ptr = Tree::Ptr<Node>;

  virtual ~Node() = 0;
  virtual string to_json() const = 0;

  struct Sequence;
  struct Object;
  struct Literal;
};

struct Node::Sequence : public Node {
  using Ptr = Tree::Ptr<Sequence>;

  Sequence(vector<Node::Ptr> contents = {}) : contents(contents) {}
  vector<Node::Ptr> contents;

  Ptr append(Node::Ptr other) const;

  string to_json() const override;
};

struct Node::Object : public Node {
  using Ptr = Tree::Ptr<Object>;

  Object(map<string, Node::Ptr> contents = {}) : contents(contents) {}
  map<string, Node::Ptr> contents;

  string to_json() const override;
};

struct Node::Literal : public Node {
  using Ptr = Tree::Ptr<Literal>;

  Literal(string value) : value(value) {}
  string value;

  string to_json() const override;
};
}
}

#endif
