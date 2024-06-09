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
    @State private var audioTitle: String = ""
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
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Записано: \(audioTitle)")
                            .font(.subheadline)
                        Text("Длительность: \(audioDuration)")
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
    
    func loadAudioFileFromDatabase() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        let db = try! Connection(databaseURL.path, readonly: true)
        
        let audioRecord = Table("AudioRecord")
        let statistic = Table("Statistic")
        let idAlarmExpr = Expression<Int64>("IdAlarm")
        let soundPathExpr = Expression<String>("SoundPath")
        let dateAlarmExpr = Expression<String>("DateAlarm")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)
        
        let query = audioRecord.join(statistic, on: audioRecord[idAlarmExpr] == statistic[idAlarmExpr])
                               .filter(statistic[dateAlarmExpr] == selectedDateString)
                               .order(statistic[idAlarmExpr].desc)
        
        if let lastAudioRecord = try? db.pluck(query) {
            let relativePath = lastAudioRecord[soundPathExpr]
            let fullPath = documentsDirectory.appendingPathComponent(relativePath).path
            
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fullPath))
                    audioDuration = formatTime(audioPlayer?.duration ?? 0)
                    
                    if let creationDate = getFileCreationDate(URL(fileURLWithPath: fullPath)) {
                        audioTitle = formatDate(creationDate)
                    } else {
                        audioTitle = "Дата создания файла неизвестна"
                    }
                    
                    audioPlayer?.prepareToPlay()
                    self.errorMessage = nil
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

    func playOrPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback)
                try audioSession.setActive(true)
            } catch {
                print("Ошибка активации аудио: \(error)")
            }
            player.play()
            isPlaying = true
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let word = seconds == 1 ? "секунда" : (seconds > 1 && seconds < 5 ? "секунды" : "секунд")
        return String(format: "%d \(word)", seconds)
    }
    
    func getFileCreationDate(_ url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date
        } catch {
            print("Failed to get file attributes: \(error)")
            return nil
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM в HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct SongsViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        SongsViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
