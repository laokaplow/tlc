#include "parse/parse.h"
#include <iostream>

using namespace std;

int main(int argc, char *argv[]) {
  cout << parse(cin)->to_json();
  return 0;
}
