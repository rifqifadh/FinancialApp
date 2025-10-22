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

@MainActor
final class GlobalFocusState: ObservableObject {
    @Published var focus: Focusable? 
}
