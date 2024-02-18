import SwiftUI

struct ShortViewAsset: View {
    var body: some View {
        VStack {
            
            HStack{
                
                Image(systemName:"moon.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("00:11")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Начало сна")
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


                Image(systemName:"bed.double.circle.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack (alignment: .leading){
                    
                    Text("10 мин")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("заснул(а) после")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    
                }
                Spacer()
                
            }
            .padding()
            HStack {
                Spacer()
                Image(systemName:"alarm.fill")
                    .resizable()
                    .frame(width : 30, height : 30)
                    .foregroundColor(.blue)
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("09:02")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Конец сна")
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
                Spacer()
                Spacer()

            }
            .padding(.bottom, 20) // Добавление отступа сверху

        }
    }
}

struct ShortViewAsset_Previews : PreviewProvider{
    
    static var previews:some View{
        
        ShortViewAsset()
            .background(Color.black)
        
    }
}
