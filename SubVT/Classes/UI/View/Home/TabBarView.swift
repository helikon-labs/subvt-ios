//
//  TabBarView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 25.06.2022.
//

import SwiftUI

struct TabBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}

struct TabBarButtonView: View {
    let tab: Tab
    @State var isActive = false
    
    init(tab: Tab) {
        self.tab = tab
    }
    
    var body: some View {
        Button(
            action: {},
            label: {
                VStack(alignment: .center, spacing: 0) {
                    self.tab.getImage(isActive: self.isActive)
                    Text(self.tab.text)
                        .font(UI.Font.TabBar.text)
                        .foregroundColor(
                            self.isActive
                            ? Color("TabBarItemTextActive")
                            : Color("TabBarItemTextInactive")
                        )
                }
                .frame(width: UI.Dimension.TabBar.itemWidth)
            }
        )
        .buttonStyle(TabBarButtonStyle())
    }
}

struct TabBarView: View {
    var body: some View {
        HStack(
            alignment: .center,
            spacing: UI.Dimension.TabBar.itemSpacing
        ) {
            TabBarButtonView(tab: .network)
            TabBarButtonView(tab: .myValidators)
            TabBarButtonView(tab: .notifications)
            TabBarButtonView(tab: .eraReports)
        }
        .frame(height: UI.Dimension.TabBar.height)
        .frame(maxWidth: .infinity)
        .background(Color("TabBarBg"))
        .cornerRadius(UI.Dimension.TabBar.cornerRadius)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
