//
//  PullToRefresh.swift
//  Collart
//

import SwiftUI

// Two type of positioning views
private enum PositionType {
    case fixed, moving
}

private struct Position: Equatable {
    let type: PositionType
    let y: CGFloat
}

private struct PositionPreferenceKey: PreferenceKey {
    typealias Value = [Position]
    
    static var defaultValue = [Position]()
    
    static func reduce(value: inout [Position], nextValue: () -> [Position]) {
        value.append(contentsOf: nextValue())
    }
}

private struct PositionIndicator: View {
    let type: PositionType
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: PositionPreferenceKey.self, value: [Position(type: type, y: proxy.frame(in: .global).minY)])
        }
    }
}

// Callback
public typealias RefreshComplete = () -> Void

public typealias OnRefresh = (@escaping RefreshComplete) -> Void

// The offset threshold
public let defaultRefreshThreshold: CGFloat = 68

// Tracks the state of the RefreshableScrollView
public enum RefreshState {
    case waiting, primed, loading
}

// ViewBuilder for the custom progress View
public typealias RefreshProgressBuilder<Progress: View> = (RefreshState) -> Progress

// Default color of the rectangle behind the progress spinner
public let defaultLoadingViewBackgroundColor = Color(UIColor.systemBackground)

public struct RefreshableScrollView<Progress, Content>: View where Progress: View, Content: View {
    let showsIndicators: Bool // If the ScrollView should show indicators
    let shouldTriggerHapticFeedback: Bool // If key actions should trigger haptic feedback
    let loadingViewBackgroundColor: Color
    let threshold: CGFloat // What height do you have to pull down to trigger the refresh
    let onRefresh: OnRefresh // The refreshing action
    let progress: RefreshProgressBuilder<Progress> // Custom progress view
    let content: () -> Content // The ScrollView content
    @State private var offset: CGFloat = 0
    @State private var state = RefreshState.waiting // The current state
    
    // Haptic Feedback
    let finishedReloadingFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let primedFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    public init(showsIndicators: Bool = true,
                shouldTriggerHapticFeedback: Bool = false,
                loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                threshold: CGFloat = defaultRefreshThreshold,
                onRefresh: @escaping OnRefresh,
                @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>,
                @ViewBuilder content: @escaping () -> Content) {
        self.showsIndicators = showsIndicators
        self.shouldTriggerHapticFeedback = shouldTriggerHapticFeedback
        self.loadingViewBackgroundColor = loadingViewBackgroundColor
        self.threshold = threshold
        self.onRefresh = onRefresh
        self.progress = progress
        self.content = content
    }
    
    public var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                PositionIndicator(type: .moving)
                    .frame(height: 0)
                
                content()
                    .alignmentGuide(.top, computeValue: { _ in
                        (state == .loading) ? -threshold + max(0, offset) : 0
                    })
                    .animation(.default, value: state)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(loadingViewBackgroundColor)
                        .frame(height: threshold)
                    progress(state)
                }.offset(y: (state == .loading) ? -max(0, offset) : -threshold)
            }
        }
        .background(PositionIndicator(type: .fixed))
        .onPreferenceChange(PositionPreferenceKey.self) { values in
            DispatchQueue.main.async {
                let movingY = values.first { $0.type == .moving }?.y ?? 0
                let fixedY = values.first { $0.type == .fixed }?.y ?? 0
                offset = movingY - fixedY
                if state != .loading {
                    if offset > threshold && state == .waiting {
                        state = .primed
                        if shouldTriggerHapticFeedback {
                            self.primedFeedbackGenerator.impactOccurred()
                        }
                    } else if offset < threshold && state == .primed {
                        state = .loading
                        onRefresh {
                            self.state = .waiting
                            if shouldTriggerHapticFeedback {
                                self.finishedReloadingFeedbackGenerator.impactOccurred()
                            }
                        }
                    }
                }
            }
        }
    }
}

