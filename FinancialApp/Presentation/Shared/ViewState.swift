import SwiftUI

// MARK: - View State Enum
enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
    case empty
}

// MARK: - View State View
struct ViewStateView<T, Content: View, EmptyView: View, ErrorView: View>: View {
    let state: ViewState<T>
    let content: (T) -> Content
    let emptyView: () -> EmptyView
    let errorView: (Error) -> ErrorView
    let retry: (() -> Void)?
    
    init(
        state: ViewState<T>,
        @ViewBuilder content: @escaping (T) -> Content,
        @ViewBuilder emptyView: @escaping () -> EmptyView = { DefaultEmptyView() },
        @ViewBuilder errorView: @escaping (Error) -> ErrorView = { error in DefaultErrorView(error: error) },
        retry: (() -> Void)? = nil
    ) {
        self.state = state
        self.content = content
        self.emptyView = emptyView
        self.errorView = errorView
        self.retry = retry
    }
    
    var body: some View {
        ZStack {
            switch state {
            case .idle:
                Color.clear
                
            case .loading:
                LoadingStateView()
                
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
                
            case .empty:
                emptyView()
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
        case .empty: return "empty"
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