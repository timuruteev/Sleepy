import SwiftUI
import HealthKit
import SQLite

struct QualityViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var startTime: String = "00:00"
    @State private var endTime: String = "00:00"
    @State private var timeInBed: String = "0ч 0мин"
    @State private var timeAsleep: String = "0ч 0мин"
    private let healthStore = HKHealthStore()

    func requestAuthorization() {
        let typesToShare: Set = Set(arrayLiteral: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
        let typesToRead: Set = Set(arrayLiteral: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if !success {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func fetchSleepData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
            guard let result = results?.first as? HKCategorySample else {
                DispatchQueue.main.async {
                    self.startTime = "Нет данных"
                    self.endTime = "Нет данных"
                    self.timeInBed = "Нет данных"
                    self.timeAsleep = "Нет данных"
                }
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            DispatchQueue.main.async {
                self.startTime = formatter.string(from: result.startDate)
                self.endTime = formatter.string(from: result.endDate)
                
                // Вычисление времени в постели
                let components = calendar.dateComponents([.hour, .minute], from: result.startDate, to: result.endDate)
                if let hours = components.hour, let minutes = components.minute {
                    self.timeInBed = "\(hours)ч \(minutes)мин"
                }

                // Получение времени сна из БД
                self.fetchSleepDuration { duration in
                    let sleepDuration = duration * 60 // duration in seconds
                    let timeDifference = result.endDate.timeIntervalSince(result.startDate)
                    if timeDifference >= Double(sleepDuration) {
                        let adjustedEndTimeForSleep = result.endDate.addingTimeInterval(-Double(sleepDuration))
                        let sleepComponents = calendar.dateComponents([.hour, .minute], from: result.startDate, to: adjustedEndTimeForSleep)
                        if let sleepHours = sleepComponents.hour, let sleepMinutes = sleepComponents.minute {
                            self.timeAsleep = "\(sleepHours)ч \(sleepMinutes)мин"
                        }
                    } else {
                        self.timeAsleep = "0ч 0мин"
                    }
                }
            }
        }

        healthStore.execute(query)
    }

    func fetchSleepDuration(completion: @escaping (Int) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")

        let db = try! Connection(finalDatabaseURL.path, readonly: true)

        let sleepPeriodTable = Table("SleepPeriod")
        let durationExpr = Expression<Int>("Duration")

        if let sleepPeriodRow = try? db.pluck(sleepPeriodTable) {
            let sleepDuration = sleepPeriodRow[durationExpr]
            completion(sleepDuration)
        } else {
            completion(0)
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
        .onAppear(perform: {
            requestAuthorization()
            fetchSleepData()
        })
        .onChange(of: selectedDate) { _ in
            fetchSleepData()
        }
    }
}

struct QualityViewAsset_Previews : PreviewProvider {
    static var previews: some SwiftUI.View {
        QualityViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
