#pragma once

#include <cstdio>
#include <fmt/core.h>
#include <SDL2/SDL_error.h>

namespace space_inv
{

#if defined(__cpp_lib_source_location) && !defined(NDEBUG)
template<class Operator = std::not_equal_to<>>
void check_error(auto value, std::source_location sloc = std::source_location::current())
{
    // Works for ints and pointers
    if(Operator{}(value, decltype(value){0})) {
        fmt::print(::stderr, "Error {} ({}): {}\n", sloc.function_name(), sloc.line(), SDL_GetError());
        throw std::runtime_error{"SDL Error"};
    }
}
#else
template<class Operator = std::not_equal_to<>>
void check_error(auto value)
{
    if(Operator{}(value, decltype(value){0})) {
        fmt::print(::stderr, "Error: {}\n", SDL_GetError());
        throw std::runtime_error{"SDL Error"};
    }
}
#endif

// For functions returning 0 on success
#define ERR(X) ::space_inv::check_error(X)
// For functions returning non 0 on success
#define ERRN(X) ::space_inv::check_error<std::equal_to<>>(X)

#ifndef NDEBUG
#define DERR(X) ::space_inv::check_error(X)
#define DERRN(X) ::space_inv::check_error<std::equal_to<>>(X)
#else
#define DERR(X) X
#define DERRN(X) X
#endif

} // namespace space_inv