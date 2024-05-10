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
                        Text("Бодрст.") // Заменено с "Начало"
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    if isGraphVisible && sleepHours != "Сон длился меньше 30 минут" {
                        Text("Сон") // Заменено с "Гл. фаза"
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .offset(y: -30)
                    }
                    Spacer()
                    if isGraphVisible && sleepHours != "Сон длился меньше 30 минут" {
                        Text("Гл. фаза") // Заменено с "Конец"
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .offset(y: -50)
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
            
            let sleepDuration = calculateDuration(startTime: startTime, endTime: endTime)
            
            // Если продолжительность сна меньше 30 минут, не строим график
            guard sleepDuration >= 30 else {
                return path
            }
            
            // Расчет начальной и конечной точек для графика
            let xOffset: CGFloat = 10 // Изменено с учетом отступов фигуры
            let yOffset: CGFloat = rect.height / (24 * 60)
            let startPointY = rect.maxY - (startHour * 60 + startMinutes) * yOffset
            let endPointY = rect.maxY - (endHour * 60 + endMinutes) * yOffset
            
            // Убедимся, что точки находятся внутри фигуры
            let startPoint = CGPoint(x: rect.minX + xOffset, y: max(startPointY, rect.minY))
            let endPoint = CGPoint(x: rect.maxX - xOffset, y: min(endPointY, rect.maxY))
            
            // Расчет высоты волны (глубины сна)
            let waveHeight = rect.height / 12 // Высота волны до уровня "гл. фазы сна"
            let midPointY = rect.maxY - waveHeight // Уровень "гл. фазы сна"
            let cycleLength = 90 * yOffset // Длина одного цикла сна (1,5 часа)

            // Рисование волн
            path.move(to: startPoint)
            var currentX = startPoint.x
            let endX = endPoint.x
            var isUp = false // Начинаем с волны, идущей вниз

            while currentX < endX - cycleLength {
                let nextX = currentX + cycleLength
                // Поднимаем контрольную точку еще выше
                let controlPointY = isUp ? (rect.minY + (midPointY - rect.minY) / 2) : rect.maxY
                
                let nextPoint = CGPoint(x: nextX, y: midPointY)
                let controlPoint = CGPoint(x: (currentX + nextX) / 2, y: controlPointY)
                
                path.addQuadCurve(to: nextPoint, control: controlPoint)
                
                currentX = nextX
                isUp.toggle() // Меняем направление волны
            }

            // Рисование последней волны до конечной точки
            let lastWaveLength = endX - currentX
            // Поднимаем контрольную точку последней волны еще выше
            let lastControlPointY = isUp ? (rect.minY + (midPointY - rect.minY) / 2) : rect.maxY
            let lastNextPoint = CGPoint(x: endX, y: startPoint.y)
            let lastControlPoint = CGPoint(x: currentX + lastWaveLength / 2, y: lastControlPointY)

            path.addQuadCurve(to: lastNextPoint, control: lastControlPoint)

            return path
            
            // Функция для расчета продолжительности сна
            func calculateDuration(startTime: String, endTime: String) -> Int {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                guard let start = dateFormatter.date(from: startTime),
                      let end = dateFormatter.date(from: endTime) else {
                    return 0
                }
                
                var duration = Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
                if duration < 0 { duration += 1440 } // Добавляем 24 часа при переходе через полночь
                return duration
            }
        }
    }
}

struct GraphicViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        GraphicViewAsset(selectedDate: .constant(Date()))
    }
}
