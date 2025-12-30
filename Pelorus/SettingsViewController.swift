//
//  SettingsViewController.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/25/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet var units : UISegmentedControl!
    @IBOutlet var compassStepsToggle : UIStepper!
    @IBOutlet var compassStepsDisplay : UILabel!
    
    @IBOutlet var shouldSmoothCompass : UISwitch!
    @IBOutlet var shouldSmoothLocation: UISwitch!
    
    @IBOutlet var light_blue : UITableViewCell!
    @IBOutlet var light_red : UITableViewCell!
    @IBOutlet var dark_blue : UITableViewCell!
    @IBOutlet var dark_red : UITableViewCell!
    @IBOutlet var hot_pink : UITableViewCell!
    @IBOutlet var system_theme : UITableViewCell!
    
    var _nav : PelorusNav!
    
    override func viewDidLoad() {
        compassStepsToggle.stepValue = 1.0
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _nav = appDelegate.NavManager
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.barTintColor = nil
        self.tabBarController?.tabBar.tintColor = nil
        
        compassStepsToggle.value = Double(UserPreferences.SensorSmoothing)
        compassStepsDisplay.text = String(UserPreferences.SensorSmoothing) + " Steps"
        
        if UserPreferences.UseMetric {
            units.selectedSegmentIndex = 1
        } else {
            units.selectedSegmentIndex = 0
        }
        
        shouldSmoothCompass.isOn = UserPreferences.ShouldSmoothCompass
        shouldSmoothLocation.isOn = UserPreferences.ShouldSmoothLocation
        
        selectTheme(UserPreferences.Theme)
    }
    
    @IBAction func compassSmoothingValueChanged(_ sender: AnyObject) {
        if compassStepsToggle.value > 0 {
            UserPreferences.SensorSmoothing = Int(compassStepsToggle.value)
            compassStepsDisplay.text = String(UserPreferences.SensorSmoothing) + " Steps"
        } else {
            compassStepsToggle.value = 1.0;
        }
        
        _nav.ChangeQueueLengths(UserPreferences.SensorSmoothing)
    }
    
    @IBAction func unitsValueChanged(_ sender: AnyObject) {
        if units.selectedSegmentIndex == 1 {
            UserPreferences.UseMetric = true
        } else {
            UserPreferences.UseMetric = false
        }
    }
    
    @IBAction func shouldSmoothCompassChanged(_ sender: AnyObject) {
        let value = shouldSmoothCompass.isOn
        UserPreferences.ShouldSmoothCompass = value
    }
    
    @IBAction func shouldSmoothLocationChanged(_ sender: AnyObject) {
        let value = shouldSmoothLocation.isOn
        UserPreferences.ShouldSmoothLocation = value
    }

    func resetAllThemeRows() {
        light_blue.accessoryType = UITableViewCell.AccessoryType.none
        light_red.accessoryType = UITableViewCell.AccessoryType.none
        dark_blue.accessoryType = UITableViewCell.AccessoryType.none
        dark_red.accessoryType = UITableViewCell.AccessoryType.none
        hot_pink.accessoryType = UITableViewCell.AccessoryType.none
        system_theme.accessoryType = UITableViewCell.AccessoryType.none
    }

    func selectTheme(_ theme_id : Int) {
        resetAllThemeRows()
        switch theme_id {
        case 0:
            light_blue.accessoryType = UITableViewCell.AccessoryType.checkmark
        case 1:
            light_red.accessoryType = UITableViewCell.AccessoryType.checkmark
        case 2:
            dark_blue.accessoryType = UITableViewCell.AccessoryType.checkmark
        case 3:
            dark_red.accessoryType = UITableViewCell.AccessoryType.checkmark
        case 4:
            hot_pink.accessoryType = UITableViewCell.AccessoryType.checkmark
        case 5:
            system_theme.accessoryType = UITableViewCell.AccessoryType.checkmark
        default:
            system_theme.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }

    // Map row index to theme ID (System is first in the list but has ID 5)
    func themeIdForRow(_ row: Int) -> Int {
        switch row {
        case 0:
            return 5  // System
        case 1:
            return 0  // Light Blue
        case 2:
            return 1  // Light Red
        case 3:
            return 2  // Dark Blue
        case 4:
            return 3  // Dark Red
        case 5:
            return 4  // Hot Pink
        default:
            return 5  // System
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Only handle theme section (section 1)
        if indexPath.section == 1 {
            let themeId = themeIdForRow(indexPath.row)
            selectTheme(themeId)
            UserPreferences.Theme = themeId
        }
    }
}
