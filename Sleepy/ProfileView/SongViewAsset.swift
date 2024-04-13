import SwiftUI
import SQLite

struct SongViewAsset: SwiftUI.View  {
    @State private var selectedSong: String
    let songs = ["Alerta", "Sirenize", "Clockwise", "Chimy", "Kevat"]
    @Environment(\.presentationMode) var presentationMode

    init() {
        // Инициализация с выбранным звуком из базы данных
        _selectedSong = State(initialValue: SongViewAsset.fetchCurrentAlarmSound())
    }
    
    // Функция для получения текущего выбранного звука будильника из базы данных
    static func fetchCurrentAlarmSound() -> String {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        let db = try! Connection(finalDatabaseURL.path)
        
        let alarmSoundTable = Table("AlarmSound")
        let soundName = Expression<String>("SoundName")
        
        if let currentSound = try! db.pluck(alarmSoundTable.select(soundName)) {
            return currentSound[soundName]
        } else {
            return "Clockwise" // Возвращаем значение по умолчанию, если в базе данных нет записей
        }
    }

    // Функция для обновления выбранного звука будильника в базе данных
    func updateAlarmSound(selectedSong: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        let db = try! Connection(finalDatabaseURL.path)
        
        let alarmSoundTable = Table("AlarmSound")
        let soundName = Expression<String>("SoundName")
        let soundPath = Expression<String>("SoundPath")
        
        // Относительный путь к звуку
        let relativeSoundPath = "/\(selectedSong).mp3"
        
        // Удаление старого значения звука будильника
        try! db.run(alarmSoundTable.delete())
        
        // Добавление нового значения звука будильника
        let insert = alarmSoundTable.insert(soundName <- selectedSong, soundPath <- relativeSoundPath)
        try! db.run(insert)
    }

    var body: some SwiftUI.View  {
        NavigationView {
            List {
                ForEach(songs, id: \.self) { song in
                    Button(action: {
                        // Обновить выбранный звук и записать в базу данных
                        selectedSong = song
                        updateAlarmSound(selectedSong: song)
                    }) {
                        HStack {
                            Image(systemName: selectedSong == song ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            Text(song)
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                Text("Назад")
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Выбор звука")
                        .font(.headline)
                }
            }
        }
        .background(Color.black)
        .colorScheme(.dark)
    }
}

struct SongViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View  {
        SongViewAsset()
    }
}
