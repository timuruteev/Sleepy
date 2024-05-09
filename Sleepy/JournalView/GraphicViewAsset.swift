import SwiftUI
import SQLite

struct GraphicViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var sleepHours: String = ""
    @State private var noDataMessage: String = ""
    @State private var isGraphVisible: Bool = false
    
    var body: some SwiftUI.View {
        VStack(alignment: .leading) {
            ZStack {
                
                SleepGraph(startTime: startTime, endTime: endTime)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .padding(.leading, 70)
                
                if sleepHours == "Сон длился меньше 30 минут" || noDataMessage != "" {
                    Text(sleepHours.isEmpty ? noDataMessage : sleepHours)
                        .font(.title)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                
            }
            .overlay(
                VStack(alignment: .leading, spacing: 30) {
                    Spacer()
                    if isGraphVisible && sleepHours != "Сон длился меньше 30 минут" {
                        Text("Начало")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    if isGraphVisible && sleepHours != "Сон длился меньше 30 минут" {
                        Text("Гл. фаза")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    if isGraphVisible && sleepHours != "Сон длился меньше 30 минут" {
                        Text("Конец")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                    Spacer()
                },
                alignment: .leading
            )
            
            
            if sleepHours != "Сон длился меньше 30 минут" && noDataMessage.isEmpty {
                HStack(spacing: 0) {
                    ForEach(sleepHours.split(separator: " "), id: \.self) { hour in
                        Text(String(hour))
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.leading, 70)
            }
        }
    .onAppear {
        fetchSleepData(for: selectedDate)
    }
    .onChange(of: selectedDate) { newDate in
        self.startTime = ""
            self.endTime = ""
        self.sleepHours = ""
        self.noDataMessage = ""
        fetchSleepData(for: newDate)
    }

}
    
    func fetchSleepData(for selectedDate: Date) {
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
           
           let timeFormatter = DateFormatter()
           timeFormatter.dateFormat = "HH:mm:ss"
           
           let displayTimeFormatter = DateFormatter()
           displayTimeFormatter.dateFormat = "HH:mm"
           
           let selectedDateString = dateFormatter.string(from: selectedDate)
           print("Выбранная дата: \(selectedDateString)")
           
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
                       calculateSleepHours(startTime: self.startTime, endTime: self.endTime)
                       self.isGraphVisible = true
                   } else {
                       self.noDataMessage = "Нет данных"
                       self.isGraphVisible = false

                   }
               } else {
                   self.noDataMessage = "Нет данных"
                   self.isGraphVisible = false

               }
           } catch {
               print("Ошибка при выборке данных: \(error)")
               self.noDataMessage = "Нет данных"
               self.isGraphVisible = false
           }
        
       }

    func calculateSleepHours(startTime: String, endTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTimeDate = dateFormatter.date(from: startTime),
              let endTimeDate = dateFormatter.date(from: endTime) else {
            self.sleepHours = "Недостаточно данных"
            return
        }
        
        var duration = Calendar.current.dateComponents([.minute], from: startTimeDate, to: endTimeDate).minute ?? 0
        
        if duration < 0 {
            // Добавляем 24 часа (1440 минут), если время окончания меньше времени начала
            duration += 1440
        }
        
        // Проверка на минимальную продолжительность сна
        if duration < 30 {
            self.sleepHours = "Сон длился меньше 30 минут"
            return
        }
        
        let hours = duration / 60
        let interval = hours > 12 ? 2 : 1 // Интервал в часах для отображения текста
        
        var sleepHoursString = ""
        var currentHour = Int(startTime.prefix(2))! // Текущий час начала сна
        let endHour = Int(endTime.prefix(2))! // Час окончания сна
        
        while true {
            sleepHoursString += "\(currentHour)"
            
            if currentHour == endHour {
                break
            }
            
            currentHour += interval // Увеличиваем на интервал
            
            if currentHour > 23 {
                currentHour -= 24 // Если текущий час больше 23, переходим на следующий день
            }
            
            sleepHoursString += " "
        }
        
        self.sleepHours = sleepHoursString.trimmingCharacters(in: .whitespaces)
    }
    
    
    struct SleepGraph: Shape {
        var startTime: String
        var endTime: String
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Конвертация времени в координаты для графика
            let startComponents = startTime.split(separator: ":").compactMap { Int($0) }
            let endComponents = endTime.split(separator: ":").compactMap { Int($0) }
            
            guard startComponents.count == 2, endComponents.count == 2 else {
                return path
            }
            
            let startHour = CGFloat(startComponents[0])
            let startMinutes = CGFloat(startComponents[1])
            let endHour = CGFloat(endComponents[0])
            let endMinutes = CGFloat(endComponents[1])
            
            // Расчет продолжительности сна
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            guard let startTimeDate = dateFormatter.date(from: startTime),
                  let endTimeDate = dateFormatter.date(from: endTime) else {
                return path
            }
            
            var duration = Calendar.current.dateComponents([.minute], from: startTimeDate, to: endTimeDate).minute ?? 0
            
            // Проверка на переход через полночь
            if duration < 0 {
                duration += 1440 // Добавляем 24 часа
            }
            
            // Если продолжительность сна меньше 30 минут, не строим график
            if duration < 30 {
                return path
            }
            
            // Расчет точек для графика сна
            let xOffset: CGFloat = 10
            let startPoint = CGPoint(x: rect.minX + xOffset, y: rect.maxY - (startHour * 60 + startMinutes) * (rect.height / (24 * 60)))
            let endPoint = CGPoint(x: rect.maxX - xOffset, y: rect.maxY - (endHour * 60 + endMinutes) * (rect.height / (24 * 60)))
            
            // Рисование прямоугольника без верхней линии
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            
            // Рисование линии сна
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            return path
        }
    }
}

struct GraphicViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        GraphicViewAsset(selectedDate: .constant(Date()))
    }
}
