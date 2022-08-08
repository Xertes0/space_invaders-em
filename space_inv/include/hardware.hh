#pragma once

#include <atat/cpu/types.hh>

namespace space_inv
{

using atat::byte_t;
using atat::word_t;

class hardware
{
    byte_t shift0{0};
    byte_t shift1{0};
    byte_t shift_offset{0};

    byte_t port0{0b01110000};
    byte_t port1{0b00010000};

public:
    // CPU <- HW
    byte_t
    in(byte_t port);

    // CPU -> HW
    void
    out(byte_t port, byte_t value);

    void fire(byte_t on);
    void left(byte_t on);
    void right(byte_t on);
    void credit(byte_t on);
    void start_1p(byte_t on);
};

} // namespace space_inv