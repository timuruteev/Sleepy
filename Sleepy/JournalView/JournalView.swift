import SwiftUI

struct JournalView: View {
    @State private var currentDate = Date()
    @State private var sleepQuality = 96
    @State private var timeInBed = "8ч 51мин"
    @State private var timeAsleep = "8ч 40мин"
    @State private var selectedDate = Date()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }
    
    var dayOfWeekFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    // Добавляем переменные для нижней панели
    @State private var selectedTab = 0
    @State private var selectedButton = "Статистика"
    
    var body: some View {
        ScrollView{
            VStack() {
                Spacer()
                Spacer()
                DateViewAsset(selectedDate: $selectedDate)
                WeekViewAsset(selectedDate: $selectedDate)
                QualityViewAsset(selectedDate: $selectedDate)
                GraphicViewAsset()
                ShortViewAsset(selectedDate: $selectedDate)
                SongsViewAsset()
                Spacer()
                Spacer()
            }
            // Добавляем нижнюю панель поверх основного вида
        }
        .background(.black)

    }
}
  
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}


