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

    private var scale: CGFloat {
        let coefficient = 1 / 1.2
        let percentage = min(offset.y, Const.MainView.imageSize) * coefficient
        let scale = (percentage * (0 - 1) / 100) + 1
        return min(scale, 1)
    }

    private var islandScale: CGFloat {
        let coefficient: CGFloat = isZoomEffectEnabled ? 1.1 : 1.0
        var scaleFactor: CGFloat = 1
        scaleFactor = abs((offset.y / 1.5) - islandSize.height) / islandSize.height
        let perc = min(max(scaleFactor, .zero), 1)
        let scale = (perc * (1 - coefficient)) + coefficient
        return scale
    }

    private var opacity: CGFloat {
        let coefficient = 2.2
        let percentage = min(offset.y, Const.MainView.imageSize) * coefficient
        let opacity = (percentage * (0 - 1) / 100) + 1
        return min(opacity, 1)
    }

    private var blur: CGFloat {
        let coefficient = 3.5
        let percentage = min(offset.y, Const.MainView.imageSize) * coefficient
        let opacity = (percentage * (0 - 1) / 100) + 1
        return 1 - min(opacity, 1)
    }

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
            }
        }
        .background(Color(uiColor: .systemGray5))
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
            .opacity(opacity)
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
        VStack(spacing: 8.0) {
            Text(user.fullName)
                .font(.title)
                .bold()

            HStack {
                Text(user.phoneNumber)

                Text(Const.General.bulletPointSymbol)

                Text(user.nickname)
            }
            .font(.callout)
            .foregroundColor(Color(uiColor: .systemGray))

            HStack {
                Image("linkedIn-logo")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(user.linkedInURL)
                    .font(.callout)
                    .foregroundColor(Color("linkedIn-color"))
            }
        }
        .padding(.bottom, 16.0)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray5))
        .id(Const.MainView.headerViewId)
    }

    private func scrollViewCells() -> some View {
        VStack {
            customToggleCells()
            emptyCells()
        }
    }

    private func customToggleCells() -> some View {
        VStack {
            ToggleCellView(parameterName: "Indicators", isToggleOn: $showsIndicators)

            if DynamicIslandManager.shared.isIslandAvailable {
                ToggleCellView(parameterName: "Zoom Effect", isToggleOn: $isZoomEffectEnabled)
            }

            ToggleCellView(parameterName: "Header Paging", isToggleOn: $isHeaderPagingEnabled)
            ToggleCellView(parameterName: "Header Pinning", isToggleOn: $isHeaderPinningEnabled)
        }
    }

    private func emptyCells() -> some View {
        VStack {
            ForEach(0..<10) { _ in
                ToggleCellView(isToggleOn: .constant(false), showToggle: false)
            }
        }
    }
}

// MARK: - PreviewProvider

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileScene()
    }
}
