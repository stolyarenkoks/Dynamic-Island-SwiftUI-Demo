//
//  ScrollStatusModifier.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

// MARK: - ScrollStatusModifier

struct ScrollStatusModifier: ViewModifier {

    // MARK: - Internal Properties

    @State var delegate = ScrollDelegate()
    @Binding var isScrolling: Bool

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onAppear {
                self.delegate.isScrolling = $isScrolling
            }
            .introspect(.scrollView, on: .iOS(.v17, .v16, .v15, .v14, .v13), customize: { scrollView in
                scrollView.delegate = delegate
            })
    }
}

// MARK: - ScrollDelegate

final class ScrollDelegate: NSObject, UITableViewDelegate, UIScrollViewDelegate {

    // MARK: - Internal Properties

    var isScrolling: Binding<Bool>?

    // MARK: - Internal Methods

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let isScrolling = isScrolling?.wrappedValue, !isScrolling else { return }
        Task {
            self.isScrolling?.wrappedValue = true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let isScrolling = isScrolling?.wrappedValue, isScrolling else { return }
        Task {
            self.isScrolling?.wrappedValue = false
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate, let isScrolling = isScrolling?.wrappedValue, isScrolling else { return }
        Task {
            self.isScrolling?.wrappedValue = false
        }
    }
}

// MARK: - ScrollStatusModifier View Extension

extension View {

    func scrollStatus(isScrolling: Binding<Bool>) -> some View {
        modifier(ScrollStatusModifier(isScrolling: isScrolling))
    }
}
