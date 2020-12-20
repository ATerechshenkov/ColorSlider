//
//  ViewController.swift
//  ColorSlider
//
//  Created by Terechshenkov Andrey on 12/18/20.
//

import UIKit

extension UIColor {
    func getRGBAComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var (red, green, blue, alpha) = (CGFloat(1), CGFloat(1), CGFloat(1), CGFloat(1))
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        } else {
            return nil
        }
    }
}

protocol ColorViewControllerDelegate: AnyObject {
    func update(color: UIColor)
}

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: ColorViewControllerDelegate?
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    @IBOutlet var redLabel: UILabel!
    @IBOutlet var greenLabel: UILabel!
    @IBOutlet var blueLabel: UILabel!
    
    @IBOutlet var redTextField: UITextField!
    @IBOutlet var greenTextField: UITextField!
    @IBOutlet var blueTextField: UITextField!
    
    @IBOutlet var colorView: UIView!
    
    private var beforeTextFields = [Int: String?]()
    
    var (red, green, blue, alpha) = (CGFloat(1), CGFloat(1), CGFloat(1), CGFloat(1))
    var color: UIColor {
        get {
            UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        set {
            if let (red, green, blue, alpha) = newValue.getRGBAComponents() {
                (self.red, self.green, self.blue, self.alpha) = (red, green, blue, alpha)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorView.layer.cornerRadius = 10
        redrawView()
        
        // Add Done button on numberPad
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
        redTextField.delegate = self
        greenTextField.delegate = self
        blueTextField.delegate = self
        
        redTextField.inputAccessoryView = toolbar
        greenTextField.inputAccessoryView = toolbar
        blueTextField.inputAccessoryView = toolbar
        
        // Dissmiss keyboard on tap view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }

    @IBAction func onChangeSlider() {
        red = CGFloat(redSlider.value/255)
        green = CGFloat(greenSlider.value/255)
        blue = CGFloat(blueSlider.value/255)
        redrawView()
    }
    
    @IBAction func onDoneButton(_ sender: Any) {
        self.delegate?.update(color: color)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        beforeTextFields[textField.hashValue] = textField.text
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Return old value textFild for empty value
        if textField.text?.isEmpty ?? true {
            if let before = beforeTextFields[textField.hashValue] {
                textField.text = before
                return
            }
        }
        
        // Cast value
        var inputValue = Float(textField.text ?? "255") ?? 255
        inputValue = inputValue < 0 ? 0.0 : inputValue
        inputValue = inputValue > 255 ? 255.0 : inputValue
        
        let castValue = CGFloat(inputValue / 255)
        
        switch textField {
        case redTextField:
            print("red")
            red = castValue
        case greenTextField:
            print("green")
            green = castValue
        case blueTextField:
            print("blue")
            blue = castValue
        default:
            break
        }
        
        redrawView()
    }
    
    private func redrawView() {
        colorView.backgroundColor = color

        redSlider.value = Float(red * 255)
        greenSlider.value = Float(green * 255)
        blueSlider.value = Float(blue * 255)
        
        redSlider.minimumTrackTintColor = UIColor(red: red, green: 0, blue: 0, alpha: 1)
        greenSlider.minimumTrackTintColor = UIColor(red: 0, green: green, blue: 0, alpha: 1)
        blueSlider.minimumTrackTintColor = UIColor(red: 0, green: 0, blue: blue, alpha: 1)

        redLabel.text = String(format: "%.0f", redSlider.value)
        greenLabel.text = String(format: "%.0f", greenSlider.value)
        blueLabel.text = String(format: "%.0f", blueSlider.value)
        
        redTextField.text = redLabel.text
        greenTextField.text = greenLabel.text
        blueTextField.text = blueLabel.text
    }
}
