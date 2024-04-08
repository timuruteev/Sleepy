import SwiftUI
import AVFoundation
import SQLite

struct SongsViewAsset: SwiftUI.View {
    @SwiftUI.Binding var selectedDate: Date
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioFileURL: URL?
    @State private var audioFileName: String = ""
    @State private var audioDuration: String = ""
    @State private var audioTitle: String = "" // Добавьте эту переменную
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        VStack {
            Text("Записанные звуки")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                            .padding(.bottom)
            
            if let errorMessage = errorMessage {
                // Если есть ошибка, отображаем ее вместо кнопки и информации о записи
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
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
        }
        .onAppear() {
            loadAudioFileFromDatabase()
        }
        .onChange(of: selectedDate) { newDate in
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
        let statistic = Table("Statistic")
        let idAlarmExpr = Expression<Int64>("IdAlarm")
        let soundPathExpr = Expression<String>("SoundPath")
        let dateAlarmExpr = Expression<String>("DateAlarm")
        
        // Получение пути к последнему аудиофайлу
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)
        
        let query = audioRecord.join(statistic, on: audioRecord[idAlarmExpr] == statistic[idAlarmExpr])
                               .filter(statistic[dateAlarmExpr] == selectedDateString)
                               .order(statistic[idAlarmExpr].desc)
        
        // Получение пути к последнему аудиофайлу за выбранный день
        if let lastAudioRecord = try? db.pluck(query) {
            let relativePath = lastAudioRecord[soundPathExpr]
            let fullPath = documentsDirectory.appendingPathComponent(relativePath).path
            
            // Проверка доступности файла и воспроизведение
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    // Инициализация AVAudioPlayer и воспроизведение
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fullPath))
                    audioDuration = formatTime(audioPlayer?.duration ?? 0)
                    
                    if let creationDate = getFileCreationDate(URL(fileURLWithPath: fullPath)) {
                                        audioTitle = (formatDate(creationDate))
                                    } else {
                                        audioTitle = "Дата создания файла неизвестна"
                                    }
                    
                    audioPlayer?.prepareToPlay()
                    self.errorMessage = nil // Очистка сообщения об ошибке, если файл найден
                } catch {
                    self.errorMessage = "Ошибка при попытке воспроизвести записанный звук"
                }
            } else {
                self.errorMessage = "Записанный звук не найден"
            }
        } else {
            self.errorMessage = "Аудиозапись не найдена для выбранной даты"
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
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM в HH:mm" // Измените этот формат
        formatter.locale = Locale(identifier: "ru_RU") // Добавьте эту строку для русского языка
        return formatter.string(from: date)
    }
}

struct SongsViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        SongsViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
