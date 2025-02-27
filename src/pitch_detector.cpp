#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/godot.hpp>
#include <vector>
#include <cmath>
#include <limits>
#include <algorithm>
#include "pitch_detector.h"

using namespace godot;

void PitchDetector::_bind_methods() {
    ClassDB::bind_method(D_METHOD("detect_pitch", "audio_buffer", "sample_rate", "f_min", "f_max"), &PitchDetector::detect_pitch);
}

PitchDetector::PitchDetector() {}
PitchDetector::~PitchDetector() {}

std::vector<double> PitchDetector::compute_nsdf(const std::vector<double>& signal, int max_tau) {
    int N = signal.size();
    std::vector<double> nsdf(max_tau, 0.0);

    for (int tau = 1; tau < max_tau; ++tau) {
        double acf = 0.0, norm = 0.0;

        for (int i = 0; i < N - tau; ++i) {
            acf += signal[i] * signal[i + tau];
            norm += signal[i] * signal[i] + signal[i + tau] * signal[i + tau];
        }

        nsdf[tau] = (norm > 0) ? (2.0 * acf / norm) : 0.0;
    }
    return nsdf;
}

// Find the highest peak in NSDF within a given range
int PitchDetector::find_best_peak(const std::vector<double>& nsdf, int min_tau, int max_tau) {
    int best_tau = -1;
    double max_value = -1.0;

    for (int tau = min_tau; tau < max_tau - 1; ++tau) {
        if (nsdf[tau] > max_value && nsdf[tau] > nsdf[tau - 1] && nsdf[tau] > nsdf[tau + 1]) {
            max_value = nsdf[tau];
            best_tau = tau;
        }
    }
    return best_tau;
}

// Apply parabolic interpolation for a more precise pitch estimate
double PitchDetector::parabolic_interpolation(const std::vector<double>& nsdf, int tau) {
    if (tau < 1 || tau >= nsdf.size() - 1)
        return tau; // No interpolation possible at boundaries

    double alpha = nsdf[tau - 1];
    double beta = nsdf[tau];
    double gamma = nsdf[tau + 1];

    return tau + 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
}

// Main function to estimate pitch using McLeod Pitch Method
double PitchDetector::detect_pitch_double(const std::vector<double>& signal, const int sample_rate, double f_min, double f_max) {
    int max_tau = static_cast<int>(sample_rate / f_min);
    int min_tau = static_cast<int>(sample_rate / f_max);

    std::vector<double> nsdf = compute_nsdf(signal, max_tau);
    int best_tau = find_best_peak(nsdf, min_tau, max_tau);

    if (best_tau == -1)
        return -1.0; // No pitch detected

    double refined_tau = parabolic_interpolation(nsdf, best_tau);
    return sample_rate / refined_tau; // Convert period to frequency
}

double PitchDetector::detect_pitch(const PackedVector2Array &audio_buffer, const int sample_rate, double f_min, double f_max) {
    int N = audio_buffer.size();
    if (N <= 0)
        return 0.0;

    // Convert stereo samples to mono (simple average of left and right channels)
    std::vector<double> mono;
    mono.reserve(N);
    for (int i = 0; i < N; i++) {
        Vector2 sample = audio_buffer[i];
        mono.push_back((sample.x + sample.y) * 0.5);
    }

    return detect_pitch_double(mono, sample_rate, f_min, f_max);
}
