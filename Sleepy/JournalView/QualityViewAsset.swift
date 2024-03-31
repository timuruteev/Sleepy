import SwiftUI
import SQLite

struct QualityViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var sleepQuality = 30
    @State private var startTime: String = "00:00"
    @State private var endTime: String = "00:00"
    @State private var timeInBed: String = "0ч 0мин"
    @State private var timeAsleep: String = "0ч 0мин"

    // Функция для получения времени начала и окончания сна
    func fetchSleepData() {
        // Путь к файлу базы данных в директории Documents
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")

        let db = try! Connection(finalDatabaseURL.path, readonly: true)

        let statistic = Table("Statistic")
        let idAlarm = Expression<Int64>("IdAlarm")
        let dateAlarmExpr = Expression<String>("DateAlarm")
        let startTimeExpr = Expression<String>("StartTime")
        let endTimeExpr = Expression<String>("EndTime")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = dateFormatter.string(from: selectedDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss" // Формат времени в базе данных

        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.dateFormat = "HH:mm" // Формат времени для отображения

        let fifteenMinutes: TimeInterval = 15 * 60
        let calendar = Calendar.current

        let query = statistic.select(startTimeExpr, endTimeExpr)
                                     .where(dateAlarmExpr == selectedDateString)
                                     .order(idAlarm.desc)
                                     .limit(1)
                do {
                    if let row = try db.pluck(query) {
                        if let startTimeDate = timeFormatter.date(from: row[startTimeExpr]),
                           let endTimeDate = timeFormatter.date(from: row[endTimeExpr]) {
                            self.startTime = displayTimeFormatter.string(from: startTimeDate)
                            self.endTime = displayTimeFormatter.string(from: endTimeDate)

                            // Вычисление времени в постели (без вычитания 15 минут)
                            let components = calendar.dateComponents([.hour, .minute], from: startTimeDate, to: endTimeDate)
                            if let hours = components.hour, let minutes = components.minute {
                                self.timeInBed = "\(hours)ч \(minutes)мин"
                            }

                            // Вычисление времени во сне (с вычитанием 15 минут, если разница > 30 минут)
                            let timeDifference = endTimeDate.timeIntervalSince(startTimeDate)
                            if timeDifference >= 30 * 60 {
                                let adjustedEndTimeForSleep = endTimeDate.addingTimeInterval(-fifteenMinutes)
                                let sleepComponents = calendar.dateComponents([.hour, .minute], from: startTimeDate, to: adjustedEndTimeForSleep)
                                if let sleepHours = sleepComponents.hour, let sleepMinutes = sleepComponents.minute {
                                    self.timeAsleep = "\(sleepHours)ч \(sleepMinutes)мин"
                                }
                            } else {
                                self.timeAsleep = "0ч 0мин"
                            }
                        }
                    } else {
                        self.startTime = "Нет данных"
                        self.endTime = "Нет данных"
                    }
                } catch {
                    print("Ошибка при выборке данных: \(error)")
                }
            }

    
    var body: some SwiftUI.View {
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
                    Text(timeInBed)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("В постели")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text(timeAsleep)
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
        .onAppear(perform: fetchSleepData) // Вызов функции при появлении view
        .onChange(of: selectedDate) { _ in
            fetchSleepData()
        }
    }
}

struct QualityViewAsset_Previews : PreviewProvider{
    
    static var previews:some SwiftUI.View{
        
        QualityViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
        
    }
}
