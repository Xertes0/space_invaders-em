#include "hardware.hh"
#include <stdexcept>

namespace space_inv
{

byte_t
hardware::in(byte_t port)
{
    switch(port)
    {
        case 0: return port0;
        case 1: return port1;
        case 2: return port2;
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
hardware::p1_fire(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 4);
    } else {
        port1 &= ~(1 << 4);
    }
}

void
hardware::p1_left(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 5);
    } else {
        port1 &= ~(1 << 5);
    }
}

void
hardware::p1_right(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 6);
    } else {
        port1 &= ~(1 << 6);
    }
}

void
hardware::p2_fire(byte_t on)
{
    if(on == 1) {
        port2 |= (1 << 4);
    } else {
        port2 &= ~(1 << 4);
    }
}

void
hardware::p2_left(byte_t on)
{
    if(on == 1) {
        port2 |= (1 << 5);
    } else {
        port2 &= ~(1 << 5);
    }
}

void
hardware::p2_right(byte_t on)
{
    if(on == 1) {
        port2 |= (1 << 6);
    } else {
        port2 &= ~(1 << 6);
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

void
hardware::start_2p(byte_t on)
{
    if(on == 1) {
        port1 |= (1 << 1);
    } else {
        port1 &= ~(1 << 1);
    }
}

void
hardware::ship_count(byte_t count)
{
#ifndef NDEBUG
    if(count < 3 || count > 6) {
        throw std::runtime_error{"Invalid ship count"};
    }
#endif

    byte_t val = 0;
    if(count == 4 | count == 6)
        val |= 0b01;
    if(count == 5 | count == 6)
        val |= 0b10;

    port2 &= ~0b11;
    port2 |= val;
}

} // space_inv