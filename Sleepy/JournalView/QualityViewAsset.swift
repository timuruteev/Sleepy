import SwiftUI

struct QualityViewAsset: View {
    
    @State private var sleepQuality = 30
    @State private var timeInBed = "8ч 51мин"
    @State private var timeAsleep = "8ч 40мин"
    
    var body: some View {
        
        HStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 13)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Double(self.sleepQuality) / 100, 1)))
                    .stroke(style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text("\(self.sleepQuality)%")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Качество")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, height: 120)
            Spacer().frame(width: 50)
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("\(self.timeInBed)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("В постели")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("\(self.timeAsleep)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Во сне")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
            .background(Color.gray)
    }
}

#Preview {
    QualityViewAsset()
        .background(.black)

}
