import SwiftUI

struct InputWordsView: View {

    @State
    private var didContinue: Bool = false

    @State
    private var phraseIsVerified: Bool = false

    @FocusState
    private var fieldInFocus: Bool

    @Binding
    var path: [Onboarding]

    @ObservedObject
    var viewModel: NewMainViewModel

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let largeButtonHeight: CGFloat = 65.0

    let arrowSize: CGFloat = 60.0

    /// Reuse the seed grid for yourr seedwords
    private let isRestore = true

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
    }

    private func playCoin() {
        SoundsHelper().play(filename: "coinflip", type: "mp3")
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Button(action: {
                            path.removeLast()
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareImageSize,
                                           height: squareImageSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: squareImageSize)
                    .padding([.leading, .trailing], 20.0)
                    .padding(.bottom, 0.0)

                    Text("Restore your Brainwallet")
                         .modifier(BWIPSSemiBold(size: 32.0))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.05)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(8.0)

                    InputWordsGridView(viewModel: viewModel, phraseIsVerified: $phraseIsVerified)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.4, alignment: .center)
                        .padding(.top, 16.0)
                        .padding([.leading, .trailing], 16.0)
                        .focused($fieldInFocus)

                    Text( phraseIsVerified ? "Your seed phrase is verified!" :
                            "Don’t guess. It would take you\n5,444,517,950,000,000,000,000,000,000,000,000,000,000,000,000,000 tries.")
                            .font(phraseIsVerified ? .ibmPlexSansSemiBold(size: 32.0) : .ibmPlexSansRegular(size: 20.0))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(height: height * 0.2, alignment: .center)
                            .padding(.top, 5.0)
                            .padding([.leading, .trailing], 24.0)
                            .opacity(fieldInFocus ? 0.0 : 1.0)

                        Text( "Blockchain: Litecoin" )
                            .modifier(BWIPSRegular(size: 20.0))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.all, 12.0)
                            .opacity(fieldInFocus ? 0.0 : 1.0)
                    Spacer()
                    Button(action: {
                        if phraseIsVerified {
                            playCoin()
                            viewModel.didRestoreOldBrainwallet()
                        }

                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)

                            Text("Restore & Sync")
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                 .modifier(BWIPSBold(size: 24.0))
                                .foregroundColor(phraseIsVerified ? BrainwalletColor.content : BrainwalletColor.content.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.content, lineWidth: 2.0)
                                )
                        }
                        .padding(.all, 8.0)
                    }
                    .padding(.all, 8.0)
                    .opacity(fieldInFocus ? 0.0 : 1.0)
                    .disabled(!phraseIsVerified)
                }
                .ignoresSafeArea(.keyboard)
                .onChange(of: phraseIsVerified) { _,_ in
                    if phraseIsVerified {
                        fieldInFocus = false
                    }
                }
            }
        }
    }
}
