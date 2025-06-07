
import Lottie
import UIKit
import SwiftUI

struct WelcomeLottieView: UIViewRepresentable {
  let lottieFileName: String
  let shouldRunAnimation: Bool
  private let animationView = LottieAnimationView()
  func makeUIView(context _: UIViewRepresentableContext<WelcomeLottieView>) -> UIView {
    let view = UIView(frame: .zero)
    animationView.animation = LottieAnimation.named(lottieFileName)
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .loop
    animationView.backgroundColor = UIColor(Color("brainwalletSurface"))
    animationView.layer.cornerRadius = 10.0
    animationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(animationView)
    NSLayoutConstraint.activate([
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])
    return view
  }
  func updateUIView(_: UIViewType, context: UIViewRepresentableContext<WelcomeLottieView>) {
    if shouldRunAnimation {
      context.coordinator.parent.animationView.play()
    } else {
      context.coordinator.parent.animationView.stop()
    }
  }
  class Coordinator: NSObject {
    var parent: WelcomeLottieView
    init(_ parent: WelcomeLottieView) {
      self.parent = parent
    }
  }
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
