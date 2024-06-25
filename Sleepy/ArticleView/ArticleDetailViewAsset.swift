import SwiftUI

struct ArticleDetailViewAsset: View {
    var article: Article
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(article.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer()
                Button("Готово") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading) {
                    AsyncImage(url: article.imageURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .aspectRatio(contentMode: .fit)
                    Text(article.title)
                        .font(.title2)
                        .padding(.top)
                        .fontWeight(.bold)
                    Text(article.detailText)
                        .font(.body)
                        .padding(.top)
                }
                .padding()
            }
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}

struct ArticleDetailViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        ArticleDetailViewAsset(article: Article(imageURL: URL(string: "https://4brain.ru/blog/wp-content/uploads/2021/03/polifaznyj-son-mozhno-li-sohranjat-effektivnost-tratja-na-son-vsego-2-chasa-v-den.png")!, title: "Влияние сна на здоровье", description: "Обсуждение о том, как качество и количество сна влияют на физическое и психическое здоровье.", detailText: "Сон играет важную роль в вашем здоровье и благополучии на протяжении всей вашей жизни. Получение достаточного количества качественного сна в нужное время может помочь защитить ваше ментальное здоровье, физическое здоровье, качество жизни и безопасность."))

    }
}

