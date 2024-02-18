import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(UIColor.black).edgesIgnoringSafeArea(.all)
                .foregroundColor(.black)
            VStack(spacing: 10) {
                Text("Sleepy")
                    .font(.system(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Твой спутник в мире сна и покоя")
                    .font(.system(size: 20))
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
