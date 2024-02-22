import SwiftUI
import AVFoundation



struct MainView: View {
    @State private var selectedTab = 0
    @State private var selectedButton = "Сон"
    
    var body: some View {
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

class AudioPlayer: NSObject, ObservableObject {
    // Свойство, которое хранит экземпляр AVAudioPlayer
    private var audioPlayer: AVAudioPlayer?
      @Published var isPlaying = false
    
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

            if player.isPlaying {
              player.pause()
              isPlaying = false
            } else {
              player.play()
              isPlaying = true
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

struct FirstAlarm: View {
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
    
    var body: some View {
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
                    isPresented = !isPresented
                    // Вызываем метод playOrPause на нашем AudioPlayer при нажатии кнопки
                    // audioPlayer.playOrPause() // Убираем эту строку, так как мы не хотим воспроизводить звук при нажатии кнопки
                    // Устанавливаем переменную isStarted в true, чтобы показать, что кнопка старт была нажата
                    isStarted = true
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
                    TimerView(wakeUpTime: $wakeUpTime)
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
                            if currentTime == alarmTime && isStarted && !audioPlayer.isPlaying {
                                audioPlayer.playOrPause()
            }
        }
    }
}


    
struct SecondAlarm: View {
    @State private var wakeUpTime = Date()
    @State private var selectedTab = "Сон"
    @State private var alarmIndex = 1

    // Создайте DateFormatter
    let secondAlarmDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
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
    
    
    struct ThirdAlarm: View {
        @State private var wakeUpTime = Date()
        @State private var selectedTab = "Сон"
        @State private var alarmIndex = 2
        
        var body: some View {
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
        static var previews: some View {
            MainView()
        }
    }

