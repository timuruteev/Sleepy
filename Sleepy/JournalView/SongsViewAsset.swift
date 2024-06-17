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
    @State private var isShowingShareSheet = false
    @State private var isShowingDeleteAlert = false
    
    init(selectedDate: SwiftUI.Binding<Date>) {
        self._selectedDate = selectedDate
        copySoundsFolderIfNeeded()
    }
    
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
                if audioFileURL != nil {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                playOrPause()
                            }
                        }) {
                            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
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
                        .padding(.trailing, 10)
                        
                        VStack {
                            Spacer()
                            Button(action: {
                                isShowingShareSheet = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .frame(width: 28, height: 36)
                            }
                            Spacer()
                        }
                        .frame(height: 44)
                        .padding(.trailing)
                        
                        VStack {
                            Spacer()
                            Button(action: {
                                isShowingDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 28, height: 36)
                            }
                            Spacer()
                        }
                        .frame(height: 44)
                        .padding(.trailing)
                    }
                } else {
                    Text("Нет записанных звуков")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .sheet(isPresented: $isShowingShareSheet, content: {
            if let audioFileURL = audioFileURL {
                ShareSheet(activityItems: [audioFileURL])
            }
        })
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("Удалить запись"),
                message: Text("Вы уверены, что хотите удалить эту запись?"),
                primaryButton: .destructive(Text("Удалить")) {
                    deleteAudioFile()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear() {
            loadAudioFileFromDatabase()
        }
        .onChange(of: selectedDate) { newDate in
            loadAudioFileFromDatabase()
        }
    }
    
    func copySoundsFolderIfNeeded() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalSoundsDirectory = documentsDirectory.appendingPathComponent("sounds")

        if !fileManager.fileExists(atPath: finalSoundsDirectory.path) {
            guard let bundleSoundsURL = Bundle.main.url(forResource: "sounds", withExtension: nil) else {
                print("Sounds directory not found in bundle")
                return
            }
            do {
                let soundFiles = try fileManager.contentsOfDirectory(at: bundleSoundsURL, includingPropertiesForKeys: nil, options: [])
                try fileManager.createDirectory(at: finalSoundsDirectory, withIntermediateDirectories: true, attributes: nil)
                
                for file in soundFiles {
                    let destinationURL = finalSoundsDirectory.appendingPathComponent(file.lastPathComponent)
                    try fileManager.copyItem(at: file, to: destinationURL)
                    print("Copied \(file.lastPathComponent) to \(destinationURL.path)")
                }
                print("Sounds directory copied to documents directory at path: \(finalSoundsDirectory.path)")
            } catch {
                print("Error copying sounds directory: \(error)")
            }
        } else {
            print("Sounds directory already exists at path: \(finalSoundsDirectory.path)")
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
                    audioFileURL = URL(fileURLWithPath: fullPath)
                    audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL!)
                    audioDuration = formatTime(audioPlayer?.duration ?? 0)
                    
                    if let creationDate = getFileCreationDate(audioFileURL!) {
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
            audioFileURL = nil
            audioPlayer = nil
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
    
    func deleteAudioFile() {
        guard let audioFileURL = audioFileURL else { return }
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: audioFileURL)
            
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let databaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
            
            let db = try Connection(databaseURL.path, readonly: false)
            let audioRecord = Table("AudioRecord")
            let soundPathExpr = Expression<String>("SoundPath")
            
            let relativePath = audioFileURL.path.replacingOccurrences(of: documentsDirectory.path, with: "")
            let query = audioRecord.filter(soundPathExpr == relativePath)
            
            try db.run(query.delete())
            
            self.audioFileURL = nil
            self.audioPlayer = nil
            self.audioDuration = ""
            self.audioTitle = ""
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Ошибка при удалении записанного звука"
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

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SongsViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        SongsViewAsset(selectedDate: .constant(Date()))
            .background(Color.black)
    }
}
