import SwiftUI

struct LaunchView: View {
	var body: some View {
		GeometryReader { _ in
			ZStack {
                Color.midnight.edgesIgnoringSafeArea(.all)
			}
		}
	}
}

#Preview {
	LaunchView()
}
