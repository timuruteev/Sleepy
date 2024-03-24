import SwiftUI
import AVFoundation

struct TimerView: View {
    @State private var time = Date()
    @Binding var wakeUpTime: Date // Используем @Binding для получения значения из FirstAlarm
    @Environment(\.presentationMode) var presentationMode // Добавьте эту строку
    @ObservedObject var audioPlayer: AudioPlayer // Добавьте эту строку
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Добавьте эти переменные для записи звука
    @State private var audioRecorder: AVAudioRecorder!
    @State private var isRecording = false
    @State private var audioFileURL: URL?
    
    var body: some View {
        ZStack {
                let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return formatter
            }()

            Color.black
                .ignoresSafeArea()
            VStack {
                Text(wakeUpTime, style: .time)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .onAppear() {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        let dateString = formatter.string(from: wakeUpTime)
                        wakeUpTime = formatter.date(from: dateString) ?? Date()
                    }
                Text("Будильник \(wakeUpTime.addingTimeInterval(-30*60), formatter: dateFormatter) – \(wakeUpTime, formatter: dateFormatter)")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                Button(action: {
                    isPlayed.isPlaying = true
                    audioPlayer.playOrPause()
                    isPlayed.isPlaying = false
                    isPlayed.index = 1
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Отмена")
                                            
                                        .font(.system(size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                                        .background(Color.red)
                                        .cornerRadius(50)
                }
                .onAppear() {
                        let audioSession = AVAudioSession.sharedInstance()
                        do {
                            // Активируйте сессию аудио с категорией воспроизведения
                            try audioSession.setCategory(.playback)
                            try audioSession.setActive(true)
                        } catch {
                            // Обработайте возможные ошибки
                            print("Failed to activate audio session: \(error)")
                        }
                    }
                
                // Добавьте эту кнопку для записи звука
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Text(isRecording ? "Остановить запись" : "Записать звук")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                        .background(Color.blue)
                        .cornerRadius(50)
                }
            }
        }
        
    }
    
    // Добавьте этот метод для начала записи звука
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Активируйте сессию аудио с категорией записи
            try audioSession.setCategory(.record)
            try audioSession.setActive(true)
            
            // Создайте URL для сохранения файла
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "recording-\(Date().timeIntervalSince1970).m4a"
            audioFileURL = documentsURL.appendingPathComponent(fileName)
            
            // Установите настройки для записи
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Создайте экземпляр AVAudioRecorder и начните запись
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder.record()
            
            // Измените состояние записи
            isRecording = true
        } catch {
            // Обработайте возможные ошибки
            print("Failed to start recording: \(error)")
        }
    }
    
    // Добавьте этот метод для остановки записи звука
    func stopRecording() {
        // Остановите запись и деактивируйте сессию аудио
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            // Обработайте возможные ошибки
            print("Failed to deactivate audio session: \(error)")
        }
        
        // Измените состояние записи
        isRecording = false
        
        // Сохраните или удалите файл в зависимости от вашего выбора
        // Здесь вы можете использовать Alert или ActionSheet для предоставления пользователю опций
        // Например, вы можете добавить опцию "Слушать", "Сохранить", "Удалить" или "Отменить"
        // В этом примере мы просто сохраняем файл в папке документов
        print("Saved audio file at \(audioFileURL!)")
    }
}

#Preview {
    TimerView(wakeUpTime: .constant(Date()), audioPlayer: AudioPlayer(sound: "alarm")) // Добавьте аргумент audioPlayer
}


