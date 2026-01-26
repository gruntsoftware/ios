//
//  MetalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A representable container that uses a `MTKView` to periodically render a `CIImage`.
*/
// https://medium.com/@ant.lucchini/create-a-stunning-animated-background-in-swiftui-with-metal-32164bda67d9
import SwiftUI
import MetalKit

struct MetalView: ViewRepresentable {

    @StateObject var renderer: Renderer
    /// - Tag: MakeView
    func makeView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: renderer.device)

        // Suggest to Core Animation, through MetalKit, how often to redraw the view.
        // 30 fps works with 85 MB
        view.preferredFramesPerSecond = 30

        // Allow Core Image to render to the view using the Metal compute pipeline.
        view.framebufferOnly = false
        view.delegate = renderer

        if let layer = view.layer as? CAMetalLayer {
            // Enable EDR with a color space that supports values greater than SDR.
            if #available(iOS 16.0, *) {
                layer.wantsExtendedDynamicRangeContent = true
            }
            layer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
            // Ensure the render view supports pixel values in EDR.
            view.colorPixelFormat = MTLPixelFormat.rgba16Float
        }
        return view
    }

    func updateView(_ view: MTKView, context: Context) {
        configure(view: view, using: renderer)
    }

    private func configure(view: MTKView, using renderer: Renderer) {
        view.delegate = renderer
    }
}

protocol ViewRepresentable: UIViewRepresentable {
    associatedtype ViewType = UIViewType
    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
}

extension ViewRepresentable {
    func makeUIView(context: Context) -> ViewType {
        makeView(context: context)
    }

    func updateUIView(_ uiView: ViewType, context: Context) {
        updateView(uiView, context: context)
    }
}
