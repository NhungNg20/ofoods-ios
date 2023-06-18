//
//  UOMViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 5/5/2023.
//

import UIKit

class UOMViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var selectedUnitTextView: UITextField!
    @IBOutlet weak var quantityTextView: UITextField!
    @IBOutlet weak var uomPicker: UIPickerView!
    @IBOutlet weak var ingredNameLabel: UILabel!
    
    var ingredients: [Ingredient]?
    var ingredientName: String?
    var ingredient: Ingredient?
    var units: [String] = [String]()
    var delegate: RecipeUpdateDelegate?
    
    // Key to the units store in user defaults
    let UOM_KEY = "ingredientUnits"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quantityTextView.isUserInteractionEnabled = true
        
        uomPicker.dataSource = self
        uomPicker.delegate = self
        
        // Check if the ingredient is being edit or created
        if let ingredient = ingredient, let quantity = ingredient.quantity {
            ingredNameLabel.text = ingredient.name
            quantityTextView.text = "\(quantity)"
            selectedUnitTextView.text = ingredient.unit
        } else {
            ingredNameLabel.text = ingredientName
        }
        
        // Get the user default UOM units
        let defaultUnits = UserDefaults.standard.object(forKey: UOM_KEY) as? [String] ?? []
        if units.isEmpty {
            units.append(contentsOf: defaultUnits)
        }
        
        uomPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func onClickSaveBtn(_ sender: Any) {
        // Check if ingredient is updated or created
        if ingredient == nil {
            let newIngredient = Ingredient()
            newIngredient.name = ingredientName
            if let quantity = quantityTextView.text, quantity.isEmpty == false {
                newIngredient.quantity = Int(quantity)
            } else {
                newIngredient.quantity = 0
            }
            newIngredient.unit = selectedUnitTextView.text
            ingredients?.append(newIngredient)
        } else {
            if let quantity = quantityTextView.text, quantity.isEmpty == false {
                ingredient?.quantity = Int(quantity)
            } else {
                ingredient?.quantity = 0
            }
            ingredient?.unit = selectedUnitTextView.text
        }
        
        // Let the ingredients listeners know this ingredient is updated
        delegate?.ingredientsUpdated(ingredients: ingredients!)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickCancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return units[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnitTextView.text = units[row]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
