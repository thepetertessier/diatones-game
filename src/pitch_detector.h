#ifndef PITCH_DETECTOR_H
#define PITCH_DETECTOR_H

#include <godot_cpp/classes/audio_server.hpp>
#include <godot_cpp/classes/audio_effect_capture.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/godot.hpp>
#include <vector>

using namespace godot;

class PitchDetector : public Node {
    GDCLASS(PitchDetector, Node)

private:
    static constexpr int buffer_size = 2048;

    std::vector<double> compute_nsdf(const std::vector<double> &signal, int max_tau);
    int find_best_peak(const std::vector<double>& nsdf, int min_tau, int max_tau);
    double parabolic_interpolation(const std::vector<double>& nsdf, int tau);

protected:
    static void _bind_methods();

public:
    PitchDetector();
    ~PitchDetector();

    double detect_pitch_double(const std::vector<double>& signal, const int sample_rate = 44100, double f_min = 50, double f_max = 1000);
    double detect_pitch(const PackedVector2Array &audio_buffer, const int sample_rate = 44100, double f_min = 50, double f_max = 1000);
};

#endif // PITCH_DETECTOR_H
