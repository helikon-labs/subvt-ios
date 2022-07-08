//
//  Either.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 8.07.2022.
//

import Foundation

enum Either<A, B>{
  case left(A)
  case right(B)
}
