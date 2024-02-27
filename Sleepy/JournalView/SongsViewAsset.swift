import SwiftUI
import AVFoundation

struct SongsViewAsset: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioFileURL: URL?
    @State private var audioFileName: String = ""
    @State private var audioDuration: String = ""
    
    var body: some View {
        VStack {
            Text(audioFileName)
                .font(.title)
                .padding()
            Text(audioDuration)
                .font(.subheadline)
                .padding()
            Button(action: {
                playOrPause()
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .frame(width: 64, height: 64)
            }
            .padding()
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
            if let audioFileURL = fileURLs.filter({ $0.pathExtension == "m4a" }).first {
                // Создайте экземпляр AVAudioPlayer и загрузите файл
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                // Сохраните URL, имя и продолжительность файла
                self.audioFileURL = audioFileURL
                audioFileName = audioFileURL.lastPathComponent
                audioDuration = formatTime(audioPlayer?.duration ?? 0)
            } else {
                // Если файл не найден, выведите сообщение об ошибке
                print("No audio file found")
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
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SongsViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        SongsViewAsset()
    }
}
