//
//  OpacityTransitionModifier.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 18.09.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - OpacityTransitionModifier

struct OpacityTransitionModifier: ViewModifier {

    let move: Edge

    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(insertion: .move(edge: move), removal: .move(edge: move))
                .combined(with: .asymmetric(insertion: .opacity, removal: .opacity))
            )
    }
}

// MARK: - OpacityTransition View Extension

extension View {

    func opacityTransition(move: Edge) -> some View {
        modifier(OpacityTransitionModifier(move: move))
    }
}
