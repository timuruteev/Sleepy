import SwiftUI

struct MusicViewAsset: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Записанные звуки")
                .font(.title)
                .padding()
                .foregroundColor(.white) // Add this modifier to make the title white
                .fontWeight(.bold) // Add this modifier to make the title bold

            SoundView(timeRange: " ")
            SoundView(timeRange: "23:00-00:00")
            SoundView(timeRange: "00:00-01:00")
        }
    }
}

struct SoundView : View {
    let timeRange : String
    
    var body : some View {
        VStack(alignment: .leading){ // Add this modifier to align the elements to the left
            Text(timeRange)
                .font(.headline)
                .padding(.top, 10) // Add this modifier to increase the top padding for the time range
                .foregroundColor(.gray) // Add this modifier to make the time range gray
            
            HStack{
                Image(systemName:"play.fill") // You can replace this with your custom play button image
                    .resizable()
                    .frame(width : 20, height : 20)
                    .padding(.trailing, 5) // Add this modifier to increase the padding between the play button and the time range
                    .foregroundColor(.blue) // Add this modifier to make the play button blue
                
                Canvas { context, size in
                    let barWidth = size.width / 70 // You can adjust this value to change the number of bars
                    let barSpacing = barWidth / 2 // You can adjust this value to change the spacing between bars
                    let barColor = Color.gray // You can change this to any color you want
                    let barHeightFactor = 0.9 // You can adjust this value to change the maximum height of the bars
                    
                    // This is a sample array of random values to represent the sound wave amplitude
                    // You can replace this with your own data from the audio buffer or file
                    let soundData = [0.5, 0.8, 0.5, 0.7, 0.9, 1, 0.6, 0.5, 0.8, 0.5, 0.7, 0.9, 1, 0.6, 0.5, 0.8, 0.5, 0.7, 0.9, 1, 0.6, 0.8, 1, 0.5, 1, 0.6, 0.5, 0.8,0.6, 0.8, 1, 0.5, 1, 0.6, 0.5, 0.8,0.6, 0.8, 1, 0.5, 1, 0.6, 0.5, 0.8,0.5, 0.8,0.5, 0.8,0.5]
                    
                    for i in 0..<soundData.count {
                        // Calculate the position and height of each bar
                        let x = CGFloat(i) * (barWidth + barSpacing)
                        let y = size.height * (1 - barHeightFactor * CGFloat(soundData[i])) / 2
                        let height = size.height * barHeightFactor * CGFloat(soundData[i])
                        
                        // Draw each bar as a rounded rectangle
                        let bar = Path { path in
                            path.addRoundedRect(in: CGRect(x: x, y: y, width: barWidth, height: height), cornerSize: CGSize(width: barWidth / 2, height: barWidth / 2))
                        }
                        context.stroke(bar, with: .color(barColor))
                        context.fill(bar, with: .color(barColor))
                    }
                }
                .frame(height : 30) // You can adjust this value to change the height of the sound wave view
                .padding(.leading, 5) // Add this modifier to decrease the padding between the sound wave and the play button
            }
            
        }.padding()
    }
}

struct MusicViewAsset_Previews : PreviewProvider{
    static var previews:some View{
        MusicViewAsset()
            .background()
    }
}
