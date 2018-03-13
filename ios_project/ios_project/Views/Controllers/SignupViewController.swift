//
//  SignupViewController.swift
//  ios_project
//
//  Created by Fabien Martinez on 09/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit
import FirebaseAuth

internal final class SignupViewController: UIViewController {
  
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var password2TextField: UITextField!
  
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
  
  @IBAction func signUpAction(_ sender: AnyObject) {
    if passwordTextField.text == "" || password2TextField.text == "" || emailTextField.text == "" {
      self.showAlertController(message: "You should fill all fields")
      return
    }
    if password2TextField.text != passwordTextField.text {
      self.showAlertController(message: "Your 2 passwords must match ")
    }
    Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
      if error != nil {
        self.showAlertController(message: (error?.localizedDescription)!)
      } else {
        print("Account created")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: true, completion: nil)
      }
    }
  }
}
