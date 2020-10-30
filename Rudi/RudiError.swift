//
//  RudiError.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import Foundation

enum RudiError: Error {
    case dbFetchError
    case dbDeleteError
    case dbExportError
    case genericError
}
