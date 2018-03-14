//
//  LoginViewController.swift
//  ios_project
//
//  Created by Fabien Martinez on 09/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit

internal final class LoginViewController: UIViewController {
  
  @IBOutlet weak var connectButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var darkView: UIView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!

  //MARK: - Alert Controller
  func showAlertController(message: String){
    let alertController : UIAlertController = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action) in
      return
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
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
  
  @IBAction func loginAction(_ sender: AnyObject) {
    if passwordTextField.text == "" || emailTextField.text == "" {
      self.showAlertController(message: "You should fill all fields")
      return
    }
    self.showLoading(state: true)
    UserDataSource.loginUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (error) in
      self.showLoading(state: false)
      DispatchQueue.main.async {
        if error == nil {
          let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
          self.present(vc, animated: true, completion: nil)
        } else {
          self.showAlertController(message: error!)
        }
      }
    })
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
