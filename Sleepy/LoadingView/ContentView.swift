import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                LoadingView()
            } else {
                MainWindowView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
