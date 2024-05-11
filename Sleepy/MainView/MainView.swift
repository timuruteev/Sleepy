import SwiftUI
import AVFoundation
import SQLite

struct MainView: SwiftUI.View {
    @State private var selectedTab = 0
    @State private var selectedButton = "Сон"
    
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

class isPlayed{
    static var isPlaying = false
    static var index = 0
}

class AudioPlayer: NSObject, ObservableObject {
    // Свойство, которое хранит экземпляр AVAudioPlayer
    private var audioPlayer: AVAudioPlayer?
    
    // Инициализатор, который теперь будет загружать звук из базы данных
    override init() {
        super.init()
        loadLatestSound()
    }
    
    // Метод для загрузки последнего звука будильника
    func loadLatestSound() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
        
        // Подключаемся к базе данных
        let db = try! Connection(databaseURL.path, readonly: false)
        
        // Определяем таблицу и выражения
        let alarmSound = Table("AlarmSound")
        let soundPathExpr = Expression<String>("SoundPath")
        
        // Выбираем последний добавленный звук будильника
        if let lastAlarmSound = try? db.pluck(alarmSound.order(Expression<Int64>("IdAlarmSound").desc)) {
            let soundPath = lastAlarmSound[soundPathExpr]
            
            // Удаляем начальный слеш из пути, если он есть
            let trimmedSoundPath = soundPath.hasPrefix("/") ? String(soundPath.dropFirst()) : soundPath
            
            // Формируем полный путь к файлу звука, учитывая папку Sounds
            let soundFilePath = documentsDirectory
                .appendingPathComponent("Sounds", isDirectory: true)
                .appendingPathComponent(trimmedSoundPath).path
            
            // Проверяем, существует ли файл по этому пути
            if fileManager.fileExists(atPath: soundFilePath) {
                // Пытаемся загрузить файл звука
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFilePath))
                } catch {
                    print("AVAudioPlayer could not be instantiated: \(error)")
                }
            } else {
                print("Audio file does not exist at the path: \(soundFilePath)")
            }
        } else {
            print("Audio file could not be found in the database.")
        }
    }
    
    func updateSound() {
        loadLatestSound()
    }
    
    // Метод, который воспроизводит или приостанавливает звук
    func playOrPause() {
        
        updateSound()
        
        guard let player = audioPlayer else { return }

            // Изменим логику метода playOrPause
            if isPlayed.isPlaying {
              player.stop()
            player.currentTime = 0
                isPlayed.isPlaying = false            } else {
                    player.currentTime = 0 // Сбросим время воспроизведения
                            player.prepareToPlay()
              player.play()
                    isPlayed.isPlaying = true
            }
        
        }
    }

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Выводим сообщение в консоль, если воспроизведение завершилось успешно
        if flag {
            print("Sound finished playing successfully")
        }
    }
}


struct FirstAlarm: SwiftUI.View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 0
    @State private var isPresented = false
    
    // Создаем экземпляр AudioPlayer с именем файла звука
    @StateObject private var audioPlayer = AudioPlayer()
    
    // Создаем таймер, который будет запускаться каждую секунду
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Создаем переменную состояния, которая будет хранить, была ли нажата кнопка старт
    @State private var isStarted = false
    
    // Создайте DateFormatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    
    var body: some SwiftUI.View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .preferredColorScheme(.dark)
                    Text("Просыпайтесь легко между")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("\(wakeUpTime.addingTimeInterval(-30*60), formatter: dateFormatter) – \(wakeUpTime, formatter: dateFormatter)")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Button(action: {
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
        
        .onReceive(timer) { _ in
                            let currentTime = dateFormatter.string(from: Date())
                            let alarmTime = dateFormatter.string(from: wakeUpTime)
                            
            if currentTime == alarmTime && isStarted && !isPlayed.isPlaying && isPlayed.index == 0{
            audioPlayer.playOrPause()
            }
        }
    }
}

struct SecondAlarm: SwiftUI.View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 0
    @State private var isPresented = false
    
    // Создаем экземпляр AudioPlayer с именем файла звука
    @StateObject private var audioPlayer = AudioPlayer()
    
    // Создаем таймер, который будет запускаться каждую секунду
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Создаем переменную состояния, которая будет хранить, была ли нажата кнопка старт
    @State private var isStarted = false
    
    // Создайте DateFormatter
    let secondAlarmDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
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
            
            .onReceive(timer) { _ in
                                let currentTime = dateFormatter.string(from: Date())
                                let alarmTime = dateFormatter.string(from: wakeUpTime)
                                
                if currentTime == alarmTime && isStarted && !isPlayed.isPlaying && isPlayed.index == 1{
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

