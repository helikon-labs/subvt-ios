//
//  DataFetchState.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 11.07.2022.
//

import SubVTData

enum DataFetchState<T>: Hashable where T: Hashable {
    case idle
    case loading
    case error(error: APIError)
    case success(result: T)
}
