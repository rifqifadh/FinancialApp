//
//  SupabaseManager.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


import Supabase
import Foundation

class  SupabaseManager {
  nonisolated(unsafe) static let shared = SupabaseManager()
  
  let client: SupabaseClient
  
  private init() {
    // TODO: Replace with your actual values
    
    guard let supabaseURL = URL(string: ""),
          let supabaseKey = "" as String? else {
      fatalError("Missing Supabase configuration")
    }
    
    client = SupabaseClient(
      supabaseURL: supabaseURL,
      supabaseKey: supabaseKey
    )
  }
}
