#ifndef PITCH_DETECTOR_H
#define PITCH_DETECTOR_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <vector>

using namespace godot;

class PitchDetector : public Node {
	GDCLASS(PitchDetector, Node)

private:
	int sample_rate;
    int buffer_size;
    std::vector<double> audio_buffer;
    double detected_pitch; // in Hz

protected:
	static void _bind_methods();

public:
	PitchDetector();
	~PitchDetector();

	void process_audio(const PackedFloat64Array &audio_samples);
    double detect_pitch(const std::vector<double> &samples);

    void set_sample_rate(int sample_rate);
    int get_sample_rate() const;

    void set_buffer_size(int buffer_size);
    int get_buffer_size() const;

    void emit_detected_pitch();
};

#endif // PITCH_ANALYZER_H
