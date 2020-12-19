//
//  ColorViewController.swift
//  ColorSlider
//
//  Created by Terechshenkov Andrey on 19.12.2020.
//

import UIKit

class ColorViewController: UIViewController, ColorViewControllerDelegate {

    @IBOutlet var colorView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "settingsSegue" else {
            return
        }
        
        if let destination = segue.destination as? SettingsViewController {
            destination.delegate = self
            destination.color = colorView.backgroundColor ?? .white
        }
    }

    func update(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    @IBAction func exitAction(_ segie: UIStoryboardSegue) {}
}
