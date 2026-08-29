//
//  ToggleCellView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - ToggleCellView

struct ToggleCellView: View {

    // MARK: - Internal Properties

    var parameterName: String = ""
    @Binding var isToggleOn: Bool
    var showToggle = true

    // MARK: - Body

    var body: some View {
        HStack {
            Text(makeToggleTitle(parameterName: parameterName, isEnabled: isToggleOn))
                .font(.callout)
                .lineLimit(1)

            Spacer()

            if showToggle {
                Toggle("", isOn: $isToggleOn)
                    .frame(maxWidth: 50)
            }
        }
        .padding([.all], 16)
        .frame(maxWidth: .infinity, maxHeight: 44)
        .background(.background)
        .cornerRadius(12)
    }

    // MARK: - Private Methods

    private func makeToggleTitle(parameterName: String, isEnabled: Bool) -> String {
        guard showToggle else { return "" }
        return parameterName + " " + (isEnabled ? Const.ToggleCellView.enabledTitle : Const.ToggleCellView.disabledTitle)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(uiColor: .systemGray6)

        VStack {
            ToggleCellView(parameterName: "Not Long Title", isToggleOn: .constant(true))
            ToggleCellView(parameterName: "Long Title Very Long Title Title Title Title", isToggleOn: .constant(false))
            ToggleCellView(parameterName: "Empty", isToggleOn: .constant(true), showToggle: false)
        }
        .padding()
    }
    .ignoresSafeArea()
}
