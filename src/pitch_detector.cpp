#include <iostream>
#include <vector>
#include <cmath>
#include <cstdlib>
#include <kiss_fftr.h>
#include "pitch_detector.h"

using namespace godot;

void PitchDetector::_bind_methods() {
    ClassDB::bind_method(D_METHOD("detect_pitch", "audio_buffer", "sample_rate", "f_min", "f_max"), &PitchDetector::detect_pitch);
    ClassDB::bind_method(D_METHOD("detect_midi", "audio_buffer", "sample_rate", "f_min", "f_max"), &PitchDetector::detect_midi);
    ClassDB::bind_method(D_METHOD("detect_pitch_and_midi", "audio_buffer", "sample_rate", "f_min", "f_max"), &PitchDetector::detect_pitch_and_midi);
}

//--------------------------------------------------------
// Helper function to compute next power of 2 (for FFT length)
//--------------------------------------------------------
unsigned int nextPowerOf2(unsigned int n) {
    unsigned int power = 1;
    while (power < n)
        power *= 2;
    return power;
}

//--------------------------------------------------------
// FFT-based autocorrelation using kissfft
//--------------------------------------------------------
std::vector<float> computeAutocorrelation(const std::vector<float>& signal) {
    size_t N = signal.size();
    // Determine FFT size: at least 2*N for proper convolution.
    size_t fftSize = nextPowerOf2(2 * N);

    // Prepare input buffer (zero-padded)
    std::vector<float> in(fftSize, 0.0f);
    for (size_t i = 0; i < N; i++) {
        in[i] = signal[i];
    }

    // Allocate FFT output: real FFT produces fftSize/2+1 complex numbers
    size_t nfftOut = fftSize / 2 + 1;
    std::vector<kiss_fft_cpx> fftOut(nfftOut);

    // Create FFT configuration for forward transform
    kiss_fftr_cfg fftCfg = kiss_fftr_alloc(fftSize, 0, nullptr, nullptr);
    if (!fftCfg) {
        std::cerr << "Failed to allocate FFT configuration" << std::endl;
        std::exit(1);
    }
    kiss_fftr(fftCfg, in.data(), fftOut.data());
    free(fftCfg);

    // Compute power spectrum (element-wise magnitude squared)
    for (size_t i = 0; i < nfftOut; i++) {
        float real = fftOut[i].r;
        float imag = fftOut[i].i;
        float magSq = real * real + imag * imag;
        fftOut[i].r = magSq;
        fftOut[i].i = 0.0f;
    }

    // Inverse FFT to get autocorrelation
    std::vector<float> autocorr(fftSize, 0.0f);
    kiss_fftr_cfg ifftCfg = kiss_fftr_alloc(fftSize, 1, nullptr, nullptr);
    if (!ifftCfg) {
        std::cerr << "Failed to allocate IFFT configuration" << std::endl;
        std::exit(1);
    }
    kiss_fftri(ifftCfg, fftOut.data(), autocorr.data());
    free(ifftCfg);

    // Normalize (kissfft does not scale the inverse transform)
    for (size_t i = 0; i < fftSize; i++) {
        autocorr[i] /= fftSize;
    }

    // Return only the first N values (the valid autocorrelation)
    return std::vector<float>(autocorr.begin(), autocorr.begin() + N);
}

//--------------------------------------------------------
// Compute cumulative energy (sum of squares) for denominator terms
//--------------------------------------------------------
std::vector<float> computeCumulativeEnergy(const std::vector<float>& signal) {
    size_t N = signal.size();
    std::vector<float> cumEnergy(N + 1, 0.0f);
    for (size_t i = 0; i < N; i++) {
        cumEnergy[i + 1] = cumEnergy[i] + signal[i] * signal[i];
    }
    return cumEnergy;
}

