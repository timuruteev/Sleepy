import SwiftUI

struct MainView: View {
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
            .background(.black)
            .tabViewStyle(.page)
            VStack {
                Spacer()
            }
        }
    }
}

struct FirstAlarm: View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 0
    @State private var isPresented = false
    
    // Создайте DateFormatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute) // элемент выбора времени
                                    .datePickerStyle(.wheel) // стиль элемента
                                    .labelsHidden() // скрыть метки
                                    .preferredColorScheme(.dark)
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
                Button(action: {
                    isPresented = !isPresented
                }) {
                    Text("Старт")
                        .font(.system(size: 20)) // Уменьшаем размер шрифта
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                        .background(Color.orange) // Меняем цвет на оранжевый
                        .cornerRadius(50) // Увеличиваем радиус скругления
                }
                .sheet(isPresented: $isPresented, content: {
                    TimerView(wakeUpTime: $wakeUpTime)
                })
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
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute) // элемент выбора времени
                                    .datePickerStyle(.wheel) // стиль элемента
                                    .labelsHidden() // скрыть метки
                                    .preferredColorScheme(.dark)
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
            ZStack {
                VStack(spacing: 30) {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()

                    VStack(spacing: 10) {
                        Text("Без интервала пробуждения.")
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
                    Spacer()
                    Spacer()

                        Button(action: {}) {
                            Text("Старт")
                                .font(.system(size: 20)) // Уменьшаем размер шрифта
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                                .background(Color.blue) // Меняем цвет на оранжевый
                                .cornerRadius(50) // Увеличиваем радиус скругления
                                .opacity(0.6)
                        }
                        .padding(.horizontal)
                        Spacer()
                    Spacer()

                    }
                }
            }
        }
    
    
    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView()
        }
    }

