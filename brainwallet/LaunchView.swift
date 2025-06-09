import SwiftUI

struct LaunchView: View {
	var body: some View {
		GeometryReader { _ in
			ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
			}
		}
	}
}

#Preview {
	LaunchView()
}
