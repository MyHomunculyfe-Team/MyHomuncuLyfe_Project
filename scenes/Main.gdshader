shader_type canvas_item;

uniform float tile_scale = 1.0; // higher = more tiles (smaller stars)

void fragment() {
    vec2 uv_scaled = UV * tile_scale;
    COLOR = texture(TEXTURE, fract(uv_scaled));
}

