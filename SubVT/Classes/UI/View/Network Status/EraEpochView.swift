//
//  EraEpochView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 8.07.2022.
//

import SubVTData
import SwiftUI

struct EraEpochView: View {
    let eraOrEpoch: Either<Era, Epoch>
    let isAnimated: Bool
    
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    
    init(eraOrEpoch: Either<Era, Epoch>, isAnimated: Bool) {
        self.eraOrEpoch = eraOrEpoch
        self.isAnimated = isAnimated
        dateFormatter.dateFormat = "dd MMM ''YY"
        timeFormatter.dateFormat = "HH:mm"
    }
    
    private var index: UInt {
        get {
            switch eraOrEpoch {
            case .left(let era):
                return UInt(era.index)
            case .right(let epoch):
                return UInt(epoch.index)
            }
        }
    }
    
    private var title: String {
        get {
            switch eraOrEpoch {
            case .left(let era):
                return String(
                    format: localized("network_status.era_with_index"),
                    era.index
                )
            case .right(let epoch):
                return String(
                    format: localized("network_status.epoch_with_index"),
                    epoch.index
                )
            }
        }
    }
    
    private var startSeconds: Double {
        get {
            switch eraOrEpoch {
            case .left(let era):
                return Double(era.startTimestamp) / 1000
            case .right(let epoch):
                return Double(epoch.startTimestamp) / 1000
            }
        }
    }
    
    private var endSeconds: Double {
        get {
            switch eraOrEpoch {
            case .left(let era):
                return Double(era.endTimestamp) / 1000
            case .right(let epoch):
                return Double(epoch.endTimestamp) / 1000
            }
        }
    }
    
    private var startDate: Date {
        get {
            return Date(
                timeIntervalSince1970: TimeInterval(self.startSeconds)
            )
        }
    }
    
    private var endDate: Date {
        get {
            return Date(
                timeIntervalSince1970: TimeInterval(self.endSeconds)
            )
        }
    }
    
    private var elapsedSeconds: Double {
        get {
            if self.startSeconds == 0 {
                return 0
            } else {
                return Date().timeIntervalSince1970 - self.startSeconds
            }
        }
    }
    
    private var elapsedPercentage: Int {
        get {
            let elapsed = Date().timeIntervalSince1970 - self.startSeconds
            let total = self.endSeconds - self.startSeconds
            if total == 0 {
                return 0
            }
            return Int(elapsed * 100 / total)
        }
    }
    
    private var timespanFormatted: String {
        get {
            let startDate = self.startDate
            let endDate = self.endDate
            let startDateFormatted = dateFormatter.string(from: startDate)
            let startTimeFormatted = timeFormatter.string(from: startDate)
            let endTimeFormatted = timeFormatter.string(from: endDate)
            return "\(startDateFormatted) / \(startTimeFormatted) - \(endTimeFormatted)"
        }
    }
    
    private var timeLeftFormatted: (String, Bool) {
        get {
            let isOvertime = Date().timeIntervalSince1970 > self.endSeconds
            let seconds = abs(Int(self.endSeconds - Date().timeIntervalSince1970))
            let hours = seconds / (60 * 60)
            let minutes = (seconds - (hours * 60 * 60)) / 60
            if hours > 0 {
                if isOvertime {
                    return (String(
                        format: localized("network_status.hours_minutes_over"),
                        hours,
                        minutes
                    ), isOvertime)
                } else {
                    return (String(
                        format: localized("network_status.hours_minutes_left"),
                        hours,
                        minutes
                    ), isOvertime)
                }
            } else {
                if isOvertime {
                    return (String(
                        format: localized("network_status.minutes_over"),
                        minutes
                    ), isOvertime)
                } else {
                    return (String(
                        format: localized("network_status.minutes_left"),
                        minutes
                    ), isOvertime)
                }
            }
        }
    }
    
