import SwiftUI
import AVFoundation
import SQLite
import UserNotifications

struct TimerView: SwiftUI.View {
    @State private var time = Date()
    @SwiftUI.Binding var wakeUpTime: Date
    @State private var cancelTime: Date?
    @State private var showImage = false
    @State private var isAlarmPlaying = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioPlayer: AudioPlayer
    
    @State private var isStarted = true
    @State private var isSnoozeButtonVisible = true // добавляем состояние для видимости кнопки "Повтор"
    @State private var audioRecorder: AVAudioRecorder!
    @State private var isRecording = false
    @State private var audioFileURL: URL?
    @State var alarmIndex: Int
    
    let timer = Timer.publish(every: 0.0001, on: .main, in: .common).autoconnect()
    let notificationCenter = NotificationCenter.default

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено.")
            } else {
                print("Разрешение на уведомления не получено.")
            }

            if let error = error {
                print("Ошибка при запросе разрешения на уведомления: \(error.localizedDescription)")
            }
        }
    }

    func updateEndTime() {
        guard let cancelTime = cancelTime else { return }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let endTime = timeFormatter.string(from: cancelTime)
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        if !fileManager.fileExists(atPath: finalDatabaseURL.path) {
            let databaseBundleURL = Bundle.main.url(forResource: "Sleepy1", withExtension: "db")!
            do {
                try fileManager.copyItem(at: databaseBundleURL, to: finalDatabaseURL)
            } catch {
                print("Ошибка копирования файла базы данных: \(error)")
            }
        }
        
        let db = try! Connection(finalDatabaseURL.path, readonly: false)
        
        let statistic = Table("Statistic")
        let idAlarm = Expression<Int64>("IdAlarm")
        let endTimeExpr = Expression<String>("EndTime")
        
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
        
        let query = statistic.select(*)
        do {
            for row in try db.prepare(query) {
                print("IdAlarm: \(row[idAlarm]), DateAlarm: \(row[dateAlarmExpr]), StartTime: \(row[startTimeExpr]), EndTime: \(row[endTimeExpr])")
            }
        } catch {
            print("Ошибка при выборке данных: \(error)")
        }
    }
    
    func resetWakeUpTime() {
        wakeUpTime = Date()
        isStarted = false
    }
    
    func snoozeAlarm() {
        audioPlayer.playOrPause()
        showImage = false
        
        wakeUpTime = Date().addingTimeInterval(1 * 60)
        scheduleAlarmNotification(wakeUpTime: wakeUpTime)
        isStarted = true
        isSnoozeButtonVisible = false // скрываем кнопку "Повтор" после нажатия
    }
    
    func scheduleAlarmNotification(wakeUpTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Пора просыпаться!"
        content.body = "Время: \(wakeUpTime.formatted(.dateTime.hour().minute()))"
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: wakeUpTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error)")
            } else {
                print("Уведомление успешно запланировано на \(wakeUpTime)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
                
                if showImage {
                    if let image = UIImage(named: "Clock") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }
                }
                
                Text("Время пробуждения")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(wakeUpTime, style: .time)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .onAppear {
                        requestNotificationAuthorization()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        let dateString = formatter.string(from: wakeUpTime)
                        DispatchQueue.main.async {
                            self.wakeUpTime = formatter.date(from: dateString) ?? Date()
                        }
                        notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                            updateViewOnReturn()
                        }
                    }
                    .onReceive(timer) { _ in
                        let currentTime = dateFormatter.string(from: Date())
                        let alarmTime = dateFormatter.string(from: wakeUpTime)
                        
                        if currentTime == alarmTime && isStarted {
                            if !isPlayed.isPlaying && (isPlayed.index == 0 || isPlayed.index == 1) {
                                showImage = true
                                isAlarmPlaying = true
                                playAlarmSound()
                                isPlayed.isPlaying = true
                                isSnoozeButtonVisible = true // показываем кнопку "Повтор" для нового будильника
                                scheduleAlarmNotification(wakeUpTime: wakeUpTime) // запланировать уведомление для повтора
                            }
                        } else if isPlayed.isPlaying && isPlayed.index == 2 {
                            audioPlayer.playOrPause()
                            isPlayed.isPlaying = false
                            showImage = false
                            isAlarmPlaying = false
                        }
                    }
                
                Button(action: {
                    isPlayed.isPlaying = true
                    audioPlayer.playOrPause()
                    isPlayed.isPlaying = false
                    isPlayed.index = 2
                    cancelTime = Date()
                    resetWakeUpTime()
                    presentationMode.wrappedValue.dismiss()
                    updateEndTime()
                    cancelAllNotifications() // Отменяем все запланированные уведомления
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
                        try audioSession.setCategory(.playback)
                        try audioSession.setActive(true)
                    } catch {
                        print("Ошибка активации аудио: \(error)")
                    }
                }
                
                Spacer().frame(height: 20)
                
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Text(isRecording ? "Остановить" : "Запись")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                        .background(Color.blue)
                        .cornerRadius(50)
                }
                
                if isAlarmPlaying && isSnoozeButtonVisible {
                    Spacer().frame(height: 200)
                    Button(action: {
                        snoozeAlarm()
                    }) {
                        Text("Повтор")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                            .background(Color.orange)
                            .cornerRadius(50)
                    }
                }
            }
        }
    }
    
    func updateViewOnReturn() {
        if isStarted && !isPlayed.isPlaying && (isPlayed.index == 0 || isPlayed.index == 1) {
            showImage = true
            isAlarmPlaying = true
            isSnoozeButtonVisible = true
        }
    }
    
    func playAlarmSound() {
        if let audioPlayer = audioPlayer.audioPlayer {
            if !audioPlayer.isPlaying {
                audioPlayer.currentTime = 0
                audioPlayer.play()
            }
        }
    }
    
    func getRelativePathForAudioFile(_ audioFileURL: URL) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let relativePath = audioFileURL.path.replacingOccurrences(of: documentsURL.path, with: "")
        return relativePath
    }
    
    func saveRecordingToDatabase(idAlarmValue: Int64, audioFileURL: URL) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let relativePath = getRelativePathForAudioFile(audioFileURL)
        
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        let db = try! Connection(finalDatabaseURL.path, readonly: false)
        
        let audioRecord = Table("AudioRecord")
        let idAlarmExpr = Expression<Int64>("IdAlarm")
        let soundPathExpr = Expression<String>("SoundPath")
        
        let insert = audioRecord.insert(idAlarmExpr <- idAlarmValue,
                                        soundPathExpr <- relativePath)
        try! db.run(insert)
        
        print("Аудио сохранено по пути: \(audioFileURL.path)")
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let dateString = dateFormatter.string(from: Date())
            let fileName = "\(dateString).m4a"
            audioFileURL = documentsURL.appendingPathComponent(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder.record()
            
            isRecording = true
        } catch {
            print("Ошибка начала записи: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("Ошибка остановки записи: \(error)")
        }
        
        isRecording = false
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        if (!fileManager.fileExists(atPath: finalDatabaseURL.path)) {
            let databaseBundleURL = Bundle.main.url(forResource: "Sleepy1", withExtension: "db")!
            do {
                try fileManager.copyItem(at: databaseBundleURL, to: finalDatabaseURL)
            } catch {
                print("Ошибка копирования файла базы данных: \(error)")
            }
        }
        
        let db = try! Connection(finalDatabaseURL.path, readonly: false)
        
        let statistic = Table("Statistic")
        
        let idAlarm = Expression<Int64>("IdAlarm")
        if let lastIdAlarm = try? db.scalar(statistic.select(idAlarm.max)) {
            saveRecordingToDatabase(idAlarmValue: lastIdAlarm, audioFileURL: audioFileURL!)
        } else {
            print("Не удалось получить IdAlarm из таблицы Statistic")
        }
        
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print("Ошибка активации аудио: \(error)")
        }
        
        print("Saved audio file at \(audioFileURL!)")
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        TimerView(wakeUpTime: .constant(Date()), audioPlayer: AudioPlayer(), alarmIndex: 0)
    }
}
