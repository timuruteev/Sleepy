import SwiftUI
import SQLite 

struct ShortViewAsset: SwiftUI.View {
    
        @SwiftUI.Binding var selectedDate: Date
        @State private var startTime: String = "00:00"
        @State private var endTime: String = "00:00"

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

        let query = statistic.select(startTimeExpr, endTimeExpr)
                                 .where(dateAlarmExpr == selectedDateString)
                                 .order(idAlarm.desc) // Сортировка по убыванию IdAlarm
                                 .limit(1) // Ограничение на одну запись
        do {
                if let row = try db.pluck(query) {
                    if let startTimeDate = timeFormatter.date(from: row[startTimeExpr]),
                       let endTimeDate = timeFormatter.date(from: row[endTimeExpr]) {
                        self.startTime = displayTimeFormatter.string(from: startTimeDate)
                        self.endTime = displayTimeFormatter.string(from: endTimeDate)
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
            VStack {
                HStack{
                    Image(systemName:"moon.fill")
                        .resizable()
                        .frame(width : 30, height : 30)
                        .foregroundColor(.blue)
                        .padding(10)
                    VStack(alignment: .leading) {
                        Text(startTime)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Начало сна")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Image(systemName:"alarm.fill")
                        .resizable()
                        .frame(width : 30, height : 30)
                        .foregroundColor(.blue)
                        .padding(10)
                    VStack(alignment: .leading) {
                        Text(endTime)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Конец сна")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                Divider()
                    .background(Color.gray)
            }
            .onAppear(perform: fetchSleepData)
            .onChange(of: selectedDate) { _ in
                fetchSleepData()
            }
        }
    }

struct ShortViewAsset_Previews : PreviewProvider{
    
    static var previews:some SwiftUI.View{
        
        ShortViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
        
    }
}
