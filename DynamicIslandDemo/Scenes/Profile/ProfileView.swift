//
//  ProfileView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.11.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {

    // MARK: - Private Properties

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { bounds in
            ZStack(alignment: .top) {
                if viewModel.isIslandShapeVisible {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                        context.addFilter(.blur(radius: 6))
                        context.drawLayer { ctx in
                            if let island = ctx.resolveSymbol(id: Const.MainView.islandViewId) {
                                ctx.draw(island, at: CGPoint(x: (size.width / 2),
                                                             y: viewModel.islandTopPadding + (viewModel.islandSize.height / 2)))
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
        .onChange(of: scenePhase) { newPhase in
            let isActive = newPhase == .active
            let duration = isActive ? 0.3 : .zero
            withAnimation(Animation.linear(duration: duration).delay(duration)) {
                viewModel.isIslandShapeVisible = isActive
            }
        }
    }

    // MARK: - Private Methods

    private func islandShapeView() -> some View {
        Capsule(style: .continuous)
            .frame(width: viewModel.islandSize.width,
                   height: viewModel.islandSize.height,
                   alignment: .center)
            .scaleEffect(viewModel.islandScale)
            .tag(Const.MainView.islandViewId)
    }

    private func avatarShapeView() -> some View {
        Circle()
            .fill(.black)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .scaleEffect(viewModel.scale)
            .offset(y: max(-viewModel.offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(20)))
            .tag(Const.MainView.imageViewId)
    }

    private func avatarView() -> some View {
        Image(viewModel.userAvatarImageName)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .clipShape(Circle())
            .scaleEffect(viewModel.scale)
            .blur(radius: viewModel.blur)
            .opacity(viewModel.avatarOpacity)
            .offset(y: max(-viewModel.offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(10)))
            .padding(.top, Const.MainView.imageTopPadding)
    }

    private func scrollView() -> some View {
        OffsetObservingScrollView(
            offset: $viewModel.offset,
            showsIndicators: $viewModel.showsIndicators,
            isHeaderPagingEnabled: $viewModel.isHeaderPagingEnabled
        ) {
            LazyVStack(
                alignment: .center,
                pinnedViews: viewModel.isHeaderPinningEnabled ? [.sectionHeaders] : []
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
            Text(viewModel.userName)
                .font(.system(size: viewModel.titleFontSize, weight: .medium))

            HStack(spacing: 4.0) {
                Text(viewModel.userPhoneNumber)
                Text(Const.General.bulletPointSymbol)
                Text(viewModel.userNickname)
            }
            .foregroundColor(Color(uiColor: .systemGray))
            .font(.system(size: viewModel.descriptionFontSize, weight: .regular))
            .opacity(viewModel.headerOpacity)
            .padding(.bottom, viewModel.headerPadding)
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
            ToggleCellView(parameterName: "Indicators", isToggleOn: $viewModel.showsIndicators)
            ToggleCellView(parameterName: "Zoom Effect", isToggleOn: $viewModel.isZoomEffectEnabled)
        }
    }

    private func headerSettingsCells() -> some View {
        VStack {
            ToggleCellView(parameterName: "Header Paging", isToggleOn: $viewModel.isHeaderPagingEnabled)
            ToggleCellView(parameterName: "Header Pinning", isToggleOn: $viewModel.isHeaderPinningEnabled)
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
            if viewModel.isAvatarHidden {
                Button {
                    print("QR button tapped")
                } label: {
                    Image(systemName: "qrcode").imageScale(.large)
                }
                .opacityTransition(move: .top)
            }

            Spacer()

            Button {
                print("\(viewModel.isAvatarHidden ? "Edit" : "Search") button tapped")
            } label: {
                if viewModel.isAvatarHidden {
                    AnyView(Text("Edit"))
                        .opacityTransition(move: .top)
                } else {
                    if viewModel.isHeaderPinningEnabled {
                        AnyView(Image(systemName: "magnifyingglass").imageScale(.large))
                            .opacityTransition(move: .bottom)
                    }
                }
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.top, 4.0)
        .onChange(
            of: viewModel.percentage,
            perform: { value in
                withAnimation(.linear(duration: 0.2)) {
                    viewModel.isAvatarHidden = !(value == 100)
                }
            }
        )
    }
}

// MARK: - PreviewProvider

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileView(viewModel: .init(user: .mock()))
    }
}
