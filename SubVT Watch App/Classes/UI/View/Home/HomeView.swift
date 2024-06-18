//
//  HomeView.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 17.06.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: self.$router.path) {
            VStack(alignment: .leading, spacing: 3) {
                UI.Image.Home.iconWithLogo
                Spacer().frame(height: 4)
                NavigationLink(value: Screen.networkStatus) {
                    HStack(alignment: .center, spacing: 8) {
                        SwiftUI.Image("NetworkIcon").scaleEffect(0.8)
                        Text(localized("tab.network_status"))
                            .font(UI.Font.Home.menuItem)
                            .foregroundColor(Color("HomeMenuItem"))
                            .offset(y: 1)
                        Spacer()
                    }
                    .frame(height: 40)
                }
                .buttonStyle(PushButtonStyle())
                NavigationLink(value: Screen.myValidators) {
                    HStack(alignment: .center, spacing: 8) {
                        SwiftUI.Image("MyValidatorsIcon").scaleEffect(0.8)
                        Text(localized("tab.my_validators"))
                            .font(UI.Font.Home.menuItem)
                            .foregroundColor(Color("HomeMenuItem"))
                            .offset(y: 1)
                        Spacer()
                    }
                    .frame(height: 40)
                }
                .buttonStyle(PushButtonStyle())
                NavigationLink(value: Screen.income) {
                    HStack(alignment: .center, spacing: 8) {
                        ZStack(alignment: .center) {
                            Circle()
                                .stroke(Color("HomeMenuItem"))
                                .frame(width: 20, height: 20)
                            Text("$")
                                .font(UI.Font.Home.menuIcon)
                                .foregroundColor(Color("StatusActive"))
                                .offset(y: 0)
                        }
                        .frame(width: 27, height: 27)
                        Text(localized("tab.income"))
                            .font(UI.Font.Home.menuItem)
                            .foregroundColor(Color("HomeMenuItem"))
                            .offset(y: 1)
                        Spacer()
                    }
                    .frame(height: 40)
                }
                .buttonStyle(PushButtonStyle())
            }
            .frame(
                alignment: .topLeading
            )
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: 0,
                trailing: UI.Dimension.Common.padding
            ))
            .navigationDestination(for: Screen.self) { screen in
                screen.build()
            }
        }
        .onAppear {
            viewModel.fetchNetworks()
        }
    }
}