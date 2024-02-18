import SwiftUI

struct WakeUpPeriodViewAsset: View {
    // Свойство для хранения выбранного периода
    @State private var selectedPeriod = 30
    
    // Массив возможных периодов
    let periods = [10, 15, 20, 30, 45]
    
    // Свойство для хранения ссылки на окно ProfileView
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView { // Добавил NavigationView
            // Список с радиокнопками
            
            List {
                ForEach(periods, id: \.self) { period in
                    // Кнопка с текстом и изображением
                    Button(action: {
                        // Обновить выбранный период
                        selectedPeriod = period
                    }) {
                        HStack {
                            // Изображение с радиокнопкой
                            Image(systemName: selectedPeriod == period ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            
                            // Текст с периодом и рекомендацией
                            Text("\(period) мин")
                                .font(.headline)
                            
                            if period == 30 {
                                Text("(рекомендуется)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    // Стиль кнопки без фона
                    .buttonStyle(PlainButtonStyle())
                }
            }
            // Удалил navigationTitle
            .navigationBarItems(leading: Button(action: {
                // Закрыть текущее окно и вернуться к ProfileView
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                Text("Назад")
            })
            .toolbar { // Добавил toolbar
                ToolbarItem(placement: .principal) { // Изменил placement
                    Text("Период пробуждения")
                        .font(.headline)
                }
            }
        }
        // Добавил colorScheme
        .background(Color.black)
        .colorScheme(.dark)
    }
}

struct WakeUpPeriodViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        WakeUpPeriodViewAsset()
    }
}
