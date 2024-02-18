import SwiftUI

struct VibrationViewAsset: View {
    // Свойство для хранения выбранного режима вибрации
    @State private var vibrationMode = true
    
    // Свойство для хранения ссылки на окно ProfileView
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView { // Добавил NavigationView
            // Список с радиокнопками
            
            List {
                // Кнопка с текстом и изображением для включения вибрации
                Button(action: {
                    // Обновить выбранный режим вибрации
                    vibrationMode = true
                }) {
                    HStack {
                        // Изображение с радиокнопкой
                        Image(systemName: vibrationMode ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(.blue)
                        
                        // Текст с названием режима вибрации
                        Text("Включено")
                            .font(.headline)
                        
                        
                    }
                }
                // Стиль кнопки без фона
                .buttonStyle(PlainButtonStyle())
                
                // Кнопка с текстом и изображением для выключения вибрации
                Button(action: {
                    // Обновить выбранный режим вибрации
                    vibrationMode = false
                }) {
                    HStack {
                        // Изображение с радиокнопкой
                        Image(systemName: vibrationMode ? "circle" : "largecircle.fill.circle")
                            .foregroundColor(.blue)
                        
                        // Текст с названием режима вибрации
                        Text("Выключено")
                            .font(.headline)
                        
                        
                    }
                }
                // Стиль кнопки без фона
                .buttonStyle(PlainButtonStyle())
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
                    Text("Вибрация")
                        .font(.headline)
                }
            }
        }
        // Добавил colorScheme
        .background(Color.black)
        .colorScheme(.dark)
        
        // test
    }
}

struct VibrationViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        VibrationViewAsset()
    }
}
