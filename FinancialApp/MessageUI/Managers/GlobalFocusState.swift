//
//  GlobalFocusState.swift
//  ExpenseTracker
//
//  Created by Rifqi on 22/08/25.
//


//
//  Created by Alex.M on 23.06.2022.
//

import Observation
import Combine

@Observable
final class GlobalFocusState: ObservableObject {
    var focus: Focusable?
}
