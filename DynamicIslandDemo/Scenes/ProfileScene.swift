//
//  ProfileScene.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - ProfileScene

struct ProfileScene: View {

    // MARK: - Private Properties

    @Environment(\.scenePhase) var scenePhase

    @State private var offset: CGPoint = .zero

    @State private var showsIndicators = false
    @State private var isZoomEffectEnabled = true
    @State private var isHeaderPagingEnabled = true
    @State private var isHeaderPinningEnabled = true
    @State private var isIslandShapeVisible = true

    private let user: User = .mock()

    private var islandSize: CGSize {
        DynamicIslandManager.shared.islandSize
    }

    private var islandTopPadding: CGFloat {
        DynamicIslandManager.shared.islandTopPadding
    }

    private var percentage: CGFloat {
        return min(offset.y, Const.MainView.imageSize)
    }

    private var scale: CGFloat {
        let coefficient = 1 / 1.2
        let percentage = percentage * coefficient
        let scale = (percentage * (0 - 1) / 100) + 1
        return min(scale, 1)
    }

    private var islandScale: CGFloat {
        let coefficient: CGFloat = isZoomEffectEnabled ? 1.1 : 1.0
        var scaleFactor: CGFloat = 1
        scaleFactor = abs((offset.y / 1.5) - islandSize.height) / islandSize.height
        let percentage = min(max(scaleFactor, .zero), 1)
        return (percentage * (1 - coefficient)) + coefficient
    }

    private var avatarOpacity: CGFloat {
        let coefficient = 2.2
        let percentage = percentage * coefficient
        let opacity = (percentage * (0 - 1) / 100) + 1
        return min(opacity, 1)
    }

    private var headerOpacity: CGFloat {
        let coefficient = 1.0
        let percentage = percentage * coefficient
        let opacity = (percentage * (0 - 1) / 100) + 1
        return min(opacity, 1)
    }

    private var blur: CGFloat {
        let coefficient = 3.5
        let percentage = percentage * coefficient
        let opacity = (percentage * (0 - 1) / 100) + 1
        return 1 - min(opacity, 1)
    }

    private var titleFontSize: CGFloat {
        interpolateValue(minValue: 18.0, maxValue: 32.0, percent: 100 - percentage)
    }

    private var descriptionFontSize: CGFloat {
        interpolateValue(minValue: 14.0, maxValue: 17.0, percent: 100 - percentage)
    }

    private var headerPadding: CGFloat {
        interpolateValue(maxValue: 18.0, percent: 100 - percentage)
    }

    @State private var isAvatarHidden: Bool = true

    // MARK: - Body

