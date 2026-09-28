#include "greeting.hpp"

#include <catch2/catch_test_macros.hpp>

TEST_CASE("A greeting includes the supplied name") {
  REQUIRE(greeting::message("Codex") == "Hello, Codex!");
}
