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
    tokenDecimalCount: Int,
    integerOnly: Bool = false
) -> String {
    var balanceString = balance.value.description
    let addZeroCount = max(0, tokenDecimalCount + 1 - balanceString.count)
    if addZeroCount > 0 {
        for _ in 0..<addZeroCount {
            balanceString = "0" + balanceString
        }
    }
    var decimalsString = balanceString.suffix(tokenDecimalCount)
    var integerString = String(balanceString.prefix(balanceString.count - decimalsString.count))
    integerString = Int(integerString)!.formattedWithSeparator
    if integerOnly {
        return integerString
    }
    decimalsString = decimalsString.prefix(4)
    return "\(integerString).\(decimalsString)"
}
