import SwiftUI

struct SecondAlarm: View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 1 // Установите индекс будильника на 1, чтобы вторая точка была оранжевой

    var body: some View {
        ZStack {
            Color(UIColor(red: 0, green: 0, blue: 0.2, alpha: 1)).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("Выберите время пробуждения")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                        .foregroundColor(.white)
                        .colorInvert()
                        .accentColor(.white)
                    Text("Без интервала пробуждения.")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Сработает в \(wakeUpTime, formatter: secondAlarmDateFormatter)")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Button(action: {}) {
                    Text("Старт")
                        .font(.system(size: 20)) // Уменьшаем размер шрифта
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                        .background(Color.blue) // Меняем цвет на оранжевый
                        .cornerRadius(50) // Увеличиваем радиус скругления
                }
                .padding(.horizontal)
                HStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == alarmIndex ? Color.blue : Color.white) // Меняем цвет на оранжевый
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.bottom)
                HStack(spacing: 30) {
                    ForEach(["Сон", "Журнал", "Статистика", "Профиль"], id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            VStack {
                                Image(systemName: tab == "Сон" ? "moon.fill" : tab == "Журнал" ? "book.fill" : tab == "Статистика" ? "chart.bar.fill" : "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                Text(tab)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(selectedTab == tab ? .blue : .white)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

let secondAlarmDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "H:mm"
    return formatter
}()


struct SecondAlarm_Previews: PreviewProvider {
    static var previews: some View {
        SecondAlarm()
    }
}
