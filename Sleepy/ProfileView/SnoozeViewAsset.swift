import SwiftUI
import SQLite

struct SnoozeViewAsset: SwiftUI.View {
    @State private var selectedPeriod = 10
    let periods = [1, 5, 10, 15, 30, 45, 60]
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        _selectedPeriod = State(initialValue: SnoozeViewAsset.fetchCurrentSnoozePeriod())
    }
    
    static func fetchCurrentSnoozePeriod() -> Int {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        let db = try! Connection(finalDatabaseURL.path)
        let snoozePeriodTable = Table("SnoozePeriod")
        let duration = Expression<Int>("Duration")
        if let currentPeriod = try! db.pluck(snoozePeriodTable.select(duration)) {
            return currentPeriod[duration]
        } else {
            return 10
        }
    }
    
    func updateSnoozePeriod(newPeriod: Int) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        let db = try! Connection(finalDatabaseURL.path)
        let settingsTable = Table("Settings")
        let snoozePeriodTable = Table("SnoozePeriod")
        let idSetting = Expression<Int64>("IdSetting")
        let idSnoozePeriod = Expression<Int64>("IdSnoozePeriod")
        let duration = Expression<Int>("Duration")
        
        try! db.run(snoozePeriodTable.delete())
        
        let insert = snoozePeriodTable.insert(duration <- newPeriod)
        let rowId = try! db.run(insert)
        
        if let settingId = try! db.pluck(settingsTable.select(idSetting)) {
            let setting = settingsTable.filter(idSetting == settingId[idSetting])
            try! db.run(setting.update(idSnoozePeriod <- rowId))
        } else {
            let insertSetting = settingsTable.insert(idSnoozePeriod <- rowId)
            try! db.run(insertSetting)
        }
    }
    
    var body: some SwiftUI.View {
        NavigationView {
            List {
                ForEach(periods, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        updateSnoozePeriod(newPeriod: period)
                    }) {
                        HStack {
                            Image(systemName: selectedPeriod == period ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            Text("\(period) мин")
                                .font(.headline)
                            if period == 10 {
                                Text("(по умолчанию)")
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
                    Text("Повтор будильника")
                        .font(.headline)
                }
            }
        }
        .background(Color.black)
        .colorScheme(.dark)
    }
}

struct SnoozeViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        SnoozeViewAsset()
    }
}
