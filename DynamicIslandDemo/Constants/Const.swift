//
//  Const.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import Foundation

// MARK: - Const

enum Const {

    // MARK: - General

    enum General {
        static let bulletPointSymbol = "•"
    }

    // MARK: - Managers

    enum DynamicIslandManager {
        static let topPadding: CGFloat = 11.0
    }

    // MARK: - Views

    enum MainView {
        static let imageViewId = "Image"
        static let islandViewId = "Island"
        static let headerViewId = "Header"

        static let imageTopPadding: CGFloat = 8.0
        static let imageSize: CGFloat = 100.0
    }

    enum OffsetObservingScrollView {
        static let openOffsetPosition: CGFloat = 80.0
        static let coordinateSpaceName: UUID = UUID()
    }

    enum ToggleCellView {
        static let enabledTitle = "Enabled"
        static let disabledTitle = "Disabled"
    }
}
