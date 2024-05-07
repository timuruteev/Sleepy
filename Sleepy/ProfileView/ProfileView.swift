import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack() {
            Spacer()
            InformationViewAsset()
            SettingsViewAsset()
            Spacer()
            Spacer()
            Text("Версия приложения 1.0")
                .foregroundColor(.white)
            Link("С сайта", destination: URL(string: "https://drive.google.com/file/d/1A11w7Bwqgt7wLlQTAa-wn8U4WFe4VdP-/view?usp=sharing")!)
            Spacer()
        }
        .background(.black)
        .ignoresSafeArea()
    }
}

#Preview {
    ProfileView()
}
