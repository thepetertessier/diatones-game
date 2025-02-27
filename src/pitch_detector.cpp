#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/godot.hpp>
#include <vector>
#include <cmath>
#include <limits>
#include "pitch_detector.h"

using namespace godot;

void PitchDetector::_bind_methods() {
    ClassDB::bind_method(D_METHOD("detect_pitch", "audio_buffer", "sample_rate"), &PitchDetector::detect_pitch);
}

PitchDetector::PitchDetector() {}
PitchDetector::~PitchDetector() {}

// Returns the detected frequency in Hz using a basic autocorrelation pitch detection.
double PitchDetector::detect_pitch(const PackedVector2Array &audio_buffer, const int sample_rate) {
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

    // Define plausible pitch range (here: 50 Hz to 1000 Hz)
    int min_lag = sample_rate / 1000; // ~44 samples → ~1000 Hz
    int max_lag = sample_rate / 50;   // ~882 samples → ~50 Hz

    // Ensure our lag range fits within the buffer length
    if (max_lag > N - 1) {
        max_lag = N - 1;
    }
    if (min_lag < 1) {
        min_lag = 1;
    }
    if (min_lag >= max_lag)
        return 0.0;

    // Compute autocorrelation for each lag in the defined range.
    std::vector<double> autocorr;
    autocorr.resize(max_lag - min_lag + 1);
    for (int lag = min_lag; lag <= max_lag; lag++) {
        double sum = 0.0;
        for (int i = 0; i < N - lag; i++) {
            sum += mono[i] * mono[i + lag];
        }
        autocorr[lag - min_lag] = sum;
    }

    // Find the lag that gives the maximum autocorrelation value.
    int best_index = 0;
    double best_corr = -std::numeric_limits<double>::infinity();
    for (size_t i = 0; i < autocorr.size(); i++) {
        if (autocorr[i] > best_corr) {
            best_corr = autocorr[i];
            best_index = i;
        }
    }
    double best_lag = best_index + min_lag;

    // Refine the lag estimate using parabolic interpolation if possible.
    if (best_index > 0 && best_index < autocorr.size() - 1) {
        double c0 = autocorr[best_index - 1];
        double c1 = autocorr[best_index];
        double c2 = autocorr[best_index + 1];
        double denom = 2 * (2 * c1 - c0 - c2);
        if (std::fabs(denom) > 1e-6) {
            double delta = (c0 - c2) / denom;
            best_lag += delta;
        }
    }

    // Convert the period (in samples) to frequency (in Hz)
    double frequency = sample_rate / best_lag;
    return frequency;
}
