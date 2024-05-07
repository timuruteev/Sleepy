import SwiftUI
import SQLite

struct QualityViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var startTime: String = "00:00"
    @State private var endTime: String = "00:00"
    @State private var timeInBed: String = "0ч 0мин"
    @State private var timeAsleep: String = "0ч 0мин"

    func fetchSleepData() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")

        let db = try! Connection(finalDatabaseURL.path, readonly: true)

        let statistic = Table("Statistic")
        let sleepPeriodTable = Table("SleepPeriod")
        let idAlarm = Expression<Int64>("IdAlarm")
        let dateAlarmExpr = Expression<String>("DateAlarm")
        let startTimeExpr = Expression<String>("StartTime")
        let endTimeExpr = Expression<String>("EndTime")
        let durationExpr = Expression<Int>("Duration")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = dateFormatter.string(from: selectedDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.dateFormat = "HH:mm"

        let calendar = Calendar.current

        let query = statistic.select(startTimeExpr, endTimeExpr)
                             .where(dateAlarmExpr == selectedDateString)
                             .order(idAlarm.desc)
                             .limit(1)

        if let sleepPeriodRow = try? db.pluck(sleepPeriodTable) {
            let sleepDuration = sleepPeriodRow[durationExpr] * 60
            
            do {
                if let row = try db.pluck(query) {
                    if var startTimeDate = timeFormatter.date(from: row[startTimeExpr]),
                       var endTimeDate = timeFormatter.date(from: row[endTimeExpr]) {
                        
                        // Проверка, произошел ли переход через полночь
                        if endTimeDate < startTimeDate {
                            // Добавляем 24 часа к времени окончания, если оно раньше времени начала
                            endTimeDate = calendar.date(byAdding: .day, value: 1, to: endTimeDate)!
                        }

                        self.startTime = displayTimeFormatter.string(from: startTimeDate)
                        self.endTime = displayTimeFormatter.string(from: endTimeDate)

                        // Вычисление времени в постели
                        let components = calendar.dateComponents([.hour, .minute], from: startTimeDate, to: endTimeDate)
                        if let hours = components.hour, let minutes = components.minute {
                            self.timeInBed = "\(hours)ч \(minutes)мин"
                        }

                        // Вычисление времени во сне с учетом Duration из таблицы SleepPeriod
                        let timeDifference = endTimeDate.timeIntervalSince(startTimeDate)
                        if timeDifference >= Double(sleepDuration) {
                            let adjustedEndTimeForSleep = endTimeDate.addingTimeInterval(-Double(sleepDuration))
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
                    self.timeInBed = "Нет данных"
                    self.timeAsleep = "Нет данных"
                }
            } catch {
                print("Ошибка при выборке данных: \(error)")
            }
        } else {
            self.timeAsleep = "Нет данных"
        }
    }

    var body: some SwiftUI.View {
        HStack {
            HStack() {
                VStack(alignment: .leading) {
                    Text(timeInBed)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("В постели")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack() {
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
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
            .background(Color.gray)
        .onAppear(perform: fetchSleepData)
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
