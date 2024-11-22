#version 300 es
precision mediump float;

// Common uniforms
uniform float uTime;
uniform vec2 uResolution;

// Noise module uniforms
uniform float uFrequency;
uniform float uSpeed;
uniform float uNoiseMin;
uniform float uNoiseMax;

// Color module uniforms
uniform float uHueOffset;
uniform float uSaturation;
uniform float uValue;

// Module enable flags
uniform bool uNoiseEnabled;
uniform bool uColorEnabled;
uniform sampler2D uBlendTexture;
uniform bool uCurveEnabled;

// Add new uniforms
uniform float uCurveRotation;
uniform float uCurveScale;

in vec2 vUv;
out vec4 fragColor;

#include "lygia/generative/cnoise.glsl"

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 rotate2D(vec2 p, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(
        p.x * c - p.y * s,
        p.x * s + p.y * c
    );
}

void processColor(inout vec3 color) {
    if (uColorEnabled) {
        float hue = fract(uHueOffset);
        if (uNoiseEnabled) {
            float noiseValue = abs(cnoise(vec3(vUv * uFrequency, uTime * uSpeed)));
            noiseValue = mix(uNoiseMin, uNoiseMax, noiseValue);
            hue += noiseValue;
        }
        vec3 hsvColor = vec3(hue, uSaturation, uValue);
        vec3 rgbColor = hsv2rgb(hsvColor);
        
        color = rgbColor;
    }
}

void main() {
    // Start with grey background
    vec3 color = vec3(0.5);
    
    // Apply noise if enabled
    if (uNoiseEnabled) {
        vec3 noiseCoord = vec3(vUv * uFrequency, uTime * uSpeed);
        float noise = abs(cnoise(noiseCoord));
        noise = mix(uNoiseMin, uNoiseMax, noise);
        color = vec3(noise);
    }
    
    // Apply color at the end if enabled
    if (uColorEnabled) {
        vec3 hsvColor = vec3(uHueOffset, uSaturation, uValue);
        color = mix(color, hsv2rgb(hsvColor), 0.5);
    }
    
    fragColor = vec4(color, 1.0);
}