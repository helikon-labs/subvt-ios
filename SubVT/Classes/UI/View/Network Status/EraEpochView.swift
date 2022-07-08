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
    
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    
    init(eraOrEpoch: Either<Era, Epoch>) {
        self.eraOrEpoch = eraOrEpoch
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
    
    private var title: LocalizedStringKey {
        get {
            switch eraOrEpoch {
            case .left(_):
                return LocalizedStringKey("common.era")
            case .right(_):
                return LocalizedStringKey("common.epoch")
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
            Date().timeIntervalSince1970 - self.startSeconds
        }
    }
    
    private var remainingHoursMinutes: (Int, Int) {
        get {
            let seconds = Int(self.endSeconds - Date().timeIntervalSince1970)
            let hours = seconds / (60 * 60)
            let minutes = (seconds - (hours * 60 * 60)) / 60
            return (hours, minutes)
        }
    }
    
    private var elapsedPercentage: Int {
        get {
            let elapsed = Date().timeIntervalSince1970 - self.startSeconds
            let total = self.endSeconds - self.startSeconds
            if total == 0 {
                return 0
            }
            return min(Int(elapsed * 100 / total), 100)
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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.title)
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(height: 10)
            Text(self.timespanFormatted)
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(height: 16)
            HStack (alignment: .top) {
                Text("\(self.elapsedPercentage)%")
                    .font(UI.Font.NetworkStatus.dataMedium)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(width: 16)
                VStack (alignment: .leading) {
                    Spacer()
                        .frame(height: 16)
                    ProgressView(
                        value: self.elapsedSeconds,
                        total: self.endSeconds - self.startSeconds
                    )
                    .frame(height: 4)
                    .background(Color("StatusActive"))
                    Spacer()
                        .frame(height: 2)
                    Text("\(self.remainingHoursMinutes.0) hr \(self.remainingHoursMinutes.1) mins left")
                        .font(UI.Font.NetworkStatus.dataSmall)
                        .foregroundColor(Color("RemainingTime"))
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

struct EraEpochView_Previews: PreviewProvider {
    static var previews: some View {
        EraEpochView(eraOrEpoch: .left(PreviewData.era))
    }
}
