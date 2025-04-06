shader_type spatial;

uniform sampler2D base_texture;  // Declare the texture properly
uniform float time_scale : hint_range(0.0, 5.0) = 1.0;
uniform float wave_strength : hint_range(0.0, 0.2) = 0.05;
uniform float wave_frequency : hint_range(0.0, 10.0) = 5.0;
uniform float texture_scroll_speed : hint_range(0.0, 1.0) = 0.1;

void vertex() {
    float time_offset = TIME * time_scale;

    // Create a wave effect that distorts the model's vertices
    float wave = sin(VERTEX.y * wave_frequency + time_offset) * wave_strength;

    // Apply distortion to the x and z axes to simulate underwater movement
    VERTEX.x += wave;
    VERTEX.z += wave * 0.5; // Slightly less distortion on Z-axis

    // Apply normal-based distortion (helps surfaces deform naturally)
    VERTEX += NORMAL * wave_strength * sin(time_offset + VERTEX.y * wave_frequency);
}

void fragment() {
    vec2 uv = UV;

    // Scroll texture upwards over time
    float time_offset = TIME * texture_scroll_speed;
    uv.y += time_offset;

    // Apply a subtle wavy distortion to UVs
    float wave = sin(uv.y * wave_frequency + time_offset) * wave_strength;
    uv.x += wave;

    // Sample the texture properly in Godot 4.4
    vec4 tex = texture(base_texture, uv);

    // Slight blue tint to simulate water absorption
    tex.rgb *= vec3(0.8 + 0.2 * sin(time_offset), 0.9, 1.0);

    ALBEDO = tex.rgb;
}