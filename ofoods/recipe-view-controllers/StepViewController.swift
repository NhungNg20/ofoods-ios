//
//  NewDirectionViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 3/5/2023.
//

import UIKit

class StepViewController: UIViewController {

    @IBOutlet weak var stepDetailsTextView: UITextView!
    @IBOutlet weak var stepNumberTextField: UITextField!
    var delegate: RecipeUpdateDelegate?
    var directions: [Step]?
    var step: Step?

    override func viewDidLoad() {
        super.viewDidLoad()
        stepDetailsTextView.becomeFirstResponder()
        
        // Check if the step is a creation or edit
        if let step = step {
            let stepNumber = directions?.firstIndex(of: step)
            stepNumberTextField.text = String(stepNumber! + 1)
            stepDetailsTextView.text = step.detail
            stepNumberTextField.isUserInteractionEnabled = true
        } else {
            stepNumberTextField.text = String((directions?.count)! + 1)
            stepNumberTextField.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func onClickCancelBtn(_ sender: Any) {
        if let _ = step {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickSaveBtn(_ sender: Any) {
        // Make sure all details are filled in
        guard let stepNumberText = stepNumberTextField.text, stepNumberText.isEmpty == false,
              let details = stepDetailsTextView.text, details.isEmpty == false else {
            displayMessageError(title: "Incomplete Direction", message: "Please fill in all fields.")
            return
        }
        let stepNumberIndex = Int(stepNumberText)! - 1
        if let step = step {
            var oldStepNumberIndex = directions?.firstIndex(of: step)
            // Ensure the index is not out of bound
            guard stepNumberIndex < (directions?.count)! else {
                displayMessageError(title: "Empty Step", message: "There is no step \(oldStepNumberIndex! + 1)")
                return
            }
            step.detail = details
            // If step number was changed, insert the step at the new index
            if stepNumberIndex != oldStepNumberIndex {
                directions?.remove(at: oldStepNumberIndex!)
                directions?.insert(step, at: stepNumberIndex)
            }
            delegate?.directionsUpdated(directions: directions!)
            navigationController?.popViewController(animated: true)
        } else {
            let newStep = Step()
            newStep.detail = details
            directions?.insert(newStep, at: stepNumberIndex)
            delegate?.directionsUpdated(directions: directions!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        delegate?.stepUpdated()
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