    var body: some View {
        GeometryReader { bounds in
            ZStack(alignment: .top) {
                if isIslandShapeVisible {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                        context.addFilter(.blur(radius: 6))
                        context.drawLayer { ctx in
                            if let island = ctx.resolveSymbol(id: Const.MainView.islandViewId) {
                                ctx.draw(island, at: CGPoint(x: (size.width / 2),
                                                             y: islandTopPadding + (islandSize.height / 2)))
                            }
                            if let image = ctx.resolveSymbol(id: Const.MainView.imageViewId) {
                                let yImageOffset = (Const.MainView.imageSize / 2) + Const.MainView.imageTopPadding
                                let yImagePosition = bounds.safeAreaInsets.top + yImageOffset
                                ctx.draw(image, at: CGPoint(x: size.width / 2, y: yImagePosition))
                            }
                        }
                    } symbols: {
                        islandShapeView()
                        avatarShapeView()
                    }
                    .edgesIgnoringSafeArea(.top)
                }

                avatarView()
                scrollView()
                navigationButtons()
            }
        }
        .background(Color(uiColor: .systemGray6))
        .onAppear {
            if !DynamicIslandManager.shared.isIslandAvailable {
                isZoomEffectEnabled = false
            }
        }
        .onChange(of: scenePhase) { newPhase in
            let isActive = newPhase == .active
            let duration = isActive ? 0.3 : .zero
            withAnimation(Animation.linear(duration: duration).delay(duration)) {
                isIslandShapeVisible = isActive
            }
        }
    }

    // MARK: - Private Methods

    private func islandShapeView() -> some View {
        Capsule(style: .continuous)
            .frame(width: islandSize.width, height: islandSize.height, alignment: .center)
            .scaleEffect(islandScale)
            .tag(Const.MainView.islandViewId)
    }

    private func avatarShapeView() -> some View {
        Circle()
            .fill(.black)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .scaleEffect(scale)
            .offset(y: max(-offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(20)))
            .tag(Const.MainView.imageViewId)
    }

    private func avatarView() -> some View {
        Image(user.avatarImageName)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .clipShape(Circle())
            .scaleEffect(scale)
            .blur(radius: blur)
            .opacity(avatarOpacity)
            .offset(y: max(-offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(10)))
            .padding(.top, Const.MainView.imageTopPadding)
    }

    private func scrollView() -> some View {
        OffsetObservingScrollView(
            offset: $offset,
            showsIndicators: $showsIndicators,
            isHeaderPagingEnabled: $isHeaderPagingEnabled
        ) {
            LazyVStack(
                alignment: .center,
                pinnedViews: isHeaderPinningEnabled ? [.sectionHeaders] : []
            ) {
                Section(header: headerView()) {
                    scrollViewCells()
                }
            }
            .padding(.top, Const.MainView.imageSize + Const.MainView.imageTopPadding)
            .padding(.horizontal)
        }
        .padding(.top, Const.MainView.imageTopPadding)
        .scrollDismissesKeyboard(.interactively)
    }

    private func headerView() -> some View {
        VStack(spacing: 4.0) {
            Text(user.name)
                .font(.system(size: titleFontSize, weight: .medium))

            HStack(spacing: 4.0) {
                Text(user.phoneNumber)
                Text(Const.General.bulletPointSymbol)
                Text(user.nickname)
            }
            .foregroundColor(Color(uiColor: .systemGray))
            .font(.system(size: descriptionFontSize, weight: .regular))
            .opacity(headerOpacity)
            .padding(.bottom, headerPadding)
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray6))
        .id(Const.MainView.headerViewId)
    }

    private func scrollViewCells() -> some View {
        VStack(spacing: 24.0) {
            generalSettingsCells()
            headerSettingsCells()
            emptyCells()
        }
    }

    private func generalSettingsCells() -> some View {
        VStack(spacing: 24.0) {
            ToggleCellView(parameterName: "Indicators", isToggleOn: $showsIndicators)
            ToggleCellView(parameterName: "Zoom Effect", isToggleOn: $isZoomEffectEnabled)
        }
    }

    private func headerSettingsCells() -> some View {
        VStack {
            ToggleCellView(parameterName: "Header Paging", isToggleOn: $isHeaderPagingEnabled)
            ToggleCellView(parameterName: "Header Pinning", isToggleOn: $isHeaderPinningEnabled)
        }
    }

    private func emptyCells() -> some View {
        VStack {
            ForEach(0..<15) { _ in
                ToggleCellView(isToggleOn: .constant(false), showToggle: false)
            }
        }
    }

    private func navigationButtons() -> some View {
        HStack {
            if isAvatarHidden {
                Button {
                    print("QR button tapped")
                } label: {
                    Image(systemName: "qrcode").imageScale(.large)
                }
                .opacityTransition(move: .top)
            }

            Spacer()

            Button {
                print("\(isAvatarHidden ? "Edit" : "Search") button tapped")
            } label: {
                if isAvatarHidden {
                    AnyView(Text("Edit"))
                        .opacityTransition(move: .top)
                } else {
                    if isHeaderPinningEnabled {
                        AnyView(Image(systemName: "magnifyingglass").imageScale(.large))
                            .opacityTransition(move: .bottom)
                    }
                }
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.top, 4.0)
        .onChange(
            of: percentage,
            perform: { value in
                withAnimation(.linear(duration: 0.2)) {
                    isAvatarHidden = !(value == 100)
                }
            }
        )
    }

    private func interpolateValue(minValue: Double = .zero, maxValue: Double, percent: Double) -> Double {
        let value = minValue + (maxValue - minValue) * (percent / 100)
        let balancedValue = min(max(value, minValue), maxValue)
        return balancedValue
    }
}

// MARK: - PreviewProvider

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileScene()
    }
}
