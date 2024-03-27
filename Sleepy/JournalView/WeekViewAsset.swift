import SwiftUI

struct WeekViewAsset: View {
    @Binding var selectedDate: Date
    
    let daysOfWeek = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]
    
    // Функция для получения даты для каждого дня недели
    func dateForDay(index: Int) -> Date {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return calendar.date(byAdding: .day, value: index, to: startOfWeek)!
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<7, id: \.self) { index in
                Button(action: {
                    self.selectedDate = self.dateForDay(index: index)
                }) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 7)
                            .foregroundColor(Color.blue)
                        Text(daysOfWeek[index])
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding()
        .onAppear {
            // Установка selectedDate в текущую дату при первом появлении
            self.selectedDate = Date()
        }
        Divider()
            .background(Color.gray)
    }
}

// Превью компонента
struct WeekViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        WeekViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
