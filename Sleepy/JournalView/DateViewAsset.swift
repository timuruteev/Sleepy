import SwiftUI

struct DateViewAsset: View {
    @Binding var selectedDate: Date

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
    
    var body: some View {
        HStack(alignment: .center) {
            Text(dayOfWeekFormatter.string(from: selectedDate).capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(dateFormatter.string(from: selectedDate))
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.leading, 20)
                .baselineOffset(-5)
            Spacer()
        }
        .padding()

        Divider()
            .background(Color.gray)
    }
}

struct DateViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        DateViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
