//
//  InfoViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit

class InfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBtn: UIButton!
    var author: User?
    var recipe: Recipe?
    var isView: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.becomeFirstResponder()
        
        // If viewing/editing the recipe, fill in the recipe info
        if let recipe = recipe {
            if let title = recipe.title {
                titleTextField.text = title
            }
            if let cookTime = recipe.cookTimeInMins {
                cookTimeTextField.text = String(cookTime)
            }
            if let servings = recipe.servings {
                servingsTextField.text = String(servings)
            }
            if let story = recipe.story {
                storyTextView.text = String(story)
            }
            if let image = recipe.image {
                imageBtn.setTitle("Change Image", for: .normal)
                imageView.image = image
            }
            if let author = author, let authorName = author.userName {
                authorLabel.text = "Author: \(authorName)"
                authorLabel.textColor = UIColor(named: "Orange")
            }
            if isView == true {
                imageBtn.isHidden = true
            }
        }
        
        // If viewing the recipe, don't allow edit
        if let isView = isView, isView == true {
            titleTextField.isUserInteractionEnabled = false
            cookTimeTextField.isUserInteractionEnabled = false
            servingsTextField.isUserInteractionEnabled = false
            storyTextView.isEditable = false
            imageBtn.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func onClickImageBtn(_ sender: Any) {
        var controller: UIImagePickerController?
        
        // Set up the image picker controller
        let alert = UIAlertController(title: "Choose image from...", message: nil, preferredStyle: .actionSheet)
        
        // Set up the Camera option for the image picker
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            controller = UIImagePickerController()
            controller!.sourceType = .camera
            controller!.allowsEditing = false
            controller!.delegate = self
            self.present(controller!, animated: true, completion: nil)
        }))
        
        // Set up the Gallery option for the image picker
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            controller = UIImagePickerController()
            controller!.sourceType = .photoLibrary
            controller!.allowsEditing = false
            controller!.delegate = self
            self.present(controller!, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        imageView.image = image
        imageBtn.setTitle("Change Image", for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
