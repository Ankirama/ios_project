//
//  SignupViewController.swift
//  ios_project
//
//  Created by Fabien Martinez on 09/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit
import Photos

internal final class SignupViewController: UIViewController {
  
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var profilePicView: UIImageView!
  @IBOutlet weak var darkView: UIView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: - Alert Controller
  func showAlertController(message: String){
    let alertController : UIAlertController = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action) in
      return
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func openPhotoPickerWith(source: ImageSource) {
    switch source {
    case .camera:
      let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
      if (status == .authorized || status == .notDetermined) {
        self.imagePicker.sourceType = .camera
        self.imagePicker.allowsEditing = true
        self.present(self.imagePicker, animated: true, completion: nil)
      }
    case .library:
      let status = PHPhotoLibrary.authorizationStatus()
      if (status == .authorized || status == .notDetermined) {
        self.imagePicker.sourceType = .savedPhotosAlbum
        self.imagePicker.allowsEditing = true
        self.present(self.imagePicker, animated: true, completion: nil)
      }
    }
  }
  
  func showLoading(state: Bool)  {
    if state {
      self.darkView.isHidden = false
      self.spinner.startAnimating()
      UIView.animate(withDuration: 0.3, animations: {
        self.darkView.alpha = 0.5
      })
    } else {
      UIView.animate(withDuration: 0.3, animations: {
        self.darkView.alpha = 0
      }, completion: { _ in
        self.spinner.stopAnimating()
        self.darkView.isHidden = true
      })
    }
  }
  
  @IBAction func selectPictureAction(_ sender: Any) {
    let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.openPhotoPickerWith(source: .camera)
    })
    let photoAction = UIAlertAction(title: "Gallery", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.openPhotoPickerWith(source: .library)
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    sheet.addAction(cameraAction)
    sheet.addAction(photoAction)
    sheet.addAction(cancelAction)
    self.present(sheet, animated: true, completion: nil)
  }
  
  @IBAction func signUpAction(_ sender: AnyObject) {
    if passwordTextField.text == "" || nameTextField.text == "" || emailTextField.text == "" {
      self.showAlertController(message: "You should fill all fields")
      return
    }
    self.showLoading(state: true)
    UserDataSource.createUser(withName: self.nameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!, profilePic: self.profilePicView.image!) { (error) in
      self.showLoading(state: false)
      DispatchQueue.main.async {
        if error == nil {
          let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
          self.present(vc, animated: true, completion: nil)
        } else {
          self.showAlertController(message: error!)
        }
      }
    }
  }
}
