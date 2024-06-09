import SwiftUI
import AVFoundation
import SQLite

struct SongViewAsset: SwiftUI.View {
    @State private var selectedSong: String
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentPlayingSong: String?
    let songs = ["Alerta", "Sirenize", "Clockwise", "Chimy", "Kevat"]
    @Environment(\.presentationMode) var presentationMode

    init() {
        _selectedSong = State(initialValue: SongViewAsset.fetchCurrentAlarmSound())
    }
    
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
            return "Clockwise"
        }
    }

    func updateAlarmSound(selectedSong: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        let db = try! Connection(finalDatabaseURL.path)
        
        let alarmSoundTable = Table("AlarmSound")
        let soundName = Expression<String>("SoundName")
        let soundPath = Expression<String>("SoundPath")
        
        let relativeSoundPath = "/\(selectedSong).mp3"
        
        try! db.run(alarmSoundTable.delete())
        
        let insert = alarmSoundTable.insert(soundName <- selectedSong, soundPath <- relativeSoundPath)
        try! db.run(insert)
    }

    func playOrPauseSound(song: String) {
        if isPlaying && currentPlayingSong == song {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let soundFilePath = documentsDirectory.appendingPathComponent("Sounds/\(song).mp3").path
            
            if fileManager.fileExists(atPath: soundFilePath) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFilePath))
                    audioPlayer?.play()
                    isPlaying = true
                    currentPlayingSong = song
                } catch {
                    print("Ошибка при попытке воспроизвести звук: \(error)")
                }
            } else {
                print("Аудиофайл не найден по пути: \(soundFilePath)")
            }
        }
    }

    var body: some SwiftUI.View {
        NavigationView {
            List {
                ForEach(songs, id: \.self) { song in
                    HStack {
                        Button(action: {
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
                        
                        Spacer()
                        
                        Button(action: {
                            playOrPauseSound(song: song)
                        }) {
                            Image(systemName: isPlaying && currentPlayingSong == song ? "pause.circle" : "play.circle")
                                .foregroundColor(.blue)
                        }
                    }
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
    static var previews: some SwiftUI.View {
        SongViewAsset()
    }
}
