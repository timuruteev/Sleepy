import SwiftUI

struct Article: Identifiable {
    var id = UUID()
    var imageURL: URL
    var title: String
    var description: String
}


struct ArticleView: View {
    let articles = [
        Article(imageURL: URL(string: "https://4brain.ru/blog/wp-content/uploads/2021/03/polifaznyj-son-mozhno-li-sohranjat-effektivnost-tratja-na-son-vsego-2-chasa-v-den.png")!, title: "Влияние сна на здоровье", description: "Обсуждение о том, как качество и количество сна влияют на физическое и психическое здоровье."),
        Article(imageURL: URL(string: "https://img.freepik.com/premium-vector/healthy-sleep-background_1284-71517.jpg")!, title: "Сон и питание", description: "Исследование связи между рационом питания и качеством сна."),
        Article(imageURL: URL(string: "https://medobr.com/upload/iblock/543/hand_drawn_world_sleep_day_illustration_with_woman_resting_23_2148842993.jpg-_740_740_-_-Google-Chrome-_1_.jpeg")!, title: "Сонники и их значение", description: "История и интерпретация сновидений у сонников и не только."),
    ]
    @State private var selectedArticle: Article?
    
    
    var body: some View {
        List(articles) { article in
            VStack(alignment: .leading) {
                AsyncImage(url: article.imageURL) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Закругление углов
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                Text(article.title)
                    .font(.headline)
                Text(article.description)
                    .font(.subheadline)
            }
            .padding(.bottom, 20)
            .onTapGesture {
                selectedArticle = article
            }
        }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailViewAsset(article: article)
        }
        
        .navigationBarTitle("Статьи", displayMode: .automatic)
        .preferredColorScheme(.dark) // Модификатор для темной темы
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView()
    }
}
