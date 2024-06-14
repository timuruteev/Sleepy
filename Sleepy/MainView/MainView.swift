import SwiftUI
import AVFoundation
import SQLite

struct MainView: SwiftUI.View {
    @State private var selectedTab = 0

    var body: some SwiftUI.View {
        ZStack {
            TabView(selection: $selectedTab) {
                FirstAlarm()
                    .tag(0)
                SecondAlarm()
                    .tag(1)
            }
            .background(.black)
            .tabViewStyle(.page)
            VStack {
                Spacer()
            }
        }
    }
}

class isPlayed {
    static var isPlaying = false
    static var index = 0
}

class AudioPlayer: NSObject, ObservableObject {
    var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
        loadLatestSound()
    }

    func loadLatestSound() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")

        let db = try! Connection(databaseURL.path, readonly: false)

        let alarmSound = Table("AlarmSound")
        let soundPathExpr = Expression<String>("SoundPath")

        if let lastAlarmSound = try? db.pluck(alarmSound.order(Expression<Int64>("IdAlarmSound").desc)) {
            let soundPath = lastAlarmSound[soundPathExpr]

            let trimmedSoundPath = soundPath.hasPrefix("/") ? String(soundPath.dropFirst()) : soundPath

            let soundFilePath = documentsDirectory
                .appendingPathComponent("Sounds", isDirectory: true)
                .appendingPathComponent(trimmedSoundPath).path

            if fileManager.fileExists(atPath: soundFilePath) {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFilePath))
                    self.audioPlayer?.delegate = self
                } catch {
                    print("AVAudioPlayer не может быть инициализирован: \(error)")
                }
            } else {
                print("Аудиофайл не находится по пути: \(soundFilePath)")
            }
        } else {
            print("Аудиофайл не найден в Базе данных.")
        }
    }

    func updateSound() {
        loadLatestSound()
    }

    func playOrPause() {
        updateSound()

        guard let player = audioPlayer else { return }

        if isPlayed.isPlaying {
            player.stop()
            player.currentTime = 0
            isPlayed.isPlaying = false
        } else {
            player.currentTime = 0
            player.prepareToPlay()
            player.play()
            isPlayed.isPlaying = true
        }
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag && isPlayed.isPlaying {
            player.currentTime = 0
            player.play()
            print("Звук воспроизведен заново")
        }
    }
}

struct FirstAlarm: SwiftUI.View {
    @State private var wakeUpTime = Date()
    @State private var isPresented = false

    @StateObject private var audioPlayer = AudioPlayer()
    
    let timer = Timer.publish(every: 0.0001, on: .main, in: .common).autoconnect()
    @State private var isStarted = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    func calculateWakeUpTime() {
        let calendar = Calendar.current
        let currentTime = Date()
        let eightHours: TimeInterval = 8 * 60 * 60

        var wakeUpComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: wakeUpTime)
        var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentTime)

        wakeUpComponents.year = currentComponents.year
        wakeUpComponents.month = currentComponents.month
        wakeUpComponents.day = currentComponents.day

        if wakeUpTime < currentTime {
            wakeUpComponents.day! += 1
        }

        guard let adjustedWakeUpTime = calendar.date(from: wakeUpComponents) else { return }

        let sleepDuration = adjustedWakeUpTime.timeIntervalSince(currentTime)

        if sleepDuration < 60 * 60 {
        } else {
            if sleepDuration <= eightHours {
                wakeUpTime = calendar.date(byAdding: .minute, value: 30, to: adjustedWakeUpTime)!
            } else {
                wakeUpTime = calendar.date(byAdding: .minute, value: -30, to: adjustedWakeUpTime)!
            }
        }
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

    var body: some SwiftUI.View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .preferredColorScheme(.dark)

                    let intervalToWakeUpTime = wakeUpTime.timeIntervalSinceNow
                    let calendar = Calendar.current
                    let isNextDay = wakeUpTime < Date() || calendar.isDateInTomorrow(wakeUpTime)
                    let isCurrentTime = calendar.isDate(Date(), equalTo: wakeUpTime, toGranularity: .minute)

                    if isCurrentTime {
                        Text("Без интервала пробуждения")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Сработает в \(wakeUpTime, formatter: dateFormatter)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    } else if intervalToWakeUpTime < 60 * 60 && !isNextDay {
                        Text("Без интервала пробуждения")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Сработает в \(wakeUpTime, formatter: dateFormatter)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Просыпайтесь легко между")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("\(wakeUpTime.addingTimeInterval(-30*60), formatter: dateFormatter) – \(wakeUpTime.addingTimeInterval(30*60), formatter: dateFormatter)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()
                Button(action: {
                    calculateWakeUpTime()
                    scheduleAlarmNotification(wakeUpTime: wakeUpTime)
                    let currentDate = Date()
                    isStarted = true
                    isPresented = !isPresented
                    isPlayed.isPlaying = false
                    isPlayed.index = 0

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateAlarm = dateFormatter.string(from: currentDate)

                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm:ss"
                    let startTime = timeFormatter.string(from: currentDate)

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
                    let dateAlarmExpr = Expression<String>("DateAlarm")
                    let startTimeExpr = Expression<String>("StartTime")
                    let endTimeExpr = Expression<String>("EndTime")

                    let insert = statistic.insert(dateAlarmExpr <- dateAlarm, startTimeExpr <- startTime, endTimeExpr <- timeFormatter.string(from: wakeUpTime))
                    try! db.run(insert)

                    let query = statistic.select(*)
                    do {
                        for row in try db.prepare(query) {
                            print("IdAlarm: \(row[idAlarm]), DateAlarm: \(row[dateAlarmExpr]), StartTime: \(row[startTimeExpr]), EndTime: \(row[endTimeExpr])")
                        }
                    } catch {
                        print("Ошибка при выборке данных: \(error)")
                    }

                }) {

                    Text("Старт")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                        .background(Color.orange)
                        .cornerRadius(50)
                }
                .sheet(isPresented: $isPresented, content: {
                    TimerView(wakeUpTime: $wakeUpTime, audioPlayer: audioPlayer, alarmIndex: 0)
                })
                .padding(.horizontal)
                Spacer()
            }
        }
        .onAppear {
            wakeUpTime = Date()
        }
        .onReceive(timer) { _ in
            let currentTime = dateFormatter.string(from: Date())
            let alarmTime = dateFormatter.string(from: wakeUpTime)

            if currentTime == alarmTime && isStarted && !isPlayed.isPlaying && isPlayed.index == 0 {
                audioPlayer.playOrPause()
            }
        }
    }
}

