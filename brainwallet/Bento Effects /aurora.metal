//
//  aurora.metal
//  brainwallet
//
//  Created by Kerry Washington on 15/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 aurora(float2 position, float time) {
    float2 uv = position / 1000.0;
    
    float wave1 = sin(uv.x * 3.0 + time * 0.5) * 0.5 + 0.5;
    float wave2 = sin(uv.x * 2.0 - time * 0.3 + 1.0) * 0.5 + 0.5;
    float wave3 = sin(uv.x * 4.0 + time * 0.7 + 2.0) * 0.5 + 0.5;
    
    float intensity = (wave1 + wave2 + wave3) / 3.0;
    intensity *= smoothstep(0.8, 0.2, abs(uv.y - 0.3));
    
    half3 green = half3(0.2, 1.0, 0.4) * wave1;
    half3 cyan = half3(0.3, 0.9, 1.0) * wave2;
    half3 blue = half3(0.2, 0.4, 1.0) * wave3;
    
    half3 color = (green + cyan + blue) * intensity;
    
    return half4(color, intensity);
}
