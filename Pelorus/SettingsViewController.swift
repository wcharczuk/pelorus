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
        light_blue.accessoryType = UITableViewCellAccessoryType.none
        light_red.accessoryType = UITableViewCellAccessoryType.none
        dark_blue.accessoryType = UITableViewCellAccessoryType.none
        dark_red.accessoryType = UITableViewCellAccessoryType.none
        hot_pink.accessoryType = UITableViewCellAccessoryType.none
    }
    
    func selectTheme(_ theme_id : Int) {
        resetAllThemeRows()
        switch theme_id {
        case 0:
            light_blue.accessoryType = UITableViewCellAccessoryType.checkmark
            break;
        case 1:
            light_red.accessoryType = UITableViewCellAccessoryType.checkmark
            break;
        case 2:
            dark_blue.accessoryType = UITableViewCellAccessoryType.checkmark
            break;
        case 3:
            dark_red.accessoryType = UITableViewCellAccessoryType.checkmark
            break;
        case 4:
            hot_pink.accessoryType = UITableViewCellAccessoryType.checkmark
            break;
        default:
            light_blue.accessoryType = UITableViewCellAccessoryType.checkmark
            break;
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTheme((indexPath as NSIndexPath).row)
        UserPreferences.Theme = (indexPath as NSIndexPath).row
    }
}