struct SecondAlarm: SwiftUI.View {
    @State private var wakeUpTime = Date()
    @State private var isPresented = false

    @StateObject private var audioPlayer = AudioPlayer()

    let timer = Timer.publish(every: 0.0001, on: .main, in: .common).autoconnect()
    @State private var isStarted = false

    let secondAlarmDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    func scheduleAlarmNotification(wakeUpTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Будильник"
        content.body = "Пора просыпаться! Время: \(wakeUpTime.formatted(.dateTime.hour().minute()))"
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

    var body: some SwiftUI.View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .preferredColorScheme(.dark)
                    Text("Без интервала пробуждения.")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Сработает в \(wakeUpTime, formatter: secondAlarmDateFormatter)")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Button(action: {
                    scheduleAlarmNotification(wakeUpTime: wakeUpTime)
                    let currentDate = Date()
                    isStarted = true
                    isPresented = !isPresented
                    isPlayed.isPlaying = false
                    isPlayed.index = 1

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateAlarm = dateFormatter.string(from: currentDate)

                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm:ss"
                    let startTime = timeFormatter.string(from: currentDate)

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
                    let dateAlarmExpr = Expression<String>("DateAlarm")
                    let startTimeExpr = Expression<String>("StartTime")
                    let endTimeExpr = Expression<String>("EndTime")

                    let insert = statistic.insert(dateAlarmExpr <- dateAlarm, startTimeExpr <- startTime, endTimeExpr <- startTime)
                    try! db.run(insert)

                    let query = statistic.select(*)
                    do {
                        for row in try db.prepare(query) {
                            print("IdAlarm: \(row[idAlarm]), DateAlarm: \(row[dateAlarmExpr]), StartTime: \(row[startTimeExpr]), EndTime: \(row[endTimeExpr])")
                        }
                    } catch {
                        print("Ошибка при выборке данных: \(error)")
                    }

                }) {

                    Text("Старт")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                        .background(Color.blue)
                        .cornerRadius(50)
                }
                .sheet(isPresented: $isPresented, content: {
                    TimerView(wakeUpTime: $wakeUpTime, audioPlayer: audioPlayer, alarmIndex: 1)
                })
                .padding(.horizontal)
                Spacer()
            }
        }
        .onAppear {
            wakeUpTime = Date()
        }
        .onReceive(timer) { _ in
            let currentTime = secondAlarmDateFormatter.string(from: Date())
            let alarmTime = secondAlarmDateFormatter.string(from: wakeUpTime)

            if currentTime == alarmTime && isStarted && !isPlayed.isPlaying && isPlayed.index == 1 {
                audioPlayer.playOrPause()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        MainView()
    }
}
