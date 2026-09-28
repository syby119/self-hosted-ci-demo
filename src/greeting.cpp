#include "greeting.hpp"

namespace greeting {

std::string message(const std::string& name) {
  return "Hello, " + name + "!";
}

}  // namespace greeting
