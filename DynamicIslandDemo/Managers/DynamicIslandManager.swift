//
//  DynamicIslandManager.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import Foundation

// MARK: - DynamicIslandManager

class DynamicIslandManager {

    // MARK: - Singleton

    static let shared = DynamicIslandManager()

    private init() {}

    // MARK: - Internal Properties

    /// Returns whether this device supports the Dynamic Island.
    /// This returns `true` for iPhone 14 Pro and iPhone Pro Max, otherwise returns `false`.
    let isIslandAvailable: Bool = {
        if #unavailable(iOS 16) {
            return false
        }

        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != .zero else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif

        let prefix = "iPhone"
        let iPhone14MinNumber: Double = 15.0
        let model = String(identifier.suffix(identifier.count - prefix.count))
        let modelNumber = Double(model.replacingOccurrences(of: ",", with: "."))
        guard let modelNumber = modelNumber else { return false }
        return modelNumber > iPhone14MinNumber
    }()

    /// The top padding of the Dynamic Island cutout.
    var islandTopPadding: CGFloat {
        isIslandAvailable ? Const.DynamicIslandManager.topPadding : .zero
    }

    /// The size of the Dynamic Island cutout.
    var islandSize: CGSize {
        isIslandAvailable ? islandActualSize : notchActualSize
    }

    // MARK: - Private Properties

    private var islandActualSize: CGSize {
        CGSize(width: 126.0, height: 37.33)
    }

    private var notchActualSize: CGSize {
        CGSize(width: 94, height: 32)
    }
}
