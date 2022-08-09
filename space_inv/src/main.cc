#include <algorithm>
#include <stdexcept>
#include <functional>

#include <SDL2/SDL.h>
#include <atat/cpu/cpu.hh>
#include <atat/cpu/registers.hh>
#include <atat/opcodes.hh>
#include <atat/disassembler.hh>
#include <fmt/core.h>

#include "atat/cpu/types.hh"
#include "error.hh"
#include "hardware.hh"

static constexpr int TEXTURE_WIDTH  {256};
static constexpr int TEXTURE_HEIGHT {224};

static constexpr double SCALE{2};
static constexpr int SCREEN_WIDTH  {static_cast<int>(TEXTURE_HEIGHT * SCALE)};
static constexpr int SCREEN_HEIGHT {static_cast<int>(TEXTURE_WIDTH * SCALE)};
//static constexpr int SCREEN_WIDTH  {static_cast<int>(TEXTURE_WIDTH * SCALE)};
//static constexpr int SCREEN_HEIGHT {static_cast<int>(TEXTURE_HEIGHT * SCALE)};

static constexpr uint32_t REFRESH_RATE{1000/120}; // milliseconds

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
        SDL_SWSURFACE, TEXTURE_WIDTH, TEXTURE_HEIGHT, 1, SDL_PIXELFORMAT_ARGB8888
    )};
    ERRN(surface);
    //SDL_Color colors[2] {{0, 0, 0, 255}, {255, 255, 255, 255}};
    //DERR(SDL_SetPaletteColors(surface->format->palette, colors, 0, 2));

    while(cpu.int_enabled_ == 0)
        cpu.step();

    // 0 - Top half
    // 1 - Bottom half
    uint8_t next_int{0};
    uint32_t last_int_time{0};

    bool close{false};
    while(!close) {
        //for(int i=0;i<20;++i)
        //    cpu.step();
        int frame_skip = 0;
        do{
            cpu.step();
            ++frame_skip;
        }while(cpu.int_enabled_ == 0 || frame_skip < 20);

        SDL_Event e;
        while(SDL_PollEvent(&e)) {
            if(e.type == SDL_QUIT) {
                    close = true;
            } else if(e.type == SDL_KEYDOWN || e.type == SDL_KEYUP) {
                atat::byte_t val = (e.type == SDL_KEYUP)?0:1;
                switch(e.key.keysym.sym)
                {
                    case SDLK_a:        hw.left(val);     break;
                    case SDLK_d:        hw.right(val);    break;
                    case SDLK_SPACE:    hw.fire(val);     break;
                    case SDLK_RETURN:   hw.credit(val);   break;
                    case SDLK_1:        hw.start_1p(val); break;
                }
            }
        }

        auto ticks = SDL_GetTicks();
        if(ticks > (last_int_time + REFRESH_RATE) && cpu.int_enabled_ == 1) {
            last_int_time = ticks;
            cpu.generate_int(next_int?1:2);

            DERR(SDL_LockSurface(surface));
            uint32_t* pixel_ptr = reinterpret_cast<uint32_t*>(surface->pixels);
            for(atat::word_t i{0x2400}; i<0x4000; ++i) {
                auto b{cpu.memory[i]};
                for(int off{0};off<8;++off) {
                    *pixel_ptr++ = ((b>>off)&1)?0xFFFFFFFF:0xFF000000;
                }
            }
            //::memcpy(surface->pixels, cpu.memory + 0x2400, TEXTURE_WIDTH*TEXTURE_HEIGHT/8);
            SDL_UnlockSurface(surface);
            next_int = !next_int;
        }

        DERR(SDL_RenderClear(renderer));

        static constexpr SDL_Rect src_rect{
            0,0, 224, 256
        };

        static constexpr SDL_Rect dst_rect{
            static_cast<int>(-16 * SCALE),static_cast<int>(16 * SCALE), SCREEN_HEIGHT, SCREEN_WIDTH
        };

        SDL_Texture* texture{SDL_CreateTextureFromSurface(renderer, surface)};
        //DERR(SDL_RenderCopy(renderer, texture, nullptr, nullptr));
        DERR(SDL_RenderCopyEx(renderer, texture, nullptr, &dst_rect, -90, nullptr, SDL_FLIP_NONE));
        //DERR(SDL_RenderCopyEx(renderer, texture, &src_rect, &dst_rect, -90, nullptr, SDL_FLIP_NONE));

        SDL_RenderPresent(renderer);
        SDL_DestroyTexture(texture);
    }

    //SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}