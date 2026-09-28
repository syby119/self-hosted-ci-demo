#include "greeting.hpp"

#include <iostream>

int main() {
  std::cout << greeting::message("world") << '\n';
  return 0;
}
