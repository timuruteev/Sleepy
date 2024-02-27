import SwiftUI
import AVFoundation

struct TimerView: View {
    @State private var time = Date()
    @Binding var wakeUpTime: Date // Используем @Binding для получения значения из FirstAlarm
    @Environment(\.presentationMode) var presentationMode // Добавьте эту строку
    @ObservedObject var audioPlayer: AudioPlayer // Добавьте эту строку
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            
            // Создайте DateFormatter
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
                    // Измените действие кнопки Отмена
                    // Получаем текущее время в формате часов и минут
                    isPlayed.isPlaying = true
                    audioPlayer.playOrPause()
                        // Установите isPlaying в false, чтобы отобразить правильное состояние проигрывателя
                    isPlayed.isPlaying = false
                    isPlayed.index = 1
                    presentationMode.wrappedValue.dismiss() // Закройте модальное окно              
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
                        // Добавьте этот код
                        // Создайте объект сессии аудио
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
                }
            }
        }
        
    }




#Preview {
    TimerView(wakeUpTime: .constant(Date()), audioPlayer: AudioPlayer(sound: "alarm")) // Добавьте аргумент audioPlayer
}
