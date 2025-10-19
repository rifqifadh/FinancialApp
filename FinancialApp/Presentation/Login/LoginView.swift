//
//  LoginView.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Supabase

struct LoginView: View {
  @State private var isAuthenticated = false
  @State private var errorMessage: String?
  
  var body: some View {
    VStack(spacing: 20) {
      if isAuthenticated {
        Text("🎉 You’re signed in with Google!")
      } else {
        GoogleSignInButton {
          Task {
            await handleSignInButton()
          }
        }
      }
      
    }
    .padding()
  }
  
  @MainActor
  func handleSignInButton() async {
    do {
      guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
      let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
      
      guard let idToken = result.user.idToken?.tokenString else {
        print("No idToken found.")
        return
      }
      
      let accessToken = result.user.accessToken.tokenString
      let response = try await SupabaseManager.shared.client.auth.signInWithIdToken(
        credentials: OpenIDConnectCredentials(
          provider: .google,
          idToken: idToken,
          accessToken: accessToken
        )
      )
      
      let userId = response.user.id.uuidString.lowercased()
      
      let existingUser: UserResponse? = try await SupabaseManager.shared.client
        .from("users")
        .select()
        .eq("id", value: userId)
        .single()
        .execute()
        .value
      
      if existingUser == nil {
        try await SupabaseManager.shared.client
          .from("users")
          .insert([
            "id": userId,
            "full_name": response.user.userMetadata["name"]?.stringValue ?? "",
            "avatar_url": response.user.userMetadata["avatar_url"]?.stringValue,
            "email": response.user.email
          ])
          .execute()
      }
    } catch {
      print("Error signing in: \(error.localizedDescription)")
    }
  }
}

#Preview {
  LoginView()
}
