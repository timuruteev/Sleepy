import SwiftUI
import HealthKit

struct ShortViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var startTime: String = "00:00"
    @State private var endTime: String = "00:00"
    private let healthStore = HKHealthStore()

    init(selectedDate: SwiftUI.Binding<Date>) {
        self._selectedDate = selectedDate
        self.requestAuthorization()
    }

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
                }
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            DispatchQueue.main.async {
                self.startTime = formatter.string(from: result.startDate)
                self.endTime = formatter.string(from: result.endDate)
            }
        }

        healthStore.execute(query)
    }

    var body: some SwiftUI.View {
        VStack {
            Divider()
                .background(Color.gray)
            HStack {
                Image(systemName: "moon.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
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
                Image(systemName: "alarm.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
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

struct ShortViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ShortViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
