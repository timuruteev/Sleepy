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
                ThirdAlarm()
                    .tag(2)
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
    
    // Инициализатор, который принимает имя файла звука
    init(sound: String) {
        super.init()
        // Пытаемся загрузить файл звука из основного пакета
        if let sound = Bundle.main.path(forResource: "alarm", ofType: "mp3") {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            } catch {
                print("AVAudioPlayer could not be instantiated.")
            }
        } else {
            print("Audio file could not be found.")
        }
    }
    

    // Метод, который воспроизводит или приостанавливает звук
    func playOrPause() {
        guard let player = audioPlayer else { return }

        
            // Измените логику метода playOrPause
            if isPlayed.isPlaying {
              player.stop()
                isPlayed.isPlaying = false            } else {
              player.play()
                    isPlayed.isPlaying = true
            }
        
        }
    }


// Расширяем класс AudioPlayer, чтобы он соответствовал протоколу AVAudioPlayerDelegate
extension AudioPlayer: AVAudioPlayerDelegate {
    // Метод, который вызывается, когда воспроизведение звука завершается
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
    @StateObject private var audioPlayer = AudioPlayer(sound: "alarm")
    
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
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute) // элемент выбора времени
                        .datePickerStyle(.wheel) // стиль элемента
                        .labelsHidden() // скрыть метки
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

                    // Форматирование даты и времени для записи в базу данных
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateAlarm = dateFormatter.string(from: currentDate)
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm:ss"
                    let startTime = timeFormatter.string(from: currentDate)
                    
                    // Путь к файлу базы данных в проекте
                    let path = Bundle.main.path(forResource: "Sleepy", ofType: "db")!
                    let db = try! Connection(path, readonly: false)
                    
                    // Определение таблицы
                    let statistic = Table("Statistic")
                    let idAlarm = Expression<Int64>("IdAlarm")
                    let dateAlarmExpr = Expression<String>("DateAlarm")
                    let startTimeExpr = Expression<String>("StartTime")
                    let endTimeExpr = Expression<String>("EndTime")
                    
                    // Вставка данных в таблицу
                    let insert = statistic.insert(dateAlarmExpr <- dateAlarm, startTimeExpr <- startTime, endTimeExpr <- startTime)
                    try! db.run(insert)
                    
                    // Проверка вставки данных
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
                        .font(.system(size: 20)) // Уменьшаем размер шрифта
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                        .background(Color.orange) // Меняем цвет на оранжевый
                        .cornerRadius(50) // Увеличиваем радиус скругления
                }
                .sheet(isPresented: $isPresented, content: {
                    TimerView(wakeUpTime: $wakeUpTime, audioPlayer: audioPlayer) // Передаем объект audioPlayer в TimerView
                })
                .padding(.horizontal)
                Spacer()
            }
        }
        // Добавляем модификатор onReceive, который будет получать события от таймера
        .onReceive(timer) { _ in
                            // Получаем текущее время в формате часов и минут
                            let currentTime = dateFormatter.string(from: Date())
                            // Получаем время пробуждения в том же формате
                            let alarmTime = dateFormatter.string(from: wakeUpTime)
                            // Сравниваем их, и если они совпадают, то воспроизводим звук
                            // Но только если переменная isStarted равна true, то есть кнопка старт была нажата
                            // И только если звук еще не играет, чтобы не прерывать его
            if currentTime == alarmTime && isStarted && !isPlayed.isPlaying && isPlayed.index == 0{
                                audioPlayer.playOrPause()
            }
        }
    }
}



struct SecondAlarm: SwiftUI.View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 1

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
                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute) // элемент выбора времени
                                    .datePickerStyle(.wheel) // стиль элемента
                                    .labelsHidden() // скрыть метки
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
                    Button(action: {}) {
                        Text("Старт")
                            .font(.system(size: 20)) // Уменьшаем размер шрифта
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                            .background(Color.blue) // Меняем цвет на оранжевый
                            .cornerRadius(50) // Увеличиваем радиус скругления
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }
    }
    
    
    struct ThirdAlarm: SwiftUI.View {
        @State private var wakeUpTime = Date()
        @State private var selectedTab = "Сон"
        @State private var alarmIndex = 2
        
        var body: some SwiftUI.View {
            ZStack {
                VStack(spacing: 30) {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()

                    VStack(spacing: 10) {
                        Text("Без интервала пробуждения.")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Только анализ сна")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    Spacer()

                        Button(action: {}) {
                            Text("Старт")
                                .font(.system(size: 20)) // Уменьшаем размер шрифта
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50)) // Увеличиваем горизонтальные отступы
                                .background(Color.blue) // Меняем цвет на оранжевый
                                .cornerRadius(50) // Увеличиваем радиус скругления
                                .opacity(0.6)
                        }
                        .padding(.horizontal)
                        Spacer()
                    Spacer()

                    }
                }
            }
        }
    
    
    struct MainView_Previews: PreviewProvider {
        static var previews: some SwiftUI.View {
            MainView()
        }
    }

