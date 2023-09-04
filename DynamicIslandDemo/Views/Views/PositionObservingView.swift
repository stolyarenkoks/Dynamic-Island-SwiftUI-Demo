//
//  PositionObservingView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - PositionObservingView

struct PositionObservingView<Content: View>: View {

    // MARK: - CurrentPreferenceKey

    private struct CurrentPreferenceKey: PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
    }

    // MARK: - Internal Properties

    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content

    // MARK: - Body

    var body: some View {
        content()
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: CurrentPreferenceKey.self,
                        value: geometry.frame(in: coordinateSpace).origin
                    )
                }
            )
            .onPreferenceChange(CurrentPreferenceKey.self) { position in
                self.position = position
            }
    }
}
