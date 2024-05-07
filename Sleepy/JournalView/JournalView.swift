import SwiftUI

struct JournalView: View {
    @State private var currentDate = Date()
    @State private var timeInBed = ""
    @State private var timeAsleep = ""
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
                GraphicViewAsset(selectedDate: $selectedDate)
                ShortViewAsset(selectedDate: $selectedDate)
                SongsViewAsset(selectedDate: $selectedDate)
                Spacer()
                Spacer()
            }
        }
        .background(.black)
    }
}

struct JournalView_Previews : PreviewProvider{
    static var previews:some View{
        JournalView()
            .background(Color.black)
        
    }
}

