import SwiftUI

struct IntroStepView: View {
	@EnvironmentObject
	var viewModel: StartViewModel

	let paragraphFont: Font = .barlowBold(size: 35.0)

	let genericPad = 5.0

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width

			ZStack {
				CreateStepConfig
					.intro
					.backgroundColor
					.edgesIgnoringSafeArea(.all)
				VStack {
					Text("Take the next 5 minutes to secure your Litecoin.")
						.font(paragraphFont)
						.foregroundColor(BrainwalletColor.content)
						.frame(width: width * 0.9, alignment: .leading)
						.padding([.leading, .trailing], genericPad)
						.padding([.bottom], genericPad)

					Text("S.CreateStep.ExtendedMessage.intro")
						.font(paragraphFont)
                        .foregroundColor(BrainwalletColor.content)
						.frame(width: width * 0.9, alignment: .leading)
						.padding([.leading, .trailing], genericPad)
						.padding([.bottom], genericPad)
				}
				.frame(width: width * 0.9)
			}
		}
	}
}

#Preview {
	IntroStepView()
}

//                    let pushOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
//                    UNUserNotificationCenter.current().requestAuthorization(options: pushOptions) { granted, error in
//                        if granted {
//                            DispatchQueue.main.async {
//                                UIApplication.shared.registerForRemoteNotifications()
//                            }
//                        }
//                        if let error = error {
//                            print("[PushNotifications] - \(error.localizedDescription)")
//                        }
//                    }

//
// func registerPushNotification(_ application: UIApplication){
//
//    UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
//
//        if granted {
//            print("Notification: Granted")
//
//        } else {
//            print("Notification: not granted")
//
//        }
//    }
//
//    application.registerForRemoteNotifications()
// }
//
// }

//                    Button(action: {
//                        //
//                        viewModel.didTapIndex = 1
//                    }) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: bigButtonCornerRadius)
//                                .frame(width: width * 0.6, height: 60, alignment: .center)
//                                .foregroundColor(.brainwalletGray)
//                                .shadow(radius: 3, x: 3.0, y: 3.0)
//
//                            Text("Ok" )
//                                .frame(width: width * 0.6, height: 60, alignment: .center)
//                                .font(paragraphFont)
//                                .foregroundColor(BrainwalletUIColor.info)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: bigButtonCornerRadius)
//                                        .stroke(.white, lineWidth: 2.0)
//                                )
//                        }
//                    }
//                    .padding(.all, 8.0)

//                    viewModel.updatePushPreference(didAcceptPush: didAcceptPush)