    var body: some View {
        let spanSeconds = self.endSeconds - self.startSeconds
        let progressValue = min(self.elapsedSeconds, spanSeconds)
        let progressTotal = max(spanSeconds, 0)
        if UIDevice.current.userInterfaceIdiom == .phone {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: 10)
                Text(self.timespanFormatted)
                    .font(UI.Font.NetworkStatus.eraEpochTimestamp)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: 16)
                HStack (alignment: .top) {
                    Text(
                        String(
                            format: localized("common.int_percentage"),
                            self.elapsedPercentage
                        )
                    )
                    .modifier(Counter(
                        format: localized("common.int_percentage"),
                        value: CGFloat(self.elapsedPercentage)
                    ))
                    .animation(
                        self.isAnimated ? .easeInOut(duration: UI.Duration.counterAnimation) : nil,
                        value: self.elapsedPercentage
                    )
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(
                        self.elapsedPercentage > 100
                            ? Color("StatusError")
                            : Color("Text")
                    )
                    Spacer()
                        .frame(width: 16)
                    VStack (alignment: .leading) {
                        let timeLeft = self.timeLeftFormatted
                        Spacer()
                            .frame(height: 14)
                        ZStack {
                            ProgressView(
                                value: progressValue,
                                total: progressTotal
                            )
                            .frame(height: 4)
                            .progressViewStyle(LinearGradientProgressViewStyle())
                            // shadow
                            ProgressView(
                                value: progressValue,
                                total: progressTotal
                            )
                            .frame(height: 4)
                            .progressViewStyle(LinearGradientProgressViewStyle())
                            .blur(radius: 3)
                            .opacity(0.2)
                            .offset(x: 0, y: 3)
                        }
                        Spacer()
                            .frame(height: 4)
                        if timeLeft.1 { // overtime
                            Text(self.timeLeftFormatted.0)
                                .font(UI.Font.NetworkStatus.dataSmall)
                                .foregroundColor(Color("StatusError"))
                        } else {
                            Text(self.timeLeftFormatted.0)
                                .font(UI.Font.NetworkStatus.dataSmall)
                                .foregroundColor(Color("RemainingTime"))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: UI.Dimension.Common.dataPanelPadding,
                trailing: UI.Dimension.Common.dataPanelPadding))
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
        } else {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: 10)
                    Text(self.timespanFormatted)
                        .font(UI.Font.NetworkStatus.eraEpochTimestamp)
                        .foregroundColor(Color("Text"))
                }
                Spacer()
                HStack (alignment: .top) {
                    Text(
                        String(
                            format: localized("common.int_percentage"),
                            self.elapsedPercentage
                        )
                    )
                    .modifier(Counter(
                        format: localized("common.int_percentage"),
                        value: CGFloat(self.elapsedPercentage)
                    ))
                    .animation(
                        self.isAnimated ? .easeInOut(duration: UI.Duration.counterAnimation) : nil,
                        value: self.elapsedPercentage
                    )
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(
                        self.elapsedPercentage > 100
                            ? Color("StatusError")
                            : Color("Text")
                    )
                    Spacer()
                        .frame(width: 16)
                    VStack (alignment: .leading) {
                        let timeLeft = self.timeLeftFormatted
                        Spacer()
                            .frame(height: 14)
                        ZStack {
                            ProgressView(
                                value: progressValue,
                                total: progressTotal
                            )
                            .frame(width: 80, height: 4)
                            .progressViewStyle(LinearGradientProgressViewStyle())
                            // shadow
                            ProgressView(
                                value: progressValue,
                                total: progressTotal
                            )
                            .frame(width: 80, height: 4)
                            .progressViewStyle(LinearGradientProgressViewStyle())
                            .blur(radius: 3)
                            .opacity(0.2)
                            .offset(x: 0, y: 3)
                        }
                        Spacer()
                            .frame(height: 4)
                        if timeLeft.1 { // overtime
                            Text(self.timeLeftFormatted.0)
                                .font(UI.Font.NetworkStatus.dataSmall)
                                .foregroundColor(Color("StatusError"))
                        } else {
                            Text(self.timeLeftFormatted.0)
                                .font(UI.Font.NetworkStatus.dataSmall)
                                .foregroundColor(Color("RemainingTime"))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: UI.Dimension.Common.dataPanelPadding,
                trailing: UI.Dimension.Common.dataPanelPadding))
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
        }
    }
}

struct EraEpochView_Previews: PreviewProvider {
    static var previews: some View {
        EraEpochView(eraOrEpoch: .left(PreviewData.era), isAnimated: true)
    }
}
