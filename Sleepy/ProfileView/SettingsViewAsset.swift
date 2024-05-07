import SwiftUI
import SQLite

struct SettingsViewAsset: SwiftUI.View {
    @State private var showWakeUpPeriod = false
    @State private var showSong = false
    @State private var showRepeat = false
    @State private var showVibration = false
    @State private var selectedSleepPeriod: Int = 15
    @State private var selectedAlarmSound: String = "Теплый ветер"
    
    init() {
        _selectedSleepPeriod = State(initialValue: SettingsViewAsset.fetchCurrentSleepPeriod())
        _selectedAlarmSound = State(initialValue: SettingsViewAsset.fetchCurrentAlarmSound())
    }
    
    static func fetchCurrentSleepPeriod() -> Int {
        
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
            
            let db = try! Connection(finalDatabaseURL.path)
            
            let sleepPeriodTable = Table("SleepPeriod")
            let duration = Expression<Int>("Duration")
            
            if let currentPeriod = try! db.pluck(sleepPeriodTable.select(duration)) {
                return currentPeriod[duration]
            } else {
                return 15
            }
        }
    
    static func fetchCurrentAlarmSound() -> String {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let finalDatabaseURL = documentsDirectory.appendingPathComponent("Sleepy1.db")
            
            let db = try! Connection(finalDatabaseURL.path)
            
            let alarmSoundTable = Table("AlarmSound")
            let soundName = Expression<String>("SoundName")
            
            if let currentSound = try! db.pluck(alarmSoundTable.select(soundName)) {
                return currentSound[soundName]
            } else {
                return "Теплый ветер"
            }
        }
    
    var body: some SwiftUI.View {
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
                                    
                                    Text("\(selectedSleepPeriod) минут")
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image(systemName:"chevron.right")
                        .resizable()
                        .frame(width : 12, height : 18)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                .padding()
                .onAppear {
                    self.selectedSleepPeriod = SettingsViewAsset.fetchCurrentSleepPeriod()
                }
                .onTapGesture {
                    showWakeUpPeriod = true
                }
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
                    
                    Text(selectedAlarmSound)
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
            .onAppear {
                self.selectedAlarmSound = SettingsViewAsset.fetchCurrentAlarmSound()
                
            }
            .onTapGesture {
                showSong = true
            }
            .sheet(isPresented: $showSong) {
                SongViewAsset()
            }

            Divider()
                .background(Color.gray)
        }
    }
}

struct SettingsViewAsset_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        SettingsViewAsset()
            .background(Color.black)
    }
}
