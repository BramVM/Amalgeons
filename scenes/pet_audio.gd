extends AudioStreamPlayer

@export var slash_duration := 0.18
@export var slash_start_freq := 260.0
@export var slash_end_freq := 90.0
@export var slash_noise_amount := 0.85
@export var slash_tone_amount := 0.25
@export var volume := 0.1

var _phase := 0.0

func _ready() -> void:
    randomize()
    # Set up the generator stream
    var gen := AudioStreamGenerator.new()
    gen.mix_rate = 22050.0        # lower rate = cheaper CPU, still fine for SFX
    gen.buffer_length = 0.25
    stream = gen
    play()                        # needs to be "playing" so playback exists
    SignalBus.attack.connect(_on_attack)
    SignalBus.start_dieing.connect(_on_death)

func _on_attack(_c):
    play_hit()

func _on_death(_c):
    play_death()

func play_hit() -> void:
    var playback := get_stream_playback() as AudioStreamGeneratorPlayback
    if playback == null:
        return

    var gen := stream as AudioStreamGenerator
    var sample_rate := gen.mix_rate

    # -----------------------------
    # ✨ Random variation per slash
    # -----------------------------
    var dur := slash_duration * randf_range(0.9, 1.15)

    var start_f := slash_start_freq * randf_range(0.9, 1.1)
    var end_f := slash_end_freq * randf_range(0.9, 1.1)

    var noise_amt := slash_noise_amount * randf_range(0.95, 1.05)
    var tone_amt  := slash_tone_amount * randf_range(0.85, 1.15)

    var pitch_jitter := randf_range(0.98, 1.02)

    playback.clear_buffer()

    var total_frames := int(sample_rate * dur)

    # ----------------------------------------
    # 🔊 Generate the slash waveform
    # ----------------------------------------
    for i in range(total_frames):
        var t := float(i) / total_frames

        # Downward pitch sweep with slight random drift
        var freq = lerp(start_f, end_f, t) * pitch_jitter
        var phase_inc = freq / sample_rate
        _phase = fmod(_phase + phase_inc, 1.0)

        # Triangle wave: smooth, whooshy
        var tri = 4.0 * abs(_phase - 0.5) - 1.0

        # Broadband noise (air “slice”)
        var noise := randf() * 2.0 - 1.0

        # Envelope: randomized decay
        var attack = clamp(t / randf_range(0.03, 0.05), 0.0, 1.0)
        var decay := pow(1.0 - t, randf_range(1.8, 2.4))
        var env = attack * decay

        # Final mixing
        var sample = (
            tri * tone_amt +
            noise * noise_amt
        ) * env * volume

        playback.push_frame(Vector2(sample, sample))

func play_death():
    var playback := get_stream_playback() as AudioStreamGeneratorPlayback
    if playback == null:
        return

    playback.clear_buffer()
    var duration := 0.22  # short, sharp, satisfying
    var sr := (stream as AudioStreamGenerator).mix_rate
    var total := int(sr * duration)

    # Randomness so it doesn’t repeat identically
    var start_freq := randf_range(650.0, 800.0)
    var end_freq   := randf_range(140.0, 180.0)
    var pop_freq   := randf_range(900.0, 1200.0)
    var noise_strength := randf_range(0.45, 0.65)

    for i in total:
        var t := float(i) / total
        var env := pow(1.0 - t, 1.7)

        var sample := 0.0

        # --- 1) First-frame “pop” (adds satisfying punch) ---
        if t < 0.05:
            var p := t / 0.05
            var pop := sin(2.0 * PI * pop_freq * t) * (1.0 - p)
            sample += pop * 0.9

        # --- 2) Downward chirp (classic faint sound) ---
        var glide_freq = lerp(start_freq, end_freq, t)
        sample += sin(2.0 * PI * glide_freq * t * 1.1) * 0.7

        # --- 3) Controlled noise burst (shatter/crumble feel) ---
        var noise := (randf() * 2.0 - 1.0) * noise_strength * (1.0 - t)
        sample += noise * 0.5

        # --- 4) Envelope & volume ---
        sample *= env * volume

        playback.push_frame(Vector2(sample, sample))

