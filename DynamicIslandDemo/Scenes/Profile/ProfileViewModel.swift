//
//  ProfileViewModel.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.11.2023.
//

import Foundation
import SwiftUI

extension ProfileView {

    // MARK: - ViewModel

    @MainActor class ViewModel: ObservableObject {

        // MARK: - Internal Properties

        @Published var showsIndicators = false
        @Published var isZoomEffectEnabled = true
        @Published var isHeaderPagingEnabled = true
        @Published var isHeaderPinningEnabled = true
        @Published var isIslandShapeVisible = true
        @Published var isAvatarHidden: Bool = true

        @Published var offset: CGPoint = .zero

        var islandSize: CGSize {
            DynamicIslandManager.shared.islandSize
        }

        var islandTopPadding: CGFloat {
            DynamicIslandManager.shared.islandTopPadding
        }

        var percentage: CGFloat {
            return min(offset.y, Const.MainView.imageSize)
        }

        var scale: CGFloat {
            let coefficient = 1 / 1.2
            let percentage = percentage * coefficient
            let scale = (percentage * (0 - 1) / 100) + 1
            return min(scale, 1)
        }

        var islandScale: CGFloat {
            let coefficient: CGFloat = isZoomEffectEnabled ? 1.1 : 1.0
            var scaleFactor: CGFloat = 1
            scaleFactor = abs((offset.y / 1.5) - islandSize.height) / islandSize.height
            let percentage = min(max(scaleFactor, .zero), 1)
            return (percentage * (1 - coefficient)) + coefficient
        }

        var avatarOpacity: CGFloat {
            let coefficient = 2.2
            let percentage = percentage * coefficient
            let opacity = (percentage * (0 - 1) / 100) + 1
            return min(opacity, 1)
        }

        var headerOpacity: CGFloat {
            let coefficient = 1.0
            let percentage = percentage * coefficient
            let opacity = (percentage * (0 - 1) / 100) + 1
            return min(opacity, 1)
        }

        var blur: CGFloat {
            let coefficient = 3.5
            let percentage = percentage * coefficient
            let opacity = (percentage * (0 - 1) / 100) + 1
            return 1 - min(opacity, 1)
        }

        var userAvatarImageName: String {
            user.avatarImageName
        }

        var userName: String {
            user.name
        }

        var userPhoneNumber: String {
            user.phoneNumber
        }

        var userNickname: String {
            user.nickname
        }

        var titleFontSize: CGFloat {
            interpolateValue(minValue: 18.0, maxValue: 32.0, percent: 100 - percentage)
        }

        var descriptionFontSize: CGFloat {
            interpolateValue(minValue: 14.0, maxValue: 17.0, percent: 100 - percentage)
        }

        var headerPadding: CGFloat {
            interpolateValue(maxValue: 18.0, percent: 100 - percentage)
        }

        // MARK: - Private Properties

        private let user: User

        // MARK: - Init

        init(user: User = .mock()) {
            self.user = user

            setup()
        }

        // MARK: - Private Methods

        private func setup() {
            isZoomEffectEnabled = DynamicIslandManager.shared.isIslandAvailable
        }

        private func interpolateValue(minValue: Double = .zero, maxValue: Double, percent: Double) -> Double {
            let value = minValue + (maxValue - minValue) * (percent / 100)
            let balancedValue = min(max(value, minValue), maxValue)
            return balancedValue
        }
    }
}
