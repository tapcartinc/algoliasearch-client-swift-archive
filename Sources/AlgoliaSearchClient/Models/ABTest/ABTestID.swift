//
//  ABTestID.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

public struct ABTestID: StringWrapper, URLEncodable {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}