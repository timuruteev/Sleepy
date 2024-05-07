import SwiftUI

struct MainWindowView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                MainView()
                            }
            .tabItem {
                Image(systemName: "moon.fill")
                Text("Сон")
            }
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
