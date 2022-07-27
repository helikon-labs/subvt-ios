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
            static func backArrow(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("BackArrowDark")
                } else {
                    return SwiftUI.Image("BackArrowLight")
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
        
        enum NetworkSelection {
            static func networkIcon(
                network: Network
            ) -> SwiftUI.Image {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return SwiftUI.Image("\(network.chain.capitalized)IconPhone")
                } else {
                    return SwiftUI.Image("\(network.chain.capitalized)IconPad")
                }
            }
        }
        
        enum NetworkStatus {
            static func arrowDown(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("NetworkStatusArrowDownDark")
                } else {
                    return SwiftUI.Image("NetworkStatusArrowDownLight")
                }
            }
            
            static func arrowUp(_ colorScheme: ColorScheme) -> SwiftUI.Image {
                if colorScheme == .dark {
                    return SwiftUI.Image("NetworkStatusArrowUpDark")
                } else {
                    return SwiftUI.Image("NetworkStatusArrowUpLight")
                }
            }
            
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
    }
}
