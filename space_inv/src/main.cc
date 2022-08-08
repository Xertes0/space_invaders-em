#include <SDL2/SDL.h>
#include <SDL_events.h>
#include <SDL_pixels.h>
#include <SDL_render.h>
#include <SDL_surface.h>
#include <SDL_timer.h>
#include <algorithm>
#include <atat/cpu/cpu.hh>
#include <atat/cpu/registers.hh>
#include <atat/opcodes.hh>
#include <atat/disassembler.hh>

#include <fmt/core.h>
#include <source_location>
#include <stdexcept>
#include <functional>

#include "error.hh"
#include "hardware.hh"

static constexpr int TEXTURE_WIDTH  {256};
static constexpr int TEXTURE_HEIGHT {224};

static constexpr double SCALE{2};
static constexpr int SCREEN_WIDTH  {static_cast<int>(TEXTURE_HEIGHT * SCALE)};
static constexpr int SCREEN_HEIGHT {static_cast<int>(TEXTURE_WIDTH * SCALE)};

static constexpr uint32_t FRAME_SKIP_AMOUNT{5};

int main(int argc, char const** argv)
{
    if(argc < 2) {
        fmt::print(::stderr, "Specify space invaders rom file as an arugment\n");
        return 1;
    }

    space_inv::hardware hw{};
    auto memory{atat::memory_with_rom(argv[1])};
    atat::cpu cpu{
        memory.data(),
        [&](atat::byte_t port){ return hw.in(port); },
        [&](atat::byte_t port, atat::byte_t value){ hw.out(port, value); },
    };

    ERR(SDL_Init(SDL_INIT_VIDEO));

    SDL_Window* window{SDL_CreateWindow(
        "Space Invaders",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        SDL_WINDOW_SHOWN
    )};
    ERRN(window);

    SDL_Renderer* renderer{SDL_CreateRenderer(
        window, -1, 0//SDL_RENDERER_PRESENTVSYNC
    )};
    ERRN(renderer);

    SDL_Surface* surface{SDL_CreateRGBSurfaceWithFormat(
        SDL_SWSURFACE, TEXTURE_WIDTH, TEXTURE_HEIGHT, 1, SDL_PIXELFORMAT_INDEX1MSB
    )};
    ERRN(surface);
    SDL_Color colors[2] {{0, 0, 0, 255}, {255, 255, 255, 255}};
    DERR(SDL_SetPaletteColors(surface->format->palette, colors, 0, 2));

    while(cpu.int_enabled_ == 0) {
        cpu.step();
    }

    uint8_t next_int{0};
    uint32_t last_int_time{0};

    bool close{false};
    while(!close) {
        for(uint32_t i{0};i<FRAME_SKIP_AMOUNT;++i)
            cpu.step();

        SDL_Event e;
        while(SDL_PollEvent(&e)) {
            if(e.type == SDL_QUIT) {
                close = true;
            }
        }

        auto ticks = SDL_GetTicks();
        if(ticks > (last_int_time + (1000/60)) && cpu.int_enabled_ == 1) {
            last_int_time = ticks;
            cpu.generate_int(next_int?1:2);
            next_int = !next_int;

            DERR(SDL_LockSurface(surface));
            ::memcpy(surface->pixels, cpu.memory + 0x2400, TEXTURE_WIDTH*TEXTURE_HEIGHT/8);
            SDL_UnlockSurface(surface);
        }

        DERR(SDL_RenderClear(renderer));

        SDL_Texture* texture{SDL_CreateTextureFromSurface(renderer, surface)};
        DERR(SDL_RenderCopyEx(renderer, texture, nullptr, nullptr, 90, nullptr, SDL_FLIP_VERTICAL));

        SDL_RenderPresent(renderer);
        SDL_DestroyTexture(texture);
    }

    //SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}