//
//  DateViewAsset.swift
//  Sleepy
//
//  Created by Timur on 06.02.2024.
//

import SwiftUI

struct DateViewAsset: View {
    @State private var currentDate = Date()

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
            Text(dayOfWeekFormatter.string(from: currentDate).capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(dateFormatter.string(from: currentDate))
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.leading, 20)
                .baselineOffset(-5)
            Spacer()
            Button(action: {
                // Обработка нажатия кнопки
            }) {
                Image(systemName: "calendar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding()

        Divider()
            .background(Color.gray)    }
}

#Preview {
    DateViewAsset()
    .background(Color.black)

}
