//
//  DynamicIslandManager.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import Foundation
import DynamicIslandUtilities

// MARK: - DynamicIslandManager

class DynamicIslandManager {

    // MARK: - Singleton

    static let shared = DynamicIslandManager()

    private init() {}

    // MARK: - Internal Properties

    var isIslandAvailable: Bool {
        DynamicIsland.isAvailable
    }

    var islandTopPadding: CGFloat {
        isIslandAvailable ? Const.DynamicIslandManager.topPadding : 0
    }

    var islandSize: CGSize {
        isIslandAvailable ? DynamicIsland.size : notchSize
    }

    // MARK: - Private Properties

    private var notchSize: CGSize {
        CGSize(width: 94, height: 32)
    }
}
