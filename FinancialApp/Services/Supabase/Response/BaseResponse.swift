//
//  BaseResponse.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

struct BaseResponse<TData: Decodable & Sendable>: Decodable, Sendable {
  let success: Bool
  let message: String
  let data: TData
}
