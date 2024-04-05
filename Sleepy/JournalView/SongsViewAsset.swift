import SwiftUI
import AVFoundation
import SQLite

struct SongsViewAsset: SwiftUI.View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioFileURL: URL?
    @State private var audioFileName: String = ""
    @State private var audioDuration: String = ""
    @State private var audioTitle: String = "" // Добавьте эту переменную
    
    var body: some SwiftUI.View {
        VStack {
            HStack {
                Button(action: {
                    playOrPause()
                }) {
                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                        .resizable()
                        .frame(width: 32, height: 32) // Уменьшите размер кнопки
                }
                .padding()
                .alignmentGuide(.leading) { _ in 0 }
                
                Spacer() // Добавьте пробел между кнопкой и текстом
                
                VStack(alignment: .trailing) { // Выровняйте текст по правому краю
                    Text("Записано: \(audioTitle)") // Добавьте этот текст
                        .font(.subheadline)
                    Text("Длительность: \(audioDuration)") // Добавьте этот текст
                        .font(.subheadline)
                }
            }
        }
        .onAppear() {
            loadAudioFileFromDatabase()
        }
        
    }
    
    
    // Добавьте этот метод для загрузки аудиофайла из папки документов
    func loadAudioFileFromDatabase() {
        // Путь к файлу базы данных
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        // Подключение к базе данных
        let db = try! Connection(databaseURL.path, readonly: true)
        
        // Определение таблицы и выражений
        let audioRecord = Table("AudioRecord")
        let idAlarmExpr = Expression<Int64>("IdAlarm")
        let soundPathExpr = Expression<String>("SoundPath")
        
        // Получение пути к последнему аудиофайлу
        if let lastAudioRecord = try? db.pluck(audioRecord.order(idAlarmExpr.desc)) {
            let relativePath = lastAudioRecord[soundPathExpr]
            
            // Проверка доступности файла
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fullPath = documentsURL.appendingPathComponent(relativePath).path
            
            // Проверка доступности файла и воспроизведение
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    // Инициализация AVAudioPlayer и воспроизведение
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fullPath))
                    audioDuration = formatTime(audioPlayer?.duration ?? 0)
                    audioTitle = URL(fileURLWithPath: fullPath).lastPathComponent
                    audioPlayer?.prepareToPlay()
                } catch {
                    print("Ошибка при попытке воспроизвести файл: \(error)")
                }
            } else {
                print("Файл не найден по пути: \(fullPath)")
            }
        } else {
            print("Аудиозапись не найдена")
        }
    }


    // Добавьте этот метод для запуска и приостановки воспроизведения
    func playOrPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    // Добавьте этот метод для форматирования времени в виде mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        // Добавьте логику для выбора правильного окончания слова
        let word = seconds == 1 ? "секунда" : (seconds > 1 && seconds < 5 ? "секунды" : "секунд")
        return String(format: "%d \(word)", seconds)
    }
    
    // Добавьте этот метод для получения даты создания файла
    func getFileCreationDate(_ url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date
        } catch {
            print("Failed to get file attributes: \(error)")
            return nil
        }
    }
    
    // Добавьте этот метод для преобразования даты в строку
    // Измените этот метод для преобразования даты в строку
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM в HH:mm" // Измените этот формат
        formatter.locale = Locale(identifier: "ru_RU") // Добавьте эту строку для русского языка
        return formatter.string(from: date)
    }
}

struct SongsViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        SongsViewAsset()
            .background(Color.black)
    }
}
