//
//  DynamicIslandManager.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import UIKit

// MARK: - DynamicIslandManager

class DynamicIslandManager {

    // MARK: - Singleton

    static let shared = DynamicIslandManager()

    private init() {
        let screen = UIScreen.main
        var cutoutFrame: CGRect?

        if screen.responds(to: NSSelectorFromString(Self.exclusionAreaKey)) {
            cutoutFrame = Self.systemCutoutFrame(of: screen)
            if let cutoutFrame {
                // The Dynamic Island floats below the top edge of the screen, while the notch is attached to it.
                cutoutType = cutoutFrame.minY > .zero ? .dynamicIsland : .notch
            } else {
                cutoutType = .none
            }
        } else {
            cutoutType = Self.isIslandAvailableForDeviceModel() ? .dynamicIsland : .none
        }

        switch cutoutType {
        case .dynamicIsland:
            islandTopPadding = cutoutFrame?.minY ?? Const.DynamicIslandManager.topPadding
            islandSize = cutoutFrame?.size ?? Const.DynamicIslandManager.islandSize
        case .notch:
            islandTopPadding = .zero
            islandSize = Const.DynamicIslandManager.notchSize
        case .none:
            islandTopPadding = .zero
            islandSize = .zero
        }
    }

    // MARK: - CutoutType

    enum CutoutType {
        case dynamicIsland
        case notch
        case none
    }

    // MARK: - Internal Properties

    /// The type of the screen cutout on this device.
    let cutoutType: CutoutType

    /// Returns whether this device has the Dynamic Island.
    var isIslandAvailable: Bool {
        cutoutType == .dynamicIsland
    }

    /// Returns whether this device has any screen cutout (Dynamic Island or notch).
    var isCutoutAvailable: Bool {
        cutoutType != .none
    }

    /// The top padding of the Dynamic Island cutout.
    let islandTopPadding: CGFloat

    /// The size of the Dynamic Island cutout.
    let islandSize: CGSize

    // MARK: - Private Properties

    private static let exclusionAreaKey = "_exclusionArea"

    // MARK: - Private Methods

    /// The frame of the screen cutout (Dynamic Island or notch) in screen points, as reported by the system.
    /// Relies on the private `UIScreen._exclusionArea` API, which returns `nil` on devices without a cutout.
    private static func systemCutoutFrame(of screen: UIScreen) -> CGRect? {
        guard
            let area = screen.value(forKey: exclusionAreaKey) as? NSObject,
            area.responds(to: NSSelectorFromString("rect")),
            let rect = area.value(forKey: "rect") as? CGRect,
            !rect.isEmpty
        else {
            return nil
        }
        return rect
    }

    /// Fallback for when the system cutout frame is unavailable.
    /// Returns `true` for iPhone 14 Pro and later models, except for the notched iPhone 16e.
    private static func isIslandAvailableForDeviceModel() -> Bool {
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
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
        let iPhone14ProMinNumber: Double = 15.0
        let notchedIdentifiers: Set<String> = ["iPhone17,5"]
        guard identifier.hasPrefix(prefix), !notchedIdentifiers.contains(identifier) else { return false }
        let model = identifier.dropFirst(prefix.count).replacingOccurrences(of: ",", with: ".")
        guard let modelNumber = Double(model) else { return false }
        return modelNumber > iPhone14ProMinNumber
    }
}
