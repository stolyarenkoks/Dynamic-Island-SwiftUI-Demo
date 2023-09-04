//
//  CGFloat+Extenions.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import Foundation

// MARK: - CGFloat Extension

extension CGFloat {

    func percentage(_ perc: CGFloat) -> CGFloat {
        self * perc / 100
    }
}
