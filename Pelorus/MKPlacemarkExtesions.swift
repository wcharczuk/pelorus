//
//  CLPlacemarkExtesions.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/29/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

extension CLPlacemark {
    func toLabelString() -> String {
        if nil != self.thoroughfare && nil != self.subThoroughfare {
            return "\(self.subThoroughfare) \(self.thoroughfare), \(self.locality), \(self.administrativeArea)"
        } else if nil != self.thoroughfare {
            return "\(self.thoroughfare), \(self.locality), \(self.administrativeArea)"
        } else if nil != self.locality && nil != self.administrativeArea {
            return "\(self.locality), \(self.administrativeArea)"
        } else {
            return ""
        }
    }
}