//--------------------------------------------------------
// McLeod's Pitch Detection Method (for mono audio stored in std::vector<float>)
//--------------------------------------------------------
float detectPitch(const std::vector<float>& signal, const int sampleRate, double f_min, double f_max) {
    size_t N = signal.size();
    if (N < 500) return 0.0f;

    int max_tau = static_cast<int>(sampleRate / f_min);
    int min_tau = static_cast<int>(sampleRate / f_max);

    // Step 1: Compute autocorrelation using FFT
    std::vector<float> autocorr = computeAutocorrelation(signal);

    // Step 2: Compute cumulative energy for denominator computation
    std::vector<float> cumEnergy = computeCumulativeEnergy(signal);

    // NSDF vector (normalized square difference function)
    std::vector<float> nsdf(max_tau, 0.0f);
    for (size_t tau = 1; tau < max_tau; tau++) {
        // Compute energy terms:
        // energy1 = sum_{n=0}^{N-tau-1} x[n]^2
        // energy2 = sum_{n=tau}^{N-1} x[n]^2
        float energy1 = cumEnergy[N - tau];         // x[0]...x[N-tau-1]
        float energy2 = cumEnergy[N] - cumEnergy[tau];  // x[tau]...x[N-1]
        float denom = energy1 + energy2;
        nsdf[tau] = (denom > 0.0f) ? (2.0f * autocorr[tau] / denom) : 0.0f;
    }
    nsdf[0] = 1.0f;  // By definition

    // Step 3: Peak picking - find the best local maximum (ignore tau == 0)
    float maxVal = 0.0f;
    size_t bestTau = 0;
    const float threshold = 0.6f; // Adjust as needed

    for (size_t tau = min_tau; tau < max_tau - 1; tau++) {
        if (nsdf[tau] > maxVal && nsdf[tau] > nsdf[tau - 1] && nsdf[tau] >= nsdf[tau + 1]) { // local maximum
            if (nsdf[tau] > maxVal) {
                maxVal = nsdf[tau];
                bestTau = tau;
            }
        }
    }

    // If no strong peak is found, consider the frame unvoiced.
    if (maxVal < threshold) {
        return 0.0f;
    }

    // Step 4: Parabolic interpolation around the best peak
    float tauInterp = static_cast<float>(bestTau);
    if (bestTau > 0 && bestTau < nsdf.size() - 1) {
        float nsdf_m1 = nsdf[bestTau - 1];
        float nsdf_p1 = nsdf[bestTau + 1];
        float denominator = 2.0f * (2.0f * nsdf[bestTau] - nsdf_m1 - nsdf_p1);
        if (denominator != 0.0f) {
            tauInterp += (nsdf_p1 - nsdf_m1) / denominator;
        }
    }

    // Convert lag (in samples) to frequency (Hz)
    float pitch = sampleRate / tauInterp;
    return pitch;
}

double hzToMidi(double pitchHz) {
    if (pitchHz <= 0) {
        pitchHz = 1;
    }
    return 69.0 + 12.0 * std::log2(pitchHz / 440.0);
}


//--------------------------------------------------------
// Wrapper function: convert stereo PackedVector2Array to mono and detect pitch
//--------------------------------------------------------
float detect_pitch_godot(const PackedVector2Array &audio_buffer, const int sample_rate, double f_min, double f_max) {
    // Convert the stereo audio to mono by averaging the two channels.
    std::vector<float> monoSignal;
    monoSignal.reserve(audio_buffer.size());
    for (size_t i = 0; i < audio_buffer.size(); i++) {
        const Vector2 &sample = audio_buffer[i];
        float mono = (sample.x + sample.y) * 0.5f;
        monoSignal.push_back(mono);
    }

    // Run the pitch detection on the mono signal.
    float pitch = detectPitch(monoSignal, sample_rate, f_min, f_max);

    // Ensure that the detected pitch is within the desired frequency bounds.
    if (pitch < f_min || pitch > f_max)
        return 0.0f;
    
    return pitch;
}

float PitchDetector::detect_pitch(const PackedVector2Array &audio_buffer, const int sample_rate, double f_min, double f_max) {
    return detect_pitch_godot(audio_buffer, sample_rate, f_min, f_max);
}

float PitchDetector::detect_midi(const PackedVector2Array &audio_buffer, const int sample_rate, double f_min, double f_max) {
    return hzToMidi(detect_pitch_godot(audio_buffer, sample_rate, f_min, f_max));
}

Vector2 PitchDetector::detect_pitch_and_midi(const PackedVector2Array &audio_buffer, const int sample_rate, double f_min, double f_max) {
    float pitch = detect_pitch_godot(audio_buffer, sample_rate, f_min, f_max);
    float midi = hzToMidi(pitch);
    return Vector2(pitch, midi);
}

//--------------------------------------------------------
// Example usage (for testing purposes)
//--------------------------------------------------------
// int main() {
//     const int sample_rate = 44100;
//     const size_t frameSize = 2048;
//     PackedVector2Array audio_buffer;

//     // Fill the audio_buffer with a test sine wave at 440 Hz (A4) for both channels.
//     for (size_t i = 0; i < frameSize; i++) {
//         float sampleValue = std::sin(2.0f * static_cast<float>(M_PI) * 440.0f * i / sample_rate);
//         // For a stereo signal, both channels are set to the same value.
//         audio_buffer.data.push_back({ sampleValue, sampleValue });
//     }

//     // Define frequency bounds (for example, allow pitches between 50 Hz and 2000 Hz)
//     double f_min = 50.0;
//     double f_max = 2000.0;
//     float detectedPitch = detect_pitch(audio_buffer, sample_rate, f_min, f_max);

//     if (detectedPitch > 0.0f) {
//         std::cout << "Detected pitch: " << detectedPitch << " Hz" << std::endl;
//     } else {
//         std::cout << "No pitch detected (frame unvoiced or out-of-bound)." << std::endl;
//     }

//     return 0;
// }
