//
//  AuthenticationStore.swift
//  ExpenseTracker
//
//  Created by Rifqi on 23/07/25.
//

import Observation
import Supabase


enum AuthState {
    case loading
    case authenticated
    case unauthenticated
}

@Observable
class AuthenticationStore {
  var authState: AuthState = .loading
  
  func checkAuthentication() async {
    for await state in SupabaseManager.shared.client.auth.authStateChanges {
      if [.initialSession, .signedIn, .signedOut].contains(state.event) {
        authState = state.session == nil ? .unauthenticated : .authenticated
      } else if .signedOut == state.event {
        authState = .unauthenticated
      }
    }
  }
}

