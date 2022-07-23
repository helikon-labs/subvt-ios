//
//  ValidatorListSortFilterView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.07.2022.
//

import SwiftUI

struct ValidatorListFilterSortView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Binding var isVisible: Bool
    @Binding var sortOption: ValidatorListViewModel.SortOption?
    @Binding var filterOptions: Set<ValidatorListViewModel.FilterOption>
    @State private var sortByIdButtonPressed = false
    @State private var sortByStakePressed = false
    @State private var sortByNominationPressed = false
    @State private var filterByIdPressed = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("PopupOverlayBg")
                .onTapGesture {
                    self.isVisible = false
                }
            VStack {
                Spacer()
                    .frame(
                        height: UI.Dimension.Common.titleMarginTop
                            + UI.Dimension.ValidatorList.titleSectionHeight
                            + ValidatorListView.filterSectionHeight
                            - UI.Dimension.Common.searchBarHeight
                    )
                HStack {
                    Spacer()
                    Button(
                        action: {
                            self.isVisible = false
                        },
                        label: {
                            ZStack {
                                UI.Image.Common.filterIcon(self.colorScheme)
                            }
                            .frame(
                                width: UI.Dimension.Common.searchBarHeight,
                                height: UI.Dimension.Common.searchBarHeight
                            )
                            .background(Color("DataPanelBg"))
                            .cornerRadius(UI.Dimension.Common.cornerRadius)
                        }
                    )
                    .buttonStyle(PushButtonStyle())
                }
                Spacer()
                    .frame(height: 12)
                HStack {
                    Spacer()
                    VStack(spacing: UI.Dimension.Common.padding) {
                        VStack(
                            alignment: .leading,
                            spacing: UI.Dimension.Common.padding
                        ) {
                            Text(localized("validator_list.sort_by"))
                                .font(UI.Font.ValidatorList.listSortSectionTitle)
                                .foregroundColor(Color("Text"))
                            HStack(alignment: .center, spacing: 12) {
                                Button(
                                    action: {
                                        self.sortOption = .identity
                                    },
                                    label: {
                                        SmallCheckboxButtonView(
                                            isChecked: self.sortOption == .identity,
                                            isPressed: self.sortByIdButtonPressed
                                        )
                                    }
                                )
                                .pressAction {
                                    self.sortByIdButtonPressed = true
                                } onRelease: {
                                    self.sortByIdButtonPressed = false
                                }
                                Text(localized("validator_list.sort_by.id_address"))
                                    .foregroundColor(Color("Text"))
                                    .font(UI.Font.ValidatorList.listSortField)
                            }
                            HStack(alignment: .center, spacing: 12) {
                                Button(
                                    action: {
                                        self.sortOption = .stakeDescending
                                    },
                                    label: {
                                        SmallCheckboxButtonView(
                                            isChecked: self.sortOption == .stakeDescending,
                                            isPressed: self.sortByStakePressed
                                        )
                                    }
                                )
                                .pressAction {
                                    self.sortByStakePressed = true
                                } onRelease: {
                                    self.sortByStakePressed = false
                                }
                                Text(localized("validator_list.sort_by.active_stake"))
                                    .foregroundColor(Color("Text"))
                                    .font(UI.Font.ValidatorList.listSortField)
                            }
                            HStack(alignment: .center, spacing: 12) {
                                Button(
                                    action: {
                                        self.sortOption = .nominationDescending
                                    },
                                    label: {
                                        SmallCheckboxButtonView(
                                            isChecked: self.sortOption == .nominationDescending,
                                            isPressed: self.sortByNominationPressed
                                        )
                                    }
                                )
                                .pressAction {
                                    self.sortByNominationPressed = true
                                } onRelease: {
                                    self.sortByNominationPressed = false
                                }
                                Text(localized("validator_list.sort_by.nomination_total"))
                                    .foregroundColor(Color("Text"))
                                    .font(UI.Font.ValidatorList.listSortField)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Color("Text")
                            .frame(height: 1)
                            .opacity(0.15)
                        VStack(
                            alignment: .leading,
                            spacing: UI.Dimension.Common.padding
                        ) {
                            Text(localized("validator_list.filter"))
                                .font(UI.Font.ValidatorList.listSortSectionTitle)
                                .foregroundColor(Color("Text"))
                            HStack(alignment: .center, spacing: 12) {
                                Button(
                                    action: {
                                        if self.filterOptions.contains(.hasIdentity) {
                                            self.filterOptions.remove(.hasIdentity)
                                        } else {
                                            self.filterOptions.insert(.hasIdentity)
                                        }
                                    },
                                    label: {
                                        SmallCheckboxButtonView(
                                            isChecked: self.filterOptions.contains(.hasIdentity),
                                            isPressed: self.filterByIdPressed
                                        )
                                    }
                                )
                                .pressAction {
                                    self.filterByIdPressed = true
                                } onRelease: {
                                    self.filterByIdPressed = false
                                }
                                Text(localized("validator_list.filter.by_identity"))
                                    .foregroundColor(Color("Text"))
                                    .font(UI.Font.ValidatorList.listSortField)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .frame(width: 216)
                    .padding(UI.Dimension.Common.padding)
                    .background(Color("ValidatorListSortFilterVewBg"))
                    .cornerRadius(UI.Dimension.Common.cornerRadius)
                    
                }
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: 0,
                trailing: UI.Dimension.Common.padding
            ))
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
    }
}

struct ValidatorListSortFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorListFilterSortView(
            isVisible: .constant(true),
            sortOption: .constant(nil),
            filterOptions: .constant([])
        ).preferredColorScheme(.light)
    }
}
