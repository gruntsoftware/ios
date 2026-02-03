//
//  Text+Extension.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct BWIPSLight: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansLight(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.5)
            .truncationMode(.middle)
    }
}

struct BWIPSThin: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansThin(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.5)
            .truncationMode(.middle)
    }
}

struct BWIPSRegular: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansRegular(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.5)
            .truncationMode(.middle)
    }
}

struct BWIPSMedium: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansMedium(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.5)
            .truncationMode(.middle)
    }
}

struct BWIPSSemiBold: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansSemiBold(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.5)
            .truncationMode(.middle)
    }
}

struct BWIPSBold: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansBold(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.5)
            .truncationMode(.middle)
    }
}

struct BWBoldenVan: ViewModifier {
    let size: Double
    var lineLimit: Int = 1

    func body(content: Content) -> some View {
        content
            .font(.boldenVan(size: size))
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.7)
            .truncationMode(.middle)
    }
}
