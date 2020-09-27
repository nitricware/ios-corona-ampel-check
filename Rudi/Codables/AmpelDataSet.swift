//
//  AmpelDataSet.swift
//  Rudi
//
//  Created by Kurt Höblinger on 25.09.20.
//

import Foundation

class AmpelDataSet: Codable {
    let Stand: String
    let Warnstufen: [AmpelRegion]
}
