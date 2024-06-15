import SwiftUI
import HealthKit
import SQLite

struct InformationViewAsset: SwiftUI.View {
    @State private var numberOfNights: Int = 0
    @State private var averageSleepTime: String = "0ч 0мин"
    
    private var healthStore: HKHealthStore = HKHealthStore()

    func fetchSleepStatisticsFromDB() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")

        let db = try! Connection(finalDatabaseURL.path, readonly: true)

        let statistic = Table("Statistic")
        let idAlarm = Expression<Int64>("IdAlarm")
        let startTimeExpr = Expression<String>("StartTime")
        let endTimeExpr = Expression<String>("EndTime")

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        let query = statistic.select(startTimeExpr, endTimeExpr)
        var totalSleepTime: Int = 0
        var validNights: Int = 0

        do {
            for row in try db.prepare(query) {
                if var startTimeDate = timeFormatter.date(from: row[startTimeExpr]),
                   var endTimeDate = timeFormatter.date(from: row[endTimeExpr]) {
                    
                    if endTimeDate < startTimeDate {
                        endTimeDate = Calendar.current.date(byAdding: .day, value: 1, to: endTimeDate)!
                    }

                    let sleepDuration = Calendar.current.dateComponents([.minute], from: startTimeDate, to: endTimeDate).minute ?? 0
                    if sleepDuration > 30 {
                        validNights += 1
                        totalSleepTime += sleepDuration
                    }
                }
            }
            if validNights > 0 {
                let averageMinutes = totalSleepTime / validNights
                self.averageSleepTime = "\(averageMinutes / 60)ч \(averageMinutes % 60)мин"
            }
        } catch {
            print("Ошибка при выборке данных: \(error)")
        }
    }

    func fetchNumberOfNightsFromHealthKit() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, result, error) in
            guard error == nil else {
                print("Error fetching sleep data: \(error!.localizedDescription)")
                return
            }
            
            var validNights: Int = 0

            result?.forEach { sample in
                if let sample = sample as? HKCategorySample {
                    let sleepDuration = Calendar.current.dateComponents([.minute], from: sample.startDate, to: sample.endDate).minute ?? 0
                    if sleepDuration > 30 {
                        validNights += 1
                    }
                }
            }

            DispatchQueue.main.async {
                self.numberOfNights = validNights
            }
        }
        
        healthStore.execute(query)
    }

    var body: some SwiftUI.View {
        VStack {
            HStack(alignment: .center) {
                Text("Профиль")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            
            Divider()
                .background(Color.gray)
            
            HStack {
                Image(systemName:"moon.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("\(self.numberOfNights)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("кол-во ночей")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
                
                Image(systemName:"clock.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("\(self.averageSleepTime)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("средн. время")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            
            Divider()
                .background(Color.gray)
            .padding(.bottom, 30)
        }
        .background(Color.black)
        .onAppear {
            fetchSleepStatisticsFromDB()
            if HKHealthStore.isHealthDataAvailable() {
                let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
                self.healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
                    if success {
                        self.fetchNumberOfNightsFromHealthKit()
                    } else {
                        print("Authorization failed")
                    }
                }
            }
        }
    }
}

struct InformationViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        InformationViewAsset()
            .background(Color.black)
    }
}
