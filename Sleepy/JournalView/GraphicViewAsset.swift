import SwiftUI

struct GraphicViewAsset: View {
    let sleepData = [0.8, 0.9, 1.0, 1.0, 0.7, 0.9, 1.0, 0.5, 0.7,1.0] // Пример фиксированных значений
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("Время")
                    .foregroundColor(.white)
                    .frame(width: 70, alignment: .leading)// Увеличение ширины текста Время
                ForEach(sleepData.indices) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 20, height: CGFloat(self.sleepData[index] * 100)) // Регулировка высоты в зависимости от данных о сне
                        .clipShape(Capsule())
                        .overlay(Text("\(index+1)").foregroundColor(.white).position(x:10,y: CGFloat(self.sleepData[index] * 100 + 15))) // Перемещение меток под графиками
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 30) // Добавление отступа сверху
            .padding(.leading, 20)
            Divider()
                .background(Color.gray)
                .padding(.top, 40) // Добавление отступа сверху
        }
    }
}

struct GraphicViewAsset_Previews: PreviewProvider {
    static var previews: some View {
        GraphicViewAsset()
            .background(.black)
    }
}
