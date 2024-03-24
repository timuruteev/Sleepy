import SwiftUI
import AVFoundation

struct SongsViewAsset: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioFileURL: URL?
    @State private var audioFileName: String = ""
    @State private var audioDuration: String = ""
    @State private var audioTitle: String = "" // Добавьте эту переменную
    
    var body: some View {
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
            loadAudioFile()
        }
        
    }
    
    // Добавьте этот метод для загрузки аудиофайла из папки документов
    func loadAudioFile() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            // Получите список файлов в папке документов
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // Найдите последний файл с расширением m4a
            if let audioFileURL = fileURLs.filter({ $0.pathExtension == "m4a" }).last {
                // Создайте экземпляр AVAudioPlayer и загрузите файл
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                // Сохраните URL, имя и продолжительность файла
                self.audioFileURL = audioFileURL
                audioFileName = audioFileURL.lastPathComponent
                
                audioDuration = formatTime(audioPlayer?.duration ?? 0)
                // Получите дату создания файла из его свойств
                if let creationDate = getFileCreationDate(audioFileURL) {
                    // Преобразуйте дату в строку с нужным форматом
                    let dateString = formatDate(creationDate)
                    // Сохраните дату как заголовок аудиофайла
                    audioTitle = dateString
                } else {
                    // Если дата не найдена, выведите сообщение об ошибке
                    print("No creation date found")
                    audioTitle = "Нет даты создания"
                }
            } else {
                // Если файл не найден, выведите сообщение об ошибке
                print("No audio file found")
                audioTitle = "Нет аудиофайла" // Добавьте эту строку
            }
        } catch {
            // Обработайте возможные ошибки
            print("Failed to load audio file: \(error)")
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
    static var previews: some View {
        SongsViewAsset()
            .background(Color.black)
    }
}
