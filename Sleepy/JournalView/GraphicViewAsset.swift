import SwiftUI
import SQLite

struct GraphicViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var sleepHours: String = ""
    
    var body: some SwiftUI.View {
            VStack(alignment: .leading) {
                SleepGraph(startTime: startTime, endTime: endTime)
                    .stroke(Color.green, lineWidth: 2)
                    .frame(height: 200)
                    .padding(.horizontal, 20) // Горизонтальный отступ
                    .padding(.leading, 70)     // Вертикальный отступ
                Text(sleepHours)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20) // Горизонтальный отступ
                    .padding(.leading, 70)     // Вертикальный отступ
            }
            
            .onAppear {
                fetchSleepData(for: selectedDate)
            }
            .onChange(of: selectedDate) { newDate in
                fetchSleepData(for: newDate)
            }
        }
    
    func fetchSleepData(for selectedDate: Date) {
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
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss" // Формат времени в базе данных
            
            let displayTimeFormatter = DateFormatter()
            displayTimeFormatter.dateFormat = "HH:mm" // Формат времени для отображения
            
            let selectedDateString = dateFormatter.string(from: selectedDate)
            print("Выбранная дата: \(selectedDateString)") // Добавлен отладочный вывод
            
            let query = statistic.select(startTimeExpr, endTimeExpr)
                .where(dateAlarmExpr == selectedDateString)
                .order(idAlarm.desc) // Сортировка по убыванию IdAlarm
                .limit(1) // Ограничение на одну запись
            do {
                if let row = try db.pluck(query) {
                    print("Найдена запись для даты: \(selectedDateString)") // Добавлен отладочный вывод
                    if let startTimeDate = timeFormatter.date(from: row[startTimeExpr]),
                       let endTimeDate = timeFormatter.date(from: row[endTimeExpr]) {
                        self.startTime = displayTimeFormatter.string(from: startTimeDate)
                        self.endTime = displayTimeFormatter.string(from: endTimeDate)
                        calculateSleepHours(startTime: self.startTime, endTime: self.endTime)
                    } else {
                        print("Не удалось преобразовать время из базы данных") // Добавлен отладочный вывод
                    }
                } else {
                    self.startTime = "Нет данных"
                    self.endTime = "Нет данных"
                    self.sleepHours = ""
                    print("Нет данных для даты: \(selectedDateString)") // Добавлен отладочный вывод
                }
            } catch {
                print("Ошибка при выборке данных: \(error)")
            }
        }
    
    func calculateSleepHours(startTime: String, endTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTimeDate = dateFormatter.date(from: startTime),
              let endTimeDate = dateFormatter.date(from: endTime) else {
            return
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: startTimeDate, to: endTimeDate)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        var sleepHoursString = ""
        var currentHour = Int(startTime.prefix(2))! // Текущий час начала сна
        let endHour = Int(endTime.prefix(2))! // Час окончания сна
        
        var hourCounter = 0 // Счетчик часов сна
        
        while true {
            sleepHoursString += "\(currentHour)"
            hourCounter += 1
            
            if currentHour == endHour && hourCounter > 1 { // Если достигнут час окончания сна и был хотя бы один час сна
                break
            }
            
            if currentHour == 23 {
                currentHour = 0 // Если текущий час 23, переходим на следующий день
            } else {
                currentHour += 1
            }
            
            sleepHoursString += " "
        }
        sleepHours = sleepHoursString
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
