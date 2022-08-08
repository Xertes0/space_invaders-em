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

public:
    // CPU <- HW
    byte_t
    in(byte_t port);

    // CPU -> HW
    void
    out(byte_t port, byte_t value);
};

} // namespace space_inv