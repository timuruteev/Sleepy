import SwiftUI

struct SongViewAsset: View {
    // Свойство для хранения выбранного звука
    @State private var selectedSong = "Радар"
    
    // Массив возможных звуков
    let songs = ["Радар", "Пик", "Шелк", "Капля", "Маяк", "Колокольчики", "Цепь", "Сигнал", "Посмотрите на звезды", "Взлет"]
    
    // Свойство для хранения ссылки на окно ProfileView
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView { // Добавил NavigationView
            // Список с радиокнопками
            
            List {
                ForEach(songs, id: \.self) { song in
                    // Кнопка с текстом и изображением
                    Button(action: {
                        // Обновить выбранный звук
                        selectedSong = song
                    }) {
                        HStack {
                            // Изображение с радиокнопкой
                            Image(systemName: selectedSong == song ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            
                            // Текст с названием звука
                            Text(song)
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
                    Text("Звук")
                        .font(.headline)
                }
            }
        }
        // Добавил colorScheme
        .background(Color.black)
        .colorScheme(.dark)
    }
}

struct SongViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        SongViewAsset()
    }
}
