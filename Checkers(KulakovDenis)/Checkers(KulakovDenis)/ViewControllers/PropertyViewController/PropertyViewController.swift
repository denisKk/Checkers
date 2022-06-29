//
//  PropertyViewController.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 23.06.22.
//

import UIKit

class PropertyViewController: UIViewController {

    @IBOutlet weak var boardSizeSegment: UISegmentedControl!
    @IBOutlet weak var secondPlayerNameTextField: UITextField!
    @IBOutlet weak var startGameButton: BorderButton!
    @IBOutlet weak var timeLimitPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    
    @IBAction func closeButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension PropertyViewController {
    func setupUI(){
        setupPickers()
        setupTextField()
        setupButtons()
        loadData()
        setupSegmentedControl()
    }
    
    func loadData(){
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }
    
    func setupSegmentedControl(){
        boardSizeSegment.selectedSegmentTintColor = (self.view as? GradientBackgroundView)?.startColor ?? .orange
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        boardSizeSegment.setTitleTextAttributes(titleTextAttributes, for: .normal)
        boardSizeSegment.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    func setupPickers(){
        timeLimitPicker.delegate = self
    }
    
    func setupButtons(){
        startGameButton.isUserInteractionEnabled = true
        startGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapStartGameButton)))
    }
    
    func setupTextField(){
        secondPlayerNameTextField.delegate = self
        secondPlayerNameTextField.simpleModifier()
    }
    
    @objc
    func tapStartGameButton(){
        guard startGameButton.isEnabled else {return}
        
        saveGameProperty()
        goToGameViewController()
    }
    
    func saveGameProperty(){
        Settings.shared.secondPlayerName = secondPlayerNameTextField.text
        Settings.shared.timeLimit = TimeType.allCases[timeLimitPicker.selectedRow(inComponent: 0)]
        Settings.shared.boardSize = getBoardSize()
            

    }
    
    func getBoardSize() -> BoardSize {
        switch boardSizeSegment.selectedSegmentIndex {
        case 0:
            return .size8x8
        case 1:
            return .size10x10
        default: return .size8x8
        }
    }
    
    func goToGameViewController(){
        guard let vc = GameViewController.getInstanceViewController as? GameViewController
        else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension PropertyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            startGameButton.isEnabled = false
        } else {
            startGameButton.isEnabled = true
        }
    }
    
}

extension PropertyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        TimeType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        TimeType.allCases[row].description()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: TimeType.allCases[row].description(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }

}

