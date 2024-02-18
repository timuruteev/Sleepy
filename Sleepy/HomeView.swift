import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var selectedButton = "Сон"
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                FirstAlarm()
                    .tag(0)
                SecondAlarm()
                    .tag(1)
                ThirdAlarm()
                    .tag(2)
            }
            .tabViewStyle(.page)
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        ForEach(0..<3) { index in
                            Button(action: {
                                selectedTab = index
                            }) {
                                Circle()
                                    .fill(selectedTab == index ? Color.blue : Color.white)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    .padding(.bottom)
                    HStack(spacing: 30) {
                        ForEach(["Сон", "Журнал", "Статистика", "Профиль"], id: \.self) { tab in
                            Button(action: {
                                selectedButton = tab
                            }) {
                                VStack {
                                    Image(systemName: tab == "Сон" ? "moon.fill" : tab == "Журнал" ? "book.fill" : tab == "Статистика" ? "chart.bar.fill" : "person.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                    Text(tab)
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(selectedButton == tab ? .blue : .white)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor(red: 0, green: 0, blue: 0.2, alpha: 1)))
                }, alignment: .bottom
            )
        }
    }
}

struct FirstAlarm: View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 0

    // Создайте DateFormatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0, green: 0, blue: 0.2, alpha: 1)).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                        .foregroundColor(.white)
                        .colorInvert()
                        .accentColor(.white)
                    Text("Просыпайтесь легко между")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("\(wakeUpTime.addingTimeInterval(-30*60), formatter: dateFormatter) – \(wakeUpTime, formatter: dateFormatter)")
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
                        .background(Color.orange) // Меняем цвет на оранжевый
                        .cornerRadius(50) // Увеличиваем радиус скругления
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

    
struct SecondAlarm: View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 1

    // Создайте DateFormatter
    let secondAlarmDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0, green: 0, blue: 0.2, alpha: 1)).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
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
                    Spacer()
                }
            }
        }
    }
    
    
    struct ThirdAlarm: View {
        @State private var wakeUpTime = Date()
        @State private var selectedTab = "Сон"
        @State private var alarmIndex = 2
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color(UIColor(red: 0, green: 0, blue: 0.2, alpha: 1)).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 30) {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        VStack(spacing: 10) {
                            Text("Без будильника.")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("Только анализ сна")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .offset(y: geometry.size.height/10) // Смещение текста к центру
                        Spacer()
                        Spacer()
                        Spacer()
                        Button(action: {}) {
                            Text("Старт")
                                .font(.system(size: 20)) // Уменьшаем размер шрифта
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                                .background(Color.blue.opacity(0.4)) // Меняем цвет на темно-синий
                                .cornerRadius(50) // Увеличиваем радиус скругления
                        }
                        .padding(.horizontal)
                        Spacer()
                        Spacer()
                    }
                }
            }
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }

