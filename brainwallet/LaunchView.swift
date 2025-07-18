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

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
