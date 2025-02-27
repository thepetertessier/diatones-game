#ifndef PITCH_DETECTOR_H
#define PITCH_DETECTOR_H

#include <godot_cpp/classes/audio_server.hpp>
#include <godot_cpp/classes/audio_effect_capture.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

class PitchDetector : public Node {
    GDCLASS(PitchDetector, Node)

private:
    static constexpr int buffer_size = 1024;

protected:
    static void _bind_methods();

public:
    PitchDetector();
    ~PitchDetector();

    double detect_pitch(const PackedVector2Array &audio_buffer, const int sample_rate = 44100);
};

#endif // PITCH_DETECTOR_H
