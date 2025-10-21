//
//  SupabaseManager.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


import Supabase
import Foundation

struct SupabaseEnv {
  static var url: URL {
    guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
      fatalError("SUPABASE_URL not found in Info.plist")
    }
    return URL(string: url)!
  }
  
  static var apiKey: String {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String else {
      fatalError("SUPABASE_API_KEY not found in Info.plist")
    }
    return apiKey
  }
}

struct AppLogger: SupabaseLogger {
  func log(message: SupabaseLogMessage) {
    print(message.description)
  }
}

class  SupabaseManager {
  nonisolated(unsafe) static let shared = SupabaseManager()
  
  let client: SupabaseClient
  
  private init() {
    client = SupabaseClient(
      supabaseURL: SupabaseEnv.url,
      supabaseKey: SupabaseEnv.apiKey,
      options: SupabaseClientOptions(
        global: SupabaseClientOptions.GlobalOptions(
          logger: AppLogger()
        )
      )
    )
  }
}
