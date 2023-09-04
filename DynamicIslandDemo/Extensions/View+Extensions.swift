//
//  View+Extensions.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - View Extension

extension View {

    func scrollStatus(isScrolling: Binding<Bool>) -> some View {
        modifier(ScrollStatusModifier(isScrolling: isScrolling))
    }
}
