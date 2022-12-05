//
//  UIConfig+Image.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI
import SubVTData

extension UI {
    enum Image {
        enum Common {
            static func arrowDown(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("ArrowDownDark")
                } else {
                    return SwiftUI.Image("ArrowDownLight")
                }
            }
            
            static func arrowUp(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("ArrowUpDark")
                } else {
                    return SwiftUI.Image("ArrowUpLight")
                }
            }
            static func arrowBack(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("ArrowBackDark")
                } else {
                    return SwiftUI.Image("ArrowBackLight")
                }
            }
            static func searchIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("SearchIconDark")
                } else {
                    return SwiftUI.Image("SearchIconLight")
                }
            }
            static func filterIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("FilterIconDark")
                } else {
                    return SwiftUI.Image("FilterIconLight")
                }
            }
            static func smallCheckboxUnchecked(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("SmallCheckboxUncheckedDark")
                } else {
                    return SwiftUI.Image("SmallCheckboxUncheckedLight")
                }
            }
            static func smallCheckboxPressed(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("SmallCheckboxPressedDark")
                } else {
                    return SwiftUI.Image("SmallCheckboxPressedLight")
                }
            }
            static func smallCheckboxChecked(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("SmallCheckboxCheckedDark")
                } else {
                    return SwiftUI.Image("SmallCheckboxCheckedLight")
                }
            }
            static func networkIcon(
                network: Network
            ) -> SwiftUI.Image {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return SwiftUI.Image("\(network.chain.capitalized)IconPhone")
                } else {
                    return SwiftUI.Image("\(network.chain.capitalized)IconPad")
                }
            }
            static func unionIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("UnionIconDark")
                } else {
                    return SwiftUI.Image("UnionIconLight")
                }
            }
            static func trashIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("TrashIconDark")
                } else {
                    return SwiftUI.Image("TrashIconLight")
                }
            }
        }
        
        enum Introduction {
            static func iconVolume(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return SwiftUI.Image("IconVolumeDarkPhone")
                    } else {
                        return SwiftUI.Image("IconVolumeDarkPad")
                    }
                } else {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return SwiftUI.Image("IconVolumeLightPhone")
                    } else {
                        return SwiftUI.Image("IconVolumeLightPad")
                    }
                }
            }
        }
        
        enum Onboarding {
            static func step(
                step: OnboardingStep,
                _ colorScheme: ColorScheme
            ) -> SwiftUI.Image {
                var name: String
                switch step {
                case .step1:
                    name = "Step1"
                case .step2:
                    name = "Step2"
                case .step3:
                    name = "Step3"
                case .step4:
                    name = "Step4"
                }
                if colorScheme == .dark {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return SwiftUI.Image("Onboarding\(name)DarkPhone")
                    } else {
                        return SwiftUI.Image("Onboarding\(name)DarkPad")
                    }
                } else {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return SwiftUI.Image("Onboarding\(name)LightPhone")
                    } else {
                        return SwiftUI.Image("Onboarding\(name)LightPad")
                    }
                }
            }
        }
        
        enum NetworkStatus {
            static func arrowRight(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return SwiftUI.Image("DataPanelRightArrowDarkPhone")
                    } else {
                        return SwiftUI.Image("DataPanelRightArrowDarkPad")
                    }
                } else {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return SwiftUI.Image("DataPanelRightArrowLightPhone")
                    } else {
                        return SwiftUI.Image("DataPanelRightArrowLightPad")
                    }
                }
            }
        }
        
        enum ValidatorDetails {
            static func addValidatorIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("AddValidatorIconDark")
                } else {
                    return SwiftUI.Image("AddValidatorIconLight")
                }
            }
            
            static func validatorReportsIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("ValidatorReportsIconDark")
                } else {
                    return SwiftUI.Image("ValidatorReportsIconLight")
                }
            }
        }
        
        enum Notifications {
            static func settingsIcon(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("SettingsIconDark")
                } else {
                    return SwiftUI.Image("SettingsIconLight")
                }
            }
        }
    }
}
