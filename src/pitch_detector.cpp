#include "pitch_detector.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <cmath>

using namespace godot;

void PitchDetector::_bind_methods() {
    ClassDB::bind_method(D_METHOD("process_audio", "audio_samples"), &PitchDetector::process_audio);
    ClassDB::bind_method(D_METHOD("set_sample_rate", "rate"), &PitchDetector::set_sample_rate);
    ClassDB::bind_method(D_METHOD("get_sample_rate"), &PitchDetector::get_sample_rate);
    ClassDB::bind_method(D_METHOD("set_buffer_size", "size"), &PitchDetector::set_buffer_size);
    ClassDB::bind_method(D_METHOD("get_buffer_size"), &PitchDetector::get_buffer_size);

    ADD_PROPERTY(PropertyInfo(Variant::INT, "sample_rate"), "set_sample_rate", "get_sample_rate");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "buffer_size"), "set_buffer_size", "get_buffer_size");

    ADD_SIGNAL(MethodInfo("pitch_detected", PropertyInfo(Variant::FLOAT, "frequency")));
}

PitchDetector::PitchDetector() {
    sample_rate = 44100; // Default sample rate
    buffer_size = 1024;  // Default buffer size
    detected_pitch = 0.0;
}

PitchDetector::~PitchDetector() {}

void PitchDetector::set_sample_rate(int rate) {
    sample_rate = rate;
}

int PitchDetector::get_sample_rate() const {
    return sample_rate;
}

void PitchDetector::set_buffer_size(int size) {
    buffer_size = size;
}

int PitchDetector::get_buffer_size() const {
    return buffer_size;
}

void PitchDetector::process_audio(const PackedFloat64Array &audio_samples) {
    // Convert Godot array to std::vector
    std::vector<double> samples(audio_samples.ptr(), audio_samples.ptr() + audio_samples.size());

    // Analyze pitch
    float frequency = detect_pitch(samples);
    if (frequency > 0.0f) {
        detected_pitch = frequency;
        emit_detected_pitch();
    }
}

double PitchDetector::detect_pitch(const std::vector<double> &samples) {
    // Simple zero-crossing pitch detection (replace with FFT/YIN for better accuracy)
    int crossings = 0;
    for (size_t i = 1; i < samples.size(); ++i) {
        if ((samples[i - 1] < 0 && samples[i] > 0) || (samples[i - 1] > 0 && samples[i] < 0)) {
            crossings++;
        }
    }

    float pitch = (crossings * sample_rate) / (2.0f * samples.size());
    return pitch;
}

void PitchDetector::emit_detected_pitch() {
    emit_signal("pitch_detected", detected_pitch);
}
