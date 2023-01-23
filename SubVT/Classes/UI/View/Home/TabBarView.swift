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
    let isActive: Bool
    let notificationCount: Int
    let onSelect: () -> ()
    
    init(
        tab: Tab,
        isActive: Bool,
        notificationCount: Int,
        onSelect: @escaping () -> ()
    ) {
        self.tab = tab
        self.isActive = isActive
        self.notificationCount = notificationCount
        self.onSelect = onSelect
    }
    
    var body: some View {
        Button(
            action: {
                self.onSelect()
            },
            label: {
                ZStack(alignment: .center) {
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
                    if notificationCount > 0 {
                        VStack {
                            Spacer()
                                .frame(height: 8)
                            HStack {
                                Spacer()
                                Text("\(notificationCount)")
                                    .font(UI.Font.TabBar.notificationCount)
                                    .padding(EdgeInsets(
                                        top: 0,
                                        leading: 6,
                                        bottom: 0,
                                        trailing: 6
                                    ))
                                    .frame(height: 19)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(10)
                                Spacer()
                                    .frame(width: 4)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(width: UI.Dimension.TabBar.itemWidth)
            }
        )
        .buttonStyle(TabBarButtonStyle())
    }
}

struct TabBarView: View {
    @EnvironmentObject private var appState: AppState
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.receivedAt, order: .reverse)
    ], predicate: NSPredicate(
        format: "isRead == %@",
        NSNumber(value: false)
    )) var unreadNotifications: FetchedResults<Notification>
    
    var body: some View {
        HStack(
            alignment: .center,
            spacing: UI.Dimension.TabBar.itemSpacing
        ) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButtonView(
                    tab: tab,
                    isActive: tab == self.appState.currentTab,
                    notificationCount: (tab == .notifications) ? self.unreadNotifications.count : 0
                ) {
                    self.appState.currentTab = tab
                }
            }
        }
        .frame(height: UI.Dimension.TabBar.height)
        .frame(maxWidth: .infinity)
        .background(Color("TabBarBg"))
        .cornerRadius(UI.Dimension.TabBar.cornerRadius)
    }
}

struct TabBarView_Previews: PreviewProvider {
    @State static private var currentTab: Tab = .network
    
    static var previews: some View {
        TabBarView()
    }
}
