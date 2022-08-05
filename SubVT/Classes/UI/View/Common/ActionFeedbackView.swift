//
//  ActionFeedbackView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 5.08.2022.
//

import SwiftUI

struct ActionFeedbackView: View {
    enum State {
        case error
        case success
        
        var icon: Image {
            switch self {
            case .error:
                return Image("ErrorIcon")
            case .success:
                return Image("SuccessIcon")
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .error:
                return Color("StatusError")
            case .success:
                return Color("StatusActive")
            }
        }
    }
    
    let state: State
    let text: String
    let visibleYOffset: CGFloat
    @Binding var isVisible: Bool
    
    var body: some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                self.isVisible = false
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                self.state.icon
                    .offset(y: 2)
                Text(self.text)
                    .font(UI.Font.ActionFeedbackView.text)
                    .foregroundColor(Color("Text"))
            }
            .padding(EdgeInsets(
                top: 12,
                leading: 26,
                bottom: 12,
                trailing: 26
            ))
            .background(Color("Bg"))
            .cornerRadius(UI.Dimension.Common.cornerRadius)
            .shadow(
                color: self.state.shadowColor.opacity(0.25),
                radius: 18 ,
                x: 0,
                y: 16
            )
        }
        .buttonStyle(PushButtonStyle())
        .frame(maxHeight: .infinity, alignment: .bottom)
        .opacity(self.isVisible ? 1.0 : 0.0)
        .offset(
            y: self.isVisible
                ? visibleYOffset
                : UI.Dimension.ActionFeedback.invisibleYOffset
        )
        .animation(
            .spring(),
            value: self.isVisible
        )
    }
}

struct ActionFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        ActionFeedbackView(
            state: .success,
            text: localized("common.done"),
            visibleYOffset: -60,
            isVisible: .constant(true)
        )
    }
}
