import SwiftUI

struct InformationViewAsset: View {
    var body: some View {
        VStack {
            // Заменил текст Профиль на динамический заголовок с датой и кнопкой календаря
            HStack(alignment: .center) {
                Text("Профиль")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                // Обработка нажатия кнопки
            }
            
            .padding()
            
            Divider()
                .background(Color.gray)
            
            HStack{
                Image(systemName:"moon.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("46")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("кол-во ночей")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    
                    
                }
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                
                Image(systemName:"circle.circle.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack (alignment: .leading){
                    
                    Text("88%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("средн. качество")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    
                }
                Spacer()
            }
            .padding()
            HStack {
                Spacer()
                Image(systemName:"clock.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("7ч 10мин")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("средн. время")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()

            }
            .padding(.bottom, 20)

            Divider()
                .background(Color.gray)

            .padding(.bottom, 30)
        }
    }
}
struct InformationViewAsset_Previews : PreviewProvider{
    
    static var previews:some View{
        
        InformationViewAsset()
        .background(Color.black)
        
    }
}
