import SwiftUI


struct MainWindowView: View {
    // переменная для хранения выбранной вкладки
    @State private var selection = 0
    
    var body: some View {
        // создаем TabView с пятью вкладками
        TabView(selection: $selection) {
            // каждая вкладка содержит NavigationView с заголовком и текстом
            NavigationView {
                MainView()
                            }
            // указываем иконку, подпись и тег для каждой вкладки
            .tabItem {
                Image(systemName: "moon.fill")
                Text("Сон")
            }
            // тег соответствует значению selection
            .tag(0)
            
            NavigationView {
                JournalView()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Журнал")
                
            }
            
            .tag(1)
            
            NavigationView {
                            
                            ArticleView()
                   
                        }
            
                        .tabItem {
                            Image(systemName: "book.pages.fill")
                            Text("Статьи")
                        }
            .tag(2)
            
            NavigationView {
                ProfileView()
        
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            .tag(3)
        }
    }
}


#Preview {
    MainWindowView()
        .background(.black)
}
