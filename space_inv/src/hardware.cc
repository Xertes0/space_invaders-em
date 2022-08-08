#include "hardware.hh"

namespace space_inv
{

byte_t
hardware::in(byte_t port)
{
    switch(port)
    {
        case 0: return port0;
        case 1: return port1;
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

void
hardware::fire(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 4);
    } else {
        port1 &= ~(1 << 4);
    }
}

void
hardware::left(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 5);
    } else {
        port1 &= ~(1 << 5);
    }
}

void
hardware::right(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 6);
    } else {
        port1 &= ~(1 << 6);
    }
}

void
hardware::credit(byte_t on)
{
    if(on == 1) {
        port1 |= 1;
    } else {
        port1 &= ~1;
    }
}

void
hardware::start_1p(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 2);
    } else {
        port1 &= ~(1 << 2);
    }
}

} // space_inv