public extension RefreshableScrollView where Progress == RefreshActivityIndicator {
    init(showsIndicators: Bool = true,
         loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
         threshold: CGFloat = defaultRefreshThreshold,
         onRefresh: @escaping OnRefresh,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(showsIndicators: showsIndicators,
                  loadingViewBackgroundColor: loadingViewBackgroundColor,
                  threshold: threshold,
                  onRefresh: onRefresh,
                  progress: { state in
            RefreshActivityIndicator(isAnimating: state == .loading) {
                $0.hidesWhenStopped = false
            }
        },
                  content: content)
    }
}

public struct RefreshActivityIndicator: UIViewRepresentable {
    public typealias UIView = UIActivityIndicatorView
    public var isAnimating: Bool = true
    public var configuration = { (indicator: UIView) in }
    
    public init(isAnimating: Bool, configuration: ((UIView) -> Void)? = nil) {
        self.isAnimating = isAnimating
        if let configuration = configuration {
            self.configuration = configuration
        }
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        UIView()
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

#if compiler(>=5.5)
@available(iOS 15.0, *)
public extension RefreshableScrollView {
    init(showsIndicators: Bool = true,
         loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
         threshold: CGFloat = defaultRefreshThreshold,
         action: @escaping @Sendable () async -> Void,
         @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(showsIndicators: showsIndicators,
                  loadingViewBackgroundColor: loadingViewBackgroundColor,
                  threshold: threshold,
                  onRefresh: { refreshComplete in
            Task {
                await action()
                refreshComplete()
            }
        },
                  progress: progress,
                  content: content)
    }
}
#endif

public struct RefreshableCompat<Progress>: ViewModifier where Progress: View {
    private let showsIndicators: Bool
    private let loadingViewBackgroundColor: Color
    private let threshold: CGFloat
    private let onRefresh: OnRefresh
    private let progress: RefreshProgressBuilder<Progress>
    
    public init(showsIndicators: Bool = true,
                loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                threshold: CGFloat = defaultRefreshThreshold,
                onRefresh: @escaping OnRefresh,
                @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>) {
        self.showsIndicators = showsIndicators
        self.loadingViewBackgroundColor = loadingViewBackgroundColor
        self.threshold = threshold
        self.onRefresh = onRefresh
        self.progress = progress
    }
    
    public func body(content: Content) -> some View {
        RefreshableScrollView(showsIndicators: showsIndicators,
                              loadingViewBackgroundColor: loadingViewBackgroundColor,
                              threshold: threshold,
                              onRefresh: onRefresh,
                              progress: progress) {
            content
        }
    }
}

#if compiler(>=5.5)
@available(iOS 15.0, *)
public extension List {
    @ViewBuilder func refreshableCompat<Progress: View>(showsIndicators: Bool = true,
                                                        loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                                                        threshold: CGFloat = defaultRefreshThreshold,
                                                        onRefresh: @escaping OnRefresh,
                                                        @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>) -> some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            self.refreshable {
                await withCheckedContinuation { cont in
                    onRefresh {
                        cont.resume()
                    }
                }
            }
        } else {
            self.modifier(RefreshableCompat(showsIndicators: showsIndicators,
                                            loadingViewBackgroundColor: loadingViewBackgroundColor,
                                            threshold: threshold,
                                            onRefresh: onRefresh,
                                            progress: progress))
        }
    }
}
#endif

public extension View {
    @ViewBuilder func refreshableCompat<Progress: View>(showsIndicators: Bool = true,
                                                        loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                                                        threshold: CGFloat = defaultRefreshThreshold,
                                                        onRefresh: @escaping OnRefresh,
                                                        @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>) -> some View {
        self.modifier(RefreshableCompat(showsIndicators: showsIndicators,
                                        loadingViewBackgroundColor: loadingViewBackgroundColor,
                                        threshold: threshold,
                                        onRefresh: onRefresh,
                                        progress: progress))
    }
}
