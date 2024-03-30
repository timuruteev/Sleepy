import SwiftUI

struct DateViewAsset: View {
    @Binding var selectedDate: Date // Step 1: Add @Binding for selectedDate

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
            Text(dayOfWeekFormatter.string(from: selectedDate).capitalized) // Step 2: Use selectedDate
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(dateFormatter.string(from: selectedDate)) // Step 2: Use selectedDate
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

// Step 3: Add a Preview
struct DateViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        DateViewAsset(selectedDate: .constant(Date())) // Use a sample date for preview
            .background(Color.black)
    }
}
