//
//  LoginViewController.swift
//  ios_project
//
//  Created by Fabien Martinez on 09/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

internal final class LoginViewController: UIViewController {
  
  @IBOutlet weak var connectButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!

  @IBAction func createAccountAction(_ sender: AnyObject) {
    
    if emailTextField.text == "" {
      let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
      
      let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      alertController.addAction(defaultAction)
      
      present(alertController, animated: true, completion: nil)
      
    } else {
      Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
        
        if error == nil {
          print("You have successfully signed up")
          //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
          
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
          self.present(vc!, animated: true, completion: nil)
          
        } else {
          let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
          
          let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
          alertController.addAction(defaultAction)
          
          self.present(alertController, animated: true, completion: nil)
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    addPaddingTextFields()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension LoginViewController {
  @IBAction func backToLogin(_ segue: UIStoryboardSegue) {
  }
}
