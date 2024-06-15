import SwiftUI

struct WeekViewAsset: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach((1...7).reversed(), id: \.self) { index in
                Button(action: {
                    self.selectedDate = self.dateFor(index: index)
                }) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 7)
                            .foregroundColor(self.isDateSelected(index: index) ? Color.red : Color.blue)
                        Text(self.dayOfWeek(for: self.dateFor(index: index)))
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding()
        .onAppear {
            self.selectedDate = Date()
        }
        Divider()
            .background(Color.gray)
    }

    func dateFor(index: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: -index + 1, to: today)!
    }

    func isDateSelected(index: Int) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self.selectedDate, inSameDayAs: self.dateFor(index: index))
    }

    func dayOfWeek(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date)
    }
}

struct WeekViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        WeekViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
