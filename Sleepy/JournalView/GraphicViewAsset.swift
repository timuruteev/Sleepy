import SwiftUI
import HealthKit

struct GraphicViewAsset: View {
    @Binding var selectedDate: Date
    @State private var heartRates: [(time: Date, rate: Double)] = []
    @State private var sleepIntervals: [Date] = []
    @State private var noDataMessage: String = "Загрузка данных о пульсе..."
    @State private var isGraphVisible: Bool = false
    
    let healthStore = HKHealthStore()
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                if isGraphVisible && !heartRates.isEmpty {
                    HStack(spacing: 2) {
                        VStack(spacing: 2) {
                            Text("Не сон")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Сон")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        .frame(height: 200)
                        
                        VStack {
                            PulseGraph(heartRates: heartRates)
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(height: 200)
                                .padding(.horizontal, 5)
                            
                            HStack {
                                ForEach(sleepIntervals, id: \.self) { interval in
                                    VStack {
                                        Text(DateFormatter.localizedString(from: interval, dateStyle: .none, timeStyle: .short))
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding(.leading, 5)
                }
                
                if noDataMessage != "" {
                    Text(noDataMessage)
                        .font(.title)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.leading, 70)
                }
            }
        }
        .onAppear {
            requestAuthorization()
        }
        .onChange(of: selectedDate) { newDate in
            fetchHeartRateData(for: newDate)
            fetchSleepData(for: newDate) // Добавляем эту строку, чтобы обновлять данные о сне
        }
        .padding(.vertical, 10)
    }
    
    func requestAuthorization() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [heartRateType, sleepType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                fetchHeartRateData(for: selectedDate)
                fetchSleepData(for: selectedDate)
            } else {
                noDataMessage = "Не удалось получить разрешение на доступ к данным."
            }
        }
    }
    
    func fetchHeartRateData(for selectedDate: Date) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let startDate = Calendar.current.startOfDay(for: selectedDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                noDataMessage = "Ошибка при получении данных о пульсе."
                return
            }
            
            let heartRates = samples.map { ($0.startDate, $0.quantity.doubleValue(for: HKUnit(from: "count/min"))) }
            DispatchQueue.main.async {
                self.heartRates = heartRates
                self.isGraphVisible = !heartRates.isEmpty
                self.noDataMessage = heartRates.isEmpty ? "Нет данных о пульсе за выбранный день." : ""
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchSleepData(for selectedDate: Date) {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let startDate = Calendar.current.startOfDay(for: selectedDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                noDataMessage = "Ошибка при получении данных о сне."
                return
            }
            
            if let sample = samples.first {
                let interval = sample.endDate.timeIntervalSince(sample.startDate)
                var sleepIntervals: [Date] = []
                var currentTime = sample.startDate
                
                while currentTime <= sample.endDate {
                    sleepIntervals.append(currentTime)
                    currentTime = Calendar.current.date(byAdding: .hour, value: 1, to: currentTime)!
                }
                
                DispatchQueue.main.async {
                    self.sleepIntervals = sleepIntervals
                    self.isGraphVisible = !sleepIntervals.isEmpty
                    self.noDataMessage = sleepIntervals.isEmpty ? "Нет данных о сне за выбранный день." : ""
                }
            } else {
                DispatchQueue.main.async {
                    self.noDataMessage = "Нет данных о сне за выбранный день."
                    self.isGraphVisible = false
                }
            }
        }
        
        healthStore.execute(query)
    }
}

struct PulseGraph: Shape {
    var heartRates: [(time: Date, rate: Double)]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard heartRates.count > 1 else {
            return path
        }
        
        let maxY = rect.maxY
        let minY = rect.minY
        let stepX = rect.width / CGFloat(heartRates.count - 1)
        let maxHeartRate = heartRates.map { $0.rate }.max() ?? 0
        let minHeartRate = heartRates.map { $0.rate }.min() ?? 0
        let range = maxHeartRate - minHeartRate
        
        let points = heartRates.enumerated().map { index, heartRate -> CGPoint in
            let x = CGFloat(index) * stepX
            let y = maxY - (CGFloat((heartRate.rate - minHeartRate) / range) * rect.height)
            return CGPoint(x: x, y: y)
        }
        
        path.move(to: CGPoint(x: rect.minX, y: minY))
        path.addLine(to: points.first!)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.addLine(to: CGPoint(x: rect.maxX, y: minY))
        
        // Добавляем фигуру, чтобы график был ограничен внутри
        path.addLine(to: CGPoint(x: rect.maxX, y: maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: maxY))
        path.closeSubpath()
        
        return path
    }
}

struct GraphicViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        GraphicViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
