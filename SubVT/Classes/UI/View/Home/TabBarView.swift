//
//  TabBarView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 25.06.2022.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                
            }
            Text("asd")
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
