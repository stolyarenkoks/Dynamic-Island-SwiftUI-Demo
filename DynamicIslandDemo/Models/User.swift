//
//  User.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import Foundation

// MARK: - User

struct User {
    let fullName: String
    let avatarImageName: String
    let phoneNumber: String
    let nickname: String
    let linkedInURL: String
}

// MARK: - User Mock Extension

extension User {

    static func mock(
        fullName: String = "Konstantin Stolyarenko",
        avatarImageName: String = "avatar-image",
        phoneNumber: String = "+380 66 666 6666",
        nickname: String = "@stolyarenkoks",
        linkedInURL: String = "konstantinstolyarenko"
    ) -> Self {
        .init(
            fullName: fullName,
            avatarImageName: avatarImageName,
            phoneNumber: phoneNumber,
            nickname: nickname,
            linkedInURL: linkedInURL
        )
    }
}
