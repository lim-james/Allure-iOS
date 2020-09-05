//
//  MatrixTransform.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

extension Math {
    
    static public func SetToIdentity(_ mat: inout matrix_float4x4) {
        mat = matrix_float4x4(1.0)
    }
    
    static public func Frustrum(left: Float, right: Float, bottom: Float, top: Float, nearPlane: Float, farPlane: Float) -> matrix_float4x4 {
        return matrix_float4x4(rows: [
            simd_float4(2.0 * nearPlane / (right - left), 0, 0, 0),
            simd_float4(0, 2.0 * nearPlane / (top - bottom), 0, 0),
            simd_float4((right + left) / (right - left), (top + bottom) / (top - bottom), -(farPlane + nearPlane) / (farPlane - nearPlane), -1),
            simd_float4(0, 0, -2.0 * farPlane * nearPlane / (farPlane - nearPlane), 0)
        ])
    }
    
    static public func Orthographic(left: Float, right: Float, bottom: Float, top: Float, nearPlane: Float, farPlane: Float) -> matrix_float4x4 {
        return matrix_float4x4(rows: [
            simd_float4(2.0 / (right - left), 0, 0, 0),
            simd_float4(0, 2.0 / (top - bottom), 0, 0),
            simd_float4(0, 0, -2.0 / (farPlane - nearPlane), 0),
            simd_float4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), -(farPlane + nearPlane) / (farPlane - nearPlane), 1)
        ])
    }

    static public func SetToScale(mat: inout matrix_float4x4, scale: vector_float3) {
        mat = matrix_float4x4(diagonal: simd_float4(scale, 1.0))
    }

    static public func Scale(mat: inout matrix_float4x4, scale: vector_float3) {
        var transform = matrix_float4x4()
        SetToScale(mat: &transform, scale: scale)
        mat *= transform
    }

    static public func Scaled(mat: matrix_float4x4, scale: vector_float3) -> matrix_float4x4 {
        var transform = matrix_float4x4()
        SetToScale(mat: &transform, scale: scale)
        return mat * transform
    }

    static public func SetToRotation(mat: inout matrix_float4x4, angle: Float, axis: vector_float3) {
        let mag = sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)

        let x = axis.x / mag, y = axis.y / mag, z = axis.z / mag
        let c = cos(angle * ToRad), s = sin(angle * ToRad)

        mat = matrix_float4x4(rows: [
            simd_float4(
                x * x * (1 - c) + c,
                y * x * (1 - c) + z * s,
                x * z * (1 - c) - y * s,
                0
            ),
            simd_float4(
                x * y * (1 - c) - z * s,
                y * y * (1 - c) + c,
                y * z * (1 - c) + x * s,
                0
            ),
            simd_float4(
                x * z * (1 - c) + y * s,
                y * z * (1 - c) - x * s,
                z * z * (1 - c) + c,
                0
            ),
            simd_float4(0, 0, 0, 1)
        ])
    }

    static public func Rotate(mat: inout matrix_float4x4, angle: Float, axis: vector_float3) {
        var transform = matrix_float4x4()
        SetToRotation(mat: &transform, angle: angle, axis: axis)
        mat *= transform
    }

    static public func Rotated(mat: matrix_float4x4, angle: Float, axis: vector_float3) -> matrix_float4x4 {
        var transform = matrix_float4x4()
        SetToRotation(mat: &transform, angle: angle, axis: axis)
        return mat * transform
    }

    static public func SetToRotation(mat: inout matrix_float4x4, angles: vector_float3) {
        SetToIdentity(&mat)
        Rotate(mat: &mat, angle: angles.y, axis: vector_float3(0, 1, 0))
        Rotate(mat: &mat, angle: angles.x, axis: vector_float3(1, 0, 0))
        Rotate(mat: &mat, angle: angles.z, axis: vector_float3(0, 0, 1))
    }

    static public func Rotate(mat: inout matrix_float4x4, angles: vector_float3) {
        var transform = matrix_float4x4()
        SetToRotation(mat: &transform, angles: angles)
        mat *= transform
    }

    static public func Rotated(mat: matrix_float4x4, angles: vector_float3) -> matrix_float4x4 {
        var transform = matrix_float4x4()
        SetToRotation(mat: &transform, angles: angles)
        return mat * transform
    }

    static public func SetToTranslation(mat: inout matrix_float4x4, translation: vector_float3) {
        mat = matrix_float4x4(
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(translation, 1)
        )
    }

    static public func Translate(mat: inout matrix_float4x4, translation: vector_float3) {
        var transform = matrix_float4x4()
        SetToTranslation(mat: &transform, translation: translation)
        mat *= transform
    }

    static public func Translated(mat: matrix_float4x4, translation: vector_float3) -> matrix_float4x4 {
        var transform = matrix_float4x4()
        SetToTranslation(mat: &transform, translation: translation)
        return mat * transform
    }

    static public func SetToTransform(mat: inout matrix_float4x4, translation: vector_float3, rotation: vector_float3, scale: vector_float3) {
        SetToIdentity(&mat)
        Translate(mat: &mat, translation: translation)
        Rotate(mat: &mat, angles: rotation)
        Scale(mat: &mat, scale: scale)
    }

    static public func LookAt(eye: vector_float3, axes: matrix_float3x3) -> matrix_float4x4 {
        return matrix_float4x4(
            vector_float4(axes.columns.0, 0.0),
            vector_float4(axes.columns.1, 0.0),
            vector_float4(axes.columns.2, 0.0),
            vector_float4(eye, 1)
        )
        
    }

}
