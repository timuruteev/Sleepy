import SwiftUI
import SQLite

struct TimeToSleep: SwiftUI.View {
    @State private var selectedPeriod = 30
    let periods = [5, 10, 15, 20]
    @Environment(\.presentationMode) var presentationMode
    
    init() {
            // Инициализация с выбранным периодом из базы данных
        _selectedPeriod = State(initialValue: TimeToSleep.fetchCurrentSleepPeriod())
        }
    
    static func fetchCurrentSleepPeriod() -> Int {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
            
            let db = try! Connection(finalDatabaseURL.path)
            
            let sleepPeriodTable = Table("SleepPeriod")
            let duration = Expression<Int>("Duration")
            
            if let currentPeriod = try! db.pluck(sleepPeriodTable.select(duration)) {
                return currentPeriod[duration]
            } else {
                return 15 // Возвращаем значение по умолчанию, если в базе данных нет записей
            }
        }
    
    // Функция для обновления периода засыпания в базе данных
    func updateSleepPeriod(newPeriod: Int) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        let db = try! Connection(finalDatabaseURL.path)
        
        let settingsTable = Table("Settings")
        let sleepPeriodTable = Table("SleepPeriod")
        let idSetting = Expression<Int64>("IdSetting")
        let idSleepPeriod = Expression<Int64>("IdSleepPeriod")
        let duration = Expression<Int>("Duration")
        
        // Удаление старого значения периода засыпания
        try! db.run(sleepPeriodTable.delete())
        
        // Добавление нового значения периода засыпания
        let insert = sleepPeriodTable.insert(duration <- newPeriod)
        let rowId = try! db.run(insert)
        
        // Обновление ссылки на период засыпания в таблице настроек
        if let settingId = try! db.pluck(settingsTable.select(idSetting)) {
            let setting = settingsTable.filter(idSetting == settingId[idSetting])
            try! db.run(setting.update(idSleepPeriod <- rowId))
        } else {
            // Если запись в таблице Settings отсутствует, создаем новую
            let insertSetting = settingsTable.insert(idSleepPeriod <- rowId)
            try! db.run(insertSetting)
        }
    }
    
    var body: some SwiftUI.View {
        NavigationView {
            List {
                ForEach(periods, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        updateSleepPeriod(newPeriod: period)
                    }) {
                        HStack {
                            Image(systemName: selectedPeriod == period ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            Text("\(period) мин")
                                .font(.headline)
                            if period == 15 {
                                Text("(рекомендуется)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                Text("Назад")
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Период засыпания")
                        .font(.headline)
                }
            }
        }
        .background(Color.black)
        .colorScheme(.dark)
    }
}

struct TimeToSleep_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        TimeToSleep()
    }
}
