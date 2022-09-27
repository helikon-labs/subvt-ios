//
//  ValidatorSearchSummaryView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 27.09.2022.
//

import SubVTData
import SwiftUI

struct ValidatorSearchSummaryView: View {
    private var validatorSearchSummary: ValidatorSearchSummary
    
    init(
        validatorSearchSummary: ValidatorSearchSummary
    ) {
        self.validatorSearchSummary = validatorSearchSummary
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                HStack(alignment: .center) {
                    if self.validatorSearchSummary.parentDisplay != nil {
                        if self.validatorSearchSummary.confirmed {
                            Image("ParentIdentityConfirmedIconSmall")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        } else {
                            Image("ParentIdentityNotConfirmedIconSmall")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        }
                    } else if self.validatorSearchSummary.display != nil {
                        if self.validatorSearchSummary.confirmed {
                            Image("IdentityConfirmedIconSmall")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        } else {
                            Image("IdentityNotConfirmedIconSmall")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        }
                    }
                    Text(validatorSearchSummary.identityDisplay)
                        .font(UI.Font.ValidatorSummary.display)
                        .foregroundColor(Color("Text"))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                Spacer()
                    .frame(height: UI.Dimension.ValidatorSummary.balanceTopMargin)
                HStack {
                    Text("20384.0000 / 5042.4252 KSM")
                        .font(UI.Font.ValidatorSummary.balance)
                        .foregroundColor(Color("Text"))
                    Spacer()
                }
            }
            Spacer()
            ZStack {
                Button {
                    // action
                } label: {
                    Image("AddValidatorButton")
                }
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(
            top: UI.Dimension.ValidatorSummary.padding,
            leading: UI.Dimension.ValidatorSummary.padding,
            bottom: UI.Dimension.ValidatorSummary.padding,
            trailing: UI.Dimension.ValidatorSummary.padding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(16)
    }
}

struct ValidatorSearchSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorSearchSummaryView(
            validatorSearchSummary: PreviewData.validatorSearchSummary
        )
    }
}
