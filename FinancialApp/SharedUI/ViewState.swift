//
//  ViewState.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//


import SwiftUI

// MARK: - View State Enum
enum ViewState<T>: Equatable where T: Equatable  {
  static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (.loading, .loading):
      return true
    case (.success(let lhsData), .success(let rhsData)):
      return lhsData == rhsData
    case (.error(let lhsError), .error(let rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    default:
      return false
    }
  }
  
  case idle
  case loading
  case success(T)
  case error(Error)
}

// MARK: - View State View
struct ViewStateView<T: Equatable, Content: View, Loading: View, ErrorView: View>: View {
  let state: ViewState<T>
  let content: (T) -> Content
  let loadingView: () -> Loading
  let errorView: (Error) -> ErrorView
  let retry: (() -> Void)?
  
  init(
    state: ViewState<T>,
    @ViewBuilder content: @escaping (T) -> Content,
    @ViewBuilder loadingView: @escaping () -> Loading = { LoadingStateView() },
    @ViewBuilder errorView: @escaping (Error) -> ErrorView = { error in DefaultErrorView(error: error) },
    retry: (() -> Void)? = nil
  ) {
    self.state = state
    self.content = content
    self.loadingView = loadingView
    self.errorView = errorView
    self.retry = retry
  }
  
  var body: some View {
    ZStack {
      switch state {
      case .idle:
        Color.clear
        
      case .loading:
        loadingView()
        
      case .success(let data):
        content(data)
        
      case .error(let error):
        VStack {
          errorView(error)
          if let retry = retry {
            Button(action: retry) {
              Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .padding(.top)
          }
        }
      }
    }
    .animation(.easeInOut, value: state.id)
  }
}


// MARK: - ViewState Identifiable Extension
extension ViewState: Identifiable {
  var id: String {
    switch self {
    case .idle: return "idle"
    case .loading: return "loading"
    case .success: return "success"
    case .error: return "error"
    }
  }
}

// MARK: - Loading State View
struct LoadingStateView: View {
  var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)
      Text("Loading...")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
  }
}

// MARK: - Default Empty View
struct DefaultEmptyView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "tray")
        .font(.system(size: 60))
        .foregroundColor(.secondary)
      Text("No Data Available")
        .font(.headline)
        .foregroundColor(.secondary)
    }
  }
}

// MARK: - Default Error View
struct DefaultErrorView: View {
  let error: Error
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 60))
        .foregroundColor(.red)
      Text("Something went wrong")
        .font(.headline)
      Text(error.localizedDescription)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
  }
}


extension ViewState where T: RangeReplaceableCollection {
  mutating func append(_ element: T.Element) {
    if case .success(var data) = self {
      data.append(element)
      self = .success(data)
    }
  }
  
  mutating func append(contentsOf elements: T) {
    if case .success(var data) = self {
      data.append(contentsOf: elements)
      self = .success(data)
    }
  }
}

extension ViewState where T: RangeReplaceableCollection & MutableCollection, T.Element: Identifiable {
  mutating func updateElement(withId id: T.Element.ID, using transform: (inout T.Element) -> Void) {
    if case .success(var data) = self {
      if let index = data.firstIndex(where: { $0.id == id }) {
        transform(&data[index])
        self = .success(data)
      }
    }
  }
  
  mutating func removeElement(withId id: T.Element.ID) {
    if case .success(var data) = self {
      data.removeAll { $0.id == id }
      self = .success(data)
    }
  }
  
  func getData() -> T? {
    if case .success(let data) = self {
      return data
    }
    return nil
  }
}
