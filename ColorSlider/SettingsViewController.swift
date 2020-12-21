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

enum RGB {
    case red
    case green
    case blue
}

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: ColorViewControllerDelegate?
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
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
        
        // View Appearance
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
        
        redrawRGBSlider(slider: redSlider, color: RGB.red)
        redrawRGBSlider(slider: greenSlider, color: RGB.green)
        redrawRGBSlider(slider: blueSlider, color: RGB.blue)

        redTextField.text = String(format: "%.0f", redSlider.value)
        greenTextField.text = String(format: "%.0f", greenSlider.value)
        blueTextField.text = String(format: "%.0f", blueSlider.value)
    }
    
    func redrawRGBSlider(slider:UISlider, color rgb: RGB) {
        let tgl = CAGradientLayer()
        let frame = CGRect.init(x:0, y:0, width:slider.frame.size.width, height:15)
        tgl.frame = frame
        
        var reds = [red, red, red]
        var greens = [green, green, green]
        var blues = [blue, blue, blue]
        let gradients = [CGFloat(0), CGFloat(0.5), CGFloat(1)]
        
        switch rgb {
        case .red:
            reds = gradients
        case .green:
            greens = gradients
        case .blue:
            blues = gradients
        }
           
        tgl.colors = [
            UIColor(red: reds[0], green: greens[0], blue: blues[0], alpha: 1).cgColor,
            UIColor(red: reds[1], green: greens[1], blue: blues[1], alpha: 1).cgColor,
            UIColor(red: reds[2], green: greens[2], blue: blues[2], alpha: 1).cgColor
        ]
        tgl.startPoint = CGPoint.init(x:0.0, y:0.5)
        tgl.endPoint = CGPoint.init(x:1.0, y:0.5)

        UIGraphicsBeginImageContextWithOptions(tgl.frame.size, tgl.isOpaque, 0.0);
        tgl.render(in: UIGraphicsGetCurrentContext()!)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()

            image.resizableImage(withCapInsets: UIEdgeInsets.zero)

            slider.setMinimumTrackImage(image, for: .normal)
            slider.setMaximumTrackImage(image, for: .normal)
        }
    }
}
