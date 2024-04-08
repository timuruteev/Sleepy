import SwiftUI

struct SettingsViewAsset: View {
    // добавьте эту переменную, чтобы хранить состояние перехода
    @State private var showWakeUpPeriod = false
    // добавьте еще одну переменную, чтобы хранить состояние перехода для звука
    @State private var showSong = false
    
    @State private var showRepeat = false

    @State private var showVibration = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Настройки")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            
            Divider()
                .background(Color.gray)
            
            
            HStack {
                Image(systemName:"clock.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    Text("Период засыпания")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("15 минут")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading) // добавьте эту строку, чтобы выровнять текст по левому краю
                
                Spacer()
                
                Image(systemName:"chevron.right")
                    .resizable()
                    .frame(width : 12, height : 18)
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding()
            // добавьте этот модификатор, чтобы обернуть HStack в кнопку, которая активирует переход
            .onTapGesture {
                showWakeUpPeriod = true
            }
            // добавьте этот модификатор, чтобы добавить лист, который отображает окно WakeUpPeriodViewAsset
            .sheet(isPresented: $showWakeUpPeriod) {
                TimeToSleep()
            }
            
            HStack {
                Image(systemName:"music.note")
                    .resizable()
                    .frame(width : 22, height : 32)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    Text("Звук")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Теплый ветер")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                .padding(5)
                Spacer()
                
                Image(systemName:"chevron.right")
                    .resizable()
                    .frame(width : 12, height : 18)
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding()
            // добавьте этот модификатор, чтобы обернуть HStack в кнопку, которая активирует переход для звука
            .onTapGesture {
                showSong = true
            }
            // добавьте этот модификатор, чтобы добавить лист, который отображает окно SongViewAsset
            .sheet(isPresented: $showSong) {
                SongViewAsset()
            }
        
            
            HStack {
                Image(systemName:"repeat")
                    .resizable()
                    .frame(width : 32, height : 32)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    Text("Повтор будильника")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("5 минут")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName:"chevron.right")
                    .resizable()
                    .frame(width : 12, height : 18)
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding()
            .onTapGesture {
                            showRepeat = true
                        }
                        // добавьте этот модификатор, чтобы добавить лист, который отображает окно RepeatAlarmViewAsset
            .sheet(isPresented: $showRepeat) {
                RepeatAlarmViewAsset()
            }
            
            HStack {
                Image(systemName:"waveform.circle")
                    .resizable()
                    .frame(width : 32, height : 32)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    Text("Вибрация")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Включена")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName:"chevron.right")
                    .resizable()
                    .frame(width : 12, height : 18)
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding()
            
            .onTapGesture {
                            showVibration = true
                        }
                        // добавьте этот модификатор, чтобы добавить лист, который отображает окно VibrationViewAsset
            .sheet(isPresented: $showVibration) {
                VibrationViewAsset()
            }
            
            Divider()
                .background(Color.gray)
            
        }
    }
}
        #Preview {
            SettingsViewAsset()
                .background(Color.black)
        }
