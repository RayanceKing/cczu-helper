//
//  TutorialView.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject private var configs: ApplicationConfigs

    var body: some View {
        VStack {
            Text("欢迎使用常大助手！")
            Button("开始") {
                configs.firstUse = false
            }
        }
    }
}
