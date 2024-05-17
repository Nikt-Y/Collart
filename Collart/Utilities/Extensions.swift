//
//  Extensions.swift
//  Collart
//

import SwiftUI

// MARK: - FadeInScale
extension AnyTransition {
    static var fadeInAndScale: AnyTransition {
        let insertion = AnyTransition.opacity.combined(with: .scale)
        let removal = AnyTransition.scale.combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

// MARK: - Navigation Pop Gesture
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

// MARK: - Hide Keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Toast
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var isShowing: Bool = false
    @Published var message: String = ""
    
    private init() {}
    
    func show(message: String) {
        withAnimation {
            self.message = message
            self.isShowing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.isShowing = false
            }
        }
    }
}

struct ToastView: View {
    @ObservedObject var toastManager = ToastManager.shared
    
    var body: some View {
        VStack {
            Spacer()
            if toastManager.isShowing {
                Text(toastManager.message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: toastManager.isShowing)
            }
        }
    }
}

// MARK: - Date format
extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}
