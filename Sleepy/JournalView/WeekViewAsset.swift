import SwiftUI

struct WeekViewAsset: View {
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<7) { index in
                ZStack {
                    Circle()
                        .stroke(lineWidth: 7)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(Double(index + 1) / 7.0, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(.degrees(-90)) // Поворачиваем на 90 градусов влево
                    Text(["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"][index])
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding()
        Divider()
            .background(Color.gray)
    }
}

#Preview {
    WeekViewAsset()
        .background(.black)
}
