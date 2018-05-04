//
//  InterfaceControllerProtocol.swift
//  Heart IntervalTraxR WatchKit Extension
//
//  Created by DJ McKay on 12/3/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import Foundation

protocol InterfaceControllerProtocol {
    func authorize()
    func displayNotAllowed()
    func startStop()
    func animateHeart()
}
