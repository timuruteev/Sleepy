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
                    isPresented = !isPresented
                    // Вызываем метод playOrPause на нашем AudioPlayer при нажатии кнопки
                    // Устанавливаем переменную isStarted в true, чтобы показать, что кнопка старт была нажата
                    isStarted = true
                    // Вместо того, чтобы создавать таймер, который запускается каждую секунду, создайте таймер, который запускается только один раз в нужное время
                    // Вычислите интервал времени, как разницу между временем пробуждения и текущим временем
                    let interval = wakeUpTime.timeIntervalSince(Date())
                    // Создайте таймер, который запустится через интервал времени, не будет повторяться и выполнит блок кода
                    let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                        // В блоке кода воспроизведите звук, если переменная isStarted равна true и звук еще не играет
                        if isStarted && !audioPlayer.isPlaying {
                            audioPlayer.playOrPause()
                        }
                    }
                }) {
                    Text("Старт")
                        .font(.system(size: 20)) // Уменьшаем размер шрифта
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 50))
                        .background(Color.orange)
                        .cornerRadius(50)
                }
                .sheet(isPresented: $isPresented, content: {
                    TimerView(wakeUpTime: $wakeUpTime, audioPlayer: audioPlayer) // Добавьте этот параметр
                })
                .padding(.horizontal)
                Spacer()
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

