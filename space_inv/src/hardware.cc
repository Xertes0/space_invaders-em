#include "hardware.hh"

namespace space_inv
{

byte_t
hardware::in(byte_t port)
{
    switch(port)
    {
        case 3:
        {
            word_t v = (shift1<<8) | shift0;
            return (v >> (8-shift_offset)) & 0xff;
        }
    }
    return 0;
}

void
hardware::out(byte_t port, byte_t value)
{
    switch(port)
    {
        case 2:
        {
            shift_offset = value;
            break;
        }
        case 4:
        {
            shift0 = shift1;
            shift1 = value;
            break;
        }
    }
}

} // space_inv