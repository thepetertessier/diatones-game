#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>
#include <vector>
#include <iostream>

extern "C" {
    #include "kiss_fft.h"
}

using namespace godot;

void run_fft_example() {
    const int N = 8; // Number of samples (must be a power of 2)
    
    // Input: Create a simple test signal (real numbers)
    kiss_fft_cpx in[N], out[N];
    
    for (int i = 0; i < N; i++) {
        in[i].r = i + 1; // Real part
        in[i].i = 0;     // Imaginary part (zero for real signals)
    }

    // Create a FFT configuration
    kiss_fft_cfg cfg = kiss_fft_alloc(N, 0, nullptr, nullptr);
    if (!cfg) {
        std::cerr << "Failed to allocate FFT configuration!" << std::endl;
        return;
    }

    // Compute the FFT
    kiss_fft(cfg, in, out);

    // Print the output
    std::cout << "FFT Output:\n";
    for (int i = 0; i < N; i++) {
        std::cout << "Bin " << i << ": (" << out[i].r << ", " << out[i].i << "i)\n";
    }

    // Free memory
    free(cfg);
}

// Entry point for Godot GDExtension
extern "C" void GDE_EXPORT my_extension_init() {
    run_fft_example();
}
