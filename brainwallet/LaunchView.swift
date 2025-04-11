import SwiftUI

struct LaunchView: View {
	var body: some View {
		GeometryReader { _ in
			ZStack {
                Color.grape.edgesIgnoringSafeArea(.all)
			}
		}
	}
}

#Preview {
	LaunchView()
}
