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
    byte_t port2{0b00000000};

public:
    // CPU <- HW
    byte_t
    in(byte_t port);

    // CPU -> HW
    void
    out(byte_t port, byte_t value);

    void p1_fire(byte_t on);
    void p1_left(byte_t on);
    void p1_right(byte_t on);
    void p2_fire(byte_t on);
    void p2_left(byte_t on);
    void p2_right(byte_t on);
    void credit(byte_t on);
    void start_1p(byte_t on);
    void start_2p(byte_t on);

    // <3;6>
    void ship_count(byte_t count);
};

} // namespace space_inv