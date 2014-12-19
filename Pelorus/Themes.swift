//
//  Themes.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/14/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    
    init(id: Int, name: String, primaryColor :UIColor, secondaryColor: UIColor, backgroundColor: UIColor, highlightColor: UIColor, primaryFontColor: UIColor, primaryFont : UIFont) {
        self.Id = id
        self.Name = name
        self.PrimaryColor = primaryColor
        self.SecondaryColor = secondaryColor
        self.BackgroundColor = backgroundColor
        self.HighlightColor = highlightColor
        self.PrimaryFont = primaryFont
        self.PrimaryFontColor = primaryFontColor
    }
    
    init(id: Int, name: String, primaryColor :UIColor, secondaryColor: UIColor, backgroundColor: UIColor, highlightColor: UIColor, primaryFontColor: UIColor, primaryFont : UIFont, menubarBackgroundColor: UIColor, menubarFontColor: UIColor) {
        self.Id = id
        self.Name = name
        self.PrimaryColor = primaryColor
        self.SecondaryColor = secondaryColor
        self.BackgroundColor = backgroundColor
        self.HighlightColor = highlightColor
        self.PrimaryFont = primaryFont
        self.PrimaryFontColor = primaryFontColor
        self.MenubarBackgroundColor = menubarBackgroundColor
        self.MenubarFontColor = menubarFontColor
    }
    
    var Id : Int
    var Name : String
    
    var PrimaryColor : UIColor
    var SecondaryColor: UIColor
    var BackgroundColor: UIColor
    var HighlightColor: UIColor
    
    var MenubarBackgroundColor: UIColor?
    var MenubarFontColor : UIColor?
    
    var PrimaryFontColor: UIColor
    var PrimaryFont : UIFont
}

struct Themes {
    
    static var Current : Theme {
        get {
            let theme_id = UserPreferences.Theme
            switch theme_id {
            case 0:
                return Themes.Light_Blue
            case 1:
                return Themes.Light_Red
            case 2:
                return Themes.Dark_Blue
            case 3:
                return Themes.Dark_Red
            default:
                return Themes.Light_Blue
            }
        }
    }
    
    static var Light_Blue : Theme {
        get {
            return Theme(
                id: 0,
                name: "Light Blue",
                primaryColor: UIColor(red: 0.38, green: 0.5921, blue: 0.73333, alpha: 1.0), //blue //r:97, g:151, b:187
                secondaryColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), //dark grey
                backgroundColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), //white
                highlightColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8), //light grey
                primaryFontColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                primaryFont: UIFont(name: "Avenir Next", size: CGFloat(18.0))!
            )
        }
    }
    
    static var Light_Red : Theme {
        get {
            return Theme(
                id: 1,
                name: "Light Red",
                primaryColor: UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 1.0), //darkish red
                secondaryColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), //dark grey
                backgroundColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), //white
                highlightColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8), //light grey
                primaryFontColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                primaryFont: UIFont(name: "Avenir Next", size: CGFloat(18.0))!
            )
        }
    }
    
    static var Dark_Blue : Theme {
        get {
            return Theme(
                id: 2,
                name: "Dark Blue",
                primaryColor: UIColor(red: 0.38, green: 0.5921, blue: 0.73333, alpha: 1.0), //blue
                secondaryColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), //dark grey
                backgroundColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), //black
                highlightColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8), //light grey
                primaryFontColor: UIColor(red: 0.38, green: 0.5921, blue: 0.73333, alpha: 1.0),
                primaryFont: UIFont(name: "Avenir Next", size: CGFloat(18.0))!,
                menubarBackgroundColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), //black
                menubarFontColor: UIColor(red: 0.38, green: 0.5921, blue: 0.73333, alpha: 1.0)
            )
        }
    }
    
    static var Dark_Red : Theme {
        get {
            return Theme(
                id: 3,
                name: "Dark Red",
                primaryColor: UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 1.0), //darkish red
                secondaryColor: UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 0.6), //dark grey
                backgroundColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), //white
                highlightColor: UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 0.7), //light grey
                primaryFontColor: UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 1.0),
                primaryFont: UIFont(name: "Avenir Next", size: CGFloat(18.0))!,
                menubarBackgroundColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), //black
                menubarFontColor: UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 1.0)
            )
        }
    }
}