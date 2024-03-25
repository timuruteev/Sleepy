import SwiftUI
import AVFoundation
import SQLite

struct TimerView: SwiftUI.View {
    @State private var time = Date()
    @SwiftUI.Binding var wakeUpTime: Date
    @State private var cancelTime: Date?
    @Environment(\.presentationMode) var presentationMode // Добавьте эту строку
    @ObservedObject var audioPlayer: AudioPlayer // Добавьте эту строку
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Добавьте эти переменные для записи звука
    @State private var audioRecorder: AVAudioRecorder!
    @State private var isRecording = false
    @State private var audioFileURL: URL?
    
    func updateEndTime() {
        guard let cancelTime = cancelTime else { return }
        
        // Форматирование времени для записи в базу данных
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let endTime = timeFormatter.string(from: cancelTime)
        
        // Путь к файлу базы данных в проекте
        let path = Bundle.main.path(forResource: "Sleepy", ofType: "db")!
        let db = try! Connection(path, readonly: false)
        
        // Определение таблицы и выражений
        let statistic = Table("Statistic")
        let idAlarm = Expression<Int64>("IdAlarm")
        let endTimeExpr = Expression<String>("EndTime")
        
        // Обновление endTime в последней записи
        if let lastId = try? db.scalar(statistic.select(idAlarm.max)) {
            let query = statistic.filter(idAlarm == lastId)
            try! db.run(query.update(endTimeExpr <- endTime))
            
            displayUpdatedData(db: db, statistic: statistic)
        }
    }
    
    func displayUpdatedData(db: Connection, statistic: SQLite.Table) {
        let idAlarm = Expression<Int64>("IdAlarm")
        let dateAlarmExpr = Expression<String>("DateAlarm")
        let startTimeExpr = Expression<String>("StartTime")
        let endTimeExpr = Expression<String>("EndTime")
        
        // Выборка и вывод данных
        let query = statistic.select(*)
        do {
            for row in try db.prepare(query) {
                print("IdAlarm: \(row[idAlarm]), DateAlarm: \(row[dateAlarmExpr]), StartTime: \(row[startTimeExpr]), EndTime: \(row[endTimeExpr])")
            }
        } catch {
            print("Ошибка при выборке данных: \(error)")
        }
    }

    var body: some SwiftUI.View {
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
                        DispatchQueue.main.async {
                            self.wakeUpTime = formatter.date(from: dateString) ?? Date()
                        }
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
                    cancelTime = Date()
                    presentationMode.wrappedValue.dismiss()
                    updateEndTime()
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


