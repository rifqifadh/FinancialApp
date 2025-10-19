//
//  Collection+Extension.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  Created by Alex.M on 01.07.2022.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
