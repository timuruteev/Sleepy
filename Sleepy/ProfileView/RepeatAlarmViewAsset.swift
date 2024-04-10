import SwiftUI

struct RepeatAlarmViewAsset: View {
    // Свойство для хранения выбранного периода
    @State private var selectedPeriod = 30
    
    // Массив возможных периодов
    let periods = [1, 2, 5, 10, 15]
    
    // Свойство для хранения ссылки на окно ProfileView
    @Environment(\.presentationMode) var presentationMode
    
    // Функция, которая возвращает правильную форму слова "минута" в зависимости от числа
    func getMinuteWord(for number: Int) -> String {
        // Если число заканчивается на 1, кроме 11, то возвращаем "минута"
        if number % 10 == 1 && number != 11 {
            return "минута"
        }
        // Если число заканчивается на 2, 3 или 4, кроме 12, 13 и 14, то возвращаем "минуты"
        else if (number % 10 == 2 || number % 10 == 3 || number % 10 == 4) && (number < 10 || number > 20) {
            return "минуты"
        }
        // В остальных случаях возвращаем "минут"
        else {
            return "минут"
        }
    }
    
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
                            // Используем функцию getMinuteWord, чтобы получить правильную форму слова "минута"
                            Text("\(period) \(getMinuteWord(for: period))")
                                .font(.headline)
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

struct RepeatAlarmViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        RepeatAlarmViewAsset()
    }
}
