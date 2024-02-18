//
//  ProfileView.swift
//  Sleepy
//
//  Created by Timur on 12.02.2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
            VStack() {
                Spacer()
                InformationViewAsset()
                SettingsViewAsset()
                Spacer()
                Spacer()
            }
            .background(.black)
        .ignoresSafeArea() // Вставил эту строку, чтобы убрать отступ у ZStack
        // Добавляем нижнюю панель поверх основного вида
        
    }
}


#Preview {
    ProfileView()
}
