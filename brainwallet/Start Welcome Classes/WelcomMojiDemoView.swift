import UIKit
import SwiftUI
import SpriteKit
import FirebaseAnalytics

struct WelcomeMojiDemoView: View {

    @Environment(\.requestReview)
    private var requestReview

    @Binding
    var shouldPlay: Bool

    @State
    private var counter: Int = 0

    @State
    private var didStartGame: Bool = true

    @Binding
    var userWantsToExit: Bool

    @State
    private var countdown: TimeInterval = 30.0

    @State
    private var mainGradientStyle: MainGradientStyle = .darkStyle

    @State
    private var welcomeScene: WelcomeFallinScene?

    var width: CGFloat = 0.0
    var height: CGFloat = 0.0

    var gameIsInWelcomeMode: Bool = false

    init(width: CGFloat,
         height: CGFloat,
         shouldPlay: Binding<Bool>,
         userWantsToExit: Binding<Bool>,
         gameIsInWelcomeMode: Bool) {
        _shouldPlay = shouldPlay
        _userWantsToExit = userWantsToExit
        self.gameIsInWelcomeMode = gameIsInWelcomeMode
        self.height = height
        self.width = width
    }

    private func makeScene() -> WelcomeFallinScene {
        let scene = WelcomeFallinScene(width: width,
                                       height: height,
                                       counter: $counter,
                                       countdown: $countdown,
                                       didStartGame: $didStartGame)
        scene.size = CGSize(width: width, height: height)
        scene.scaleMode = .fill
        scene.width = width
        scene.height = height
        scene.backgroundColor = .clear
        return scene
    }

    private func placeholderScene() -> SKScene {
        let scene = SKScene(size: CGSize(width: max(width, 1), height: max(height, 1)))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        return scene
    }
    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                Image("welcome-bk")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .cornerRadius(bentoCornerRadius)
                    .overlay {
                        RoundedRectangle(cornerRadius: bentoCornerRadius)
                            .stroke(BentoColor.purple4,
                                    lineWidth: 2)
                    }
                VStack {
                    SpriteView(scene: welcomeScene ?? placeholderScene(),
                               options: [.allowsTransparency])
                    .frame(width: width, height: height)
                    .onAppear {
                        if welcomeScene == nil {
                            welcomeScene = makeScene()
                        }
                    }
                    .cornerRadius(bentoCornerRadius)
                    Spacer()
                }

                VStack {
                    HStack {
                        Text("\(counter)")
                            .modifier(BWBoldenVan(size: 35))
                            .padding(.top, 8)
                            .padding([.trailing], 24)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white,.white, BentoColor.gameBlue1.opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    Spacer()
                }

                VStack {

                    Text( String(format: "%.2f", countdown))
                        .modifier(BWBoldenVan(size: 35))
                        .padding(.top, 8)
                        .padding([.leading], 24)

                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white,.white, BentoColor.gameBlue1.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()

                }

                if !gameIsInWelcomeMode {

                    VStack(alignment: .center) {

                        Button {
                            userWantsToExit.toggle()
                            Analytics.logEvent("did_exit_demo_game",
                                parameters: [
                                    "platform": "ios",
                                    "app_version": AppVersion.string
                                ])
                        } label: {
                            Text("Exit")
                                .modifier(BWIPSLight(size: 30))
                                .padding(.top, 8)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white,.white, BentoColor.gameBlue1.opacity(0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        .frame(alignment: .center)
                        .padding(8.0)

                        Spacer()
                    }
                }

                if !didStartGame {
                    HStack {
                        Button {
                            didStartGame.toggle()
                            welcomeScene?.startGame()
                            Analytics.logEvent("did_start_demo_game",
                                parameters: [
                                    "platform": "ios",
                                    "app_version": AppVersion.string
                                ])
                        } label: {
                            VStack {
                                Text("Start! \nTap & score")
                                    .modifier(BWBoldenVan(size: 50, lineLimit: 2))
                                    .frame(width: 200, height: 95)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white,.white, BentoColor.progressGreen2.opacity(0.4)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color:
                                                Color.black.opacity(0.3),
                                            radius: 10)
                                    .padding(4)
                            }
                        }
                        .padding(20.0)
                        .cornerRadius(20.0)
                    }
                }
            }
            .frame(width: width, height: height)
        }
        .onAppear {
            requestReview()
            Analytics.logEvent("did_request_rating",
                parameters: [
                    "platform": "ios",
                    "app_version": AppVersion.string,
                    "request_placement": String(describing: type(of: WelcomeMojiDemoView.self))
                ])
        }
        .onDisappear {
            welcomeScene = nil
            didStartGame = false
        }
    }
}
