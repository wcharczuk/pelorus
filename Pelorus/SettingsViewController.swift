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
    
    @IBOutlet var light_blue : UITableViewCell!
    @IBOutlet var light_red : UITableViewCell!
    @IBOutlet var dark_blue : UITableViewCell!
    @IBOutlet var dark_red : UITableViewCell!
    
    override func viewDidLoad() {
        compassStepsToggle.stepValue = 1.0
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.barTintColor = nil
        self.tabBarController?.tabBar.tintColor = nil
        
        compassStepsToggle.value = Double(UserPreferences.CompassSmoothing)
        compassStepsDisplay.text = String(UserPreferences.CompassSmoothing) + " Steps"
        if UserPreferences.UseMetric {
            units.selectedSegmentIndex = 1
        } else {
            units.selectedSegmentIndex = 0
        }
        
        selectTheme(UserPreferences.Theme)
    }
    
    @IBAction func compassSmoothingValueChanged(sender: AnyObject) {
        if compassStepsToggle.value > 0 {
            UserPreferences.CompassSmoothing = Int(compassStepsToggle.value)
            compassStepsDisplay.text = String(UserPreferences.CompassSmoothing) + " Steps"
        } else {
            compassStepsToggle.value = 1.0;
        }
    }
    
    @IBAction func unitsValueChanged(sender: AnyObject) {
        if units.selectedSegmentIndex == 1 {
            UserPreferences.UseMetric = true
        } else {
            UserPreferences.UseMetric = false
        }
    }

    func resetAllThemeRows() {
        light_blue.accessoryType = UITableViewCellAccessoryType.None
        light_red.accessoryType = UITableViewCellAccessoryType.None
        dark_blue.accessoryType = UITableViewCellAccessoryType.None
        dark_red.accessoryType = UITableViewCellAccessoryType.None
    }
    
    func selectTheme(theme_id : Int) {
        resetAllThemeRows()
        switch theme_id {
        case 0:
            light_blue.accessoryType = UITableViewCellAccessoryType.Checkmark
            break;
        case 1:
            light_red.accessoryType = UITableViewCellAccessoryType.Checkmark
            break;
        case 2:
            dark_blue.accessoryType = UITableViewCellAccessoryType.Checkmark
            break;
        case 3:
            dark_red.accessoryType = UITableViewCellAccessoryType.Checkmark
            break;
        default:
            light_blue.accessoryType = UITableViewCellAccessoryType.Checkmark
            break;
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectTheme(indexPath.row)
        UserPreferences.Theme = indexPath.row
    }
}