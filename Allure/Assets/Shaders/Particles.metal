//
//  Computer.metal
//  Allure
//
//  Created by James on 14/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float age;
    float lifetime;
    
    vector_float3 velocity;
    
    vector_float3 startSize;
    vector_float3 endSize;
    
    vector_float4 startColor;
    vector_float4 endColor;
} Particle;

typedef struct {
    float drag;
    float accelRad;
    float accelRadRange;
} Emitter;

kernel void add_arrays(device const float* in_A,
                       device const float* in_B,
                       device float* result,
                       uint index [[thread_position_in_grid]]) {
    result[index] = in_A[index] + in_B[index];
}

kernel void get_mask(texture2d<half, access::read> inTexture[[texture(0)]],
                     device bool* result[[buffer(1)]],
                     device vector_float4* maskColor[[buffer(2)]],
                     device vector_float4* threshold[[buffer(3)]],
                     uint2 gid [[thread_position_in_grid]]) {
    const uint index = gid.x + gid.y * inTexture.get_width();
    const vector_half4 hCurrent = inTexture.read(gid);
    const vector_float4 current = vector_float4(hCurrent.x, hCurrent.y, hCurrent.z, hCurrent.w);
    const vector_float4 diff = current - *maskColor;
    
    result[index] = fabs(diff.x) <= threshold->x &&
                    fabs(diff.y) <= threshold->y &&
                    fabs(diff.z) <= threshold->z &&
                    fabs(diff.w) <= threshold->w;
}
