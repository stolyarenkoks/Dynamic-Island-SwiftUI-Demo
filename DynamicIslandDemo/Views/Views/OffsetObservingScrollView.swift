//
//  OffsetObservingScrollView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - OffsetObservingScrollView

struct OffsetObservingScrollView<Content: View>: View {

    // MARK: - Internal Properties

    @Binding var offset: CGPoint
    @Binding var showsIndicators: Bool
    @Binding var isHeaderPagingEnabled: Bool
    @ViewBuilder var content: () -> Content

    var axes: Axis.Set = [.vertical]
    @State var delegate = ScrollDelegate()
    @State var isScrolling = false

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(axes, showsIndicators: showsIndicators) {
                PositionObservingView(
                    coordinateSpace: .named(Const.OffsetObservingScrollView.coordinateSpaceName),
                    position: Binding(
                        get: { offset },
                        set: { newOffset in
                            offset = CGPoint(
                                x: -newOffset.x,
                                y: -newOffset.y
                            )
                        }
                    ),
                    content: content
                )
            }
            .scrollStatus(isScrolling: $isScrolling)
            .coordinateSpace(name: Const.OffsetObservingScrollView.coordinateSpaceName)
            .onChange(
                of: isScrolling,
                perform: { _ in
                    guard isHeaderPagingEnabled,
                          offset.y < Const.OffsetObservingScrollView.openOffsetPosition && offset.y > 0,
                          !isScrolling else { return }
                    let shouldShowBottom = offset.y > Const.OffsetObservingScrollView.openOffsetPosition / 2
                    let anchor: UnitPoint = shouldShowBottom ? .top : .bottom
                    withAnimation {
                        proxy.scrollTo(Const.MainView.headerViewId, anchor: anchor)
                    }
                }
            )
        }
    }
}
