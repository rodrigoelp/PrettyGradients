//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = GradientController()
    
    var body: some View {
        ZStack {
            FunkyAnimatedGradient(viewModel: self.viewModel) // adding the gradient
                .ignoresSafeArea() // making it full screen
                .blur(radius: 20) // smoothing it out
                .scaleEffect(CGSize(width: 1.2, height: 1.2)) // removing the stupid white from the edges.
            
            Button(action: { self.viewModel.changePalette() }, label: {
                Text("Change Palette")
                    .foregroundColor(.white)
            })
        }
    }
}

class GradientController: ObservableObject {
    private let timer = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
    private var disposeBag: Set<AnyCancellable> = []
    private var paletteIndex: Int = 0
    
    @Published var start: UnitPoint = .init(x: 10, y: 0)
    @Published var end: UnitPoint = .init(x: 0, y: -10)
    @Published var gradient: Gradient
    @Published var tick: ()
    
    let colours: [Color] = GradientController.palette.first!
    
    private static let palette: [[Color]] = [
        [ .red, .blue, .purple, .yellow, .pink, .green, .purple ],
        [.pink, .orange, .red, .purple]
    ]

    
    init() {
        gradient = Gradient(colors: colours)
        timer.sink { [weak self] _ in
            self?.start = .init(x: 0, y: 4)
            self?.end = .init(x: -10, y: 2)
            self?.start = .init(x: -6, y: -10)
            self?.start = .init(x: 5, y: 0)
            self?.end = .init(x: 3, y: 3)
            }
            .store(in: &disposeBag)
    }
    
    func changePalette() {
        paletteIndex = (paletteIndex + 1) % Self.palette.count
        gradient = Gradient(colors: Self.palette[paletteIndex])
    }
}

struct FunkyAnimatedGradient: View {
    @ObservedObject var viewModel: GradientController
    
    var body: some View {
        LinearGradient(
            gradient: viewModel.gradient,
            startPoint: viewModel.start,
            endPoint: viewModel.end
        )
        .animation(
            Animation.easeInOut(duration: 6)
                .repeatForever(autoreverses: true)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
    }
}
