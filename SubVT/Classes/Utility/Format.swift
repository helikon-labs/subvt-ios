//
//  Format.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 8.07.2022.
//

import Foundation
import SubVTData

func formatBalance(
    balance: Balance,
    tokenDecimalCount: UInt8,
    formatDecimalCount: UInt8 = 4
) -> String {
    var balanceString = balance.value.description
    let addZeroCount = max(0, Int(tokenDecimalCount) + 1 - balanceString.count)
    if addZeroCount > 0 {
        for _ in 0..<addZeroCount {
            balanceString = "0" + balanceString
        }
    }
    var decimalsString = balanceString.suffix(Int(tokenDecimalCount))
    var integerString = String(balanceString.prefix(balanceString.count - decimalsString.count))
    integerString = Int(integerString)!.formattedWithSeparator
    if formatDecimalCount == 0 {
        return integerString
    }
    decimalsString = decimalsString.prefix(Int(formatDecimalCount))
    return "\(integerString).\(decimalsString)"
}

func formatDecimal(
    integer: UInt64,
    decimalCount: UInt8,
    formatDecimalCount: UInt8
) -> String {
    var string = String(integer)
    let addZeroCount = max(0, Int(decimalCount) + 1 - string.count)
    if addZeroCount > 0 {
        for _ in 0..<addZeroCount {
            string = "0" + string
        }
    }
    var decimalsString = string.suffix(Int(decimalCount))
    var integerString = String(string.prefix(string.count - decimalsString.count))
    integerString = Int(integerString)!.formattedWithSeparator
    if formatDecimalCount == 0 {
        return integerString
    }
    decimalsString = decimalsString.prefix(Int(formatDecimalCount))
    return "\(integerString).\(decimalsString)"
}

func truncateAddress(_ address: String) -> String {
    return address.prefix(UI.Text.addressPrefixCount)
        + "..."
        + address.suffix(UI.Text.addressPrefixCount)
}

func formatMonthYear(index: Int) -> String {
    let year = index / 12;
    let monthIndex = index - (year * 12)
    var text = " '" + String(year).suffix(2)
    switch monthIndex {
    case 0:
        text = localized("common.date.month.january.short") + text
    case 1:
        text = localized("common.date.month.february.short") + text
    case 2:
        text = localized("common.date.month.march.short") + text
    case 3:
        text = localized("common.date.month.april.short") + text
    case 4:
        text = localized("common.date.month.may.short") + text
    case 5:
        text = localized("common.date.month.june.short") + text
    case 6:
        text = localized("common.date.month.july.short") + text
    case 7:
        text = localized("common.date.month.august.short") + text
    case 8:
        text = localized("common.date.month.september.short") + text
    case 9:
        text = localized("common.date.month.october.short") + text
    case 10:
        text = localized("common.date.month.november.short") + text
    case 11:
        text = localized("common.date.month.december.short") + text
    default:
        fatalError("Unexpected month index \(monthIndex).")
    }
    return text
}
