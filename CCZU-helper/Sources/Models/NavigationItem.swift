//
//  NavigationItem.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI

struct NavigationItem {
    let icon: String
    let label: String
    let view: AnyView

    init(icon: String, label: String, view: some View) {
        self.icon = icon
        self.label = label
        self.view = AnyView(view)
    }
}
