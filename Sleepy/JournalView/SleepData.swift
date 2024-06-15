import SwiftUI

class SleepData: ObservableObject {
    @Published var startTime: String = "00:00"
    @Published var endTime: String = "00:00"
}
