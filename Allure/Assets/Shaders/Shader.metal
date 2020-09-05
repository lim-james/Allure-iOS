//
//  Shader.metal
//  Allure
//
//  Created by James on 15/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

typedef struct {
    matrix_float4x4 model;
    vector_float4 uvRect;
    vector_float4 color;
} StandardInstance;

typedef struct {
    matrix_float4x4 model;
    vector_float4 color;
} TintInstance;

typedef struct {
    matrix_float4x4 view;
    matrix_float4x4 projection;
} Uniforms;

typedef struct {
    vector_float4 position [[position]];
    vector_float2 texCoord;
    vector_float4 color;
} VS_OUT;

vertex VS_OUT standardVertexShader(uint vertexID [[vertex_id]],
                           uint instanceID [[instance_id]],
                           constant vector_float2 *vertices [[buffer(0)]],
                           constant Uniforms *uniformsPtr [[buffer(1)]],
                           constant StandardInstance *instances [[buffer(2)]]) {
    const vector_float2 position = vertices[vertexID];
    const StandardInstance i = instances[instanceID];
    const Uniforms uniforms = *uniformsPtr;
    
    const matrix_float4x4 mvp = uniforms.projection * uniforms.view * i.model;
    
    VS_OUT out;
    out.position = mvp * vector_float4(position, 0.0, 1.0);
    out.texCoord = (position + 0.5) * i.uvRect.zw + i.uvRect.xy;
    out.texCoord.y = 1.0 - out.texCoord.y;
    out.color = i.color;
    
    return out;
}

fragment float4 standardFragmentShader(VS_OUT in [[stage_in]],
                                       texture2d<half> colorTexture[[texture(3)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear, address::repeat);

    // Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.texCoord);
    const float4 outColor = float4(colorSample.x * in.color.x,
                                   colorSample.y * in.color.y,
                                   colorSample.z * in.color.z,
                                   colorSample.w * in.color.w);
    
    return outColor;
}

vertex VS_OUT tintVertexShader(uint vertexID [[vertex_id]],
                           uint instanceID [[instance_id]],
                           constant vector_float2 *vertices [[buffer(0)]],
                           constant Uniforms *uniformsPtr [[buffer(1)]],
                           constant TintInstance *instances [[buffer(2)]]) {
    const vector_float2 position = vertices[vertexID];
    const TintInstance i = instances[instanceID];
    const Uniforms uniforms = *uniformsPtr;
    
    const matrix_float4x4 mvp = uniforms.projection * uniforms.view * i.model;
    
    VS_OUT out;
    out.position = mvp * vector_float4(position, 0.0, 1.0);
    out.color = i.color;
    
    return out;
}

fragment float4 tintFragmentShader(VS_OUT in [[stage_in]]) {
    return in.color;
}
