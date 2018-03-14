//
//  UserDataSource.swift
//  ios_project
//
//  Created by Fabien Martinez on 12/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

import Firebase

final class UserDataSource {
  
  //MARK: Properties
  let userID: String
  let email: String
  let name: String
  let facebookID: String
  let googleID: String
  let profilePic: UIImage
  let details: String
  
  //MARK: Inits
  init(name: String, email: String, facebookID: String, userID: String, googleID: String, profilePic: UIImage, details: String){
    self.name = name
    self.email = email
    self.facebookID = facebookID
    self.userID = userID
    self.googleID = googleID
    self.profilePic = profilePic
    self.details = details
  }

  //MARK: Methods
  /**
  Create a user by calling firebase Auth framework

  - returns:
  An async callback wich return nil or a String (if any error)
   
  - parameters:
     - withName: fullname like `Fabien Martinez`. Can not be empty
     - email: Email to login like `ankirama@patate.io`. Can not be empty
     - password: Password to login like `meowzeroplouf`. Length >= 6
     - profilePic: Profile picture
     - completion: Callback used to work with Firebase
  */
  class func createUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (String?) -> Swift.Void) {
    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
      if error == nil {
        let storageRef = Storage.storage().reference().child("usersProfilePics").child(user!.uid)
        let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
        storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
          if err == nil {
            let path = metadata?.downloadURL()?.absoluteString
            let values = ["name": withName, "email": email, "profilePicLink": path!, "facebookID": "", "googleID": "", "details": ""]
            Database.database().reference().child("users").child((user?.uid)!).child("infos").updateChildValues(values, withCompletionBlock: { (err, _) in
              if err == nil {
                UserDefaults.standard.set(user?.uid, forKey: "userID")
                completion(nil)
              }
            })
          } else {
            completion(err?.localizedDescription)
          }
        })
      }
      else {
        completion(error?.localizedDescription)
      }
    })
  }
  
  /**
   Authenticate a user and set UserDefaults userID
   
   - returns:
   An async callback wich return nil or a String (if any error)

   - parameters:
     - withEmail: (String) email used to create the account
     - password: (String) password used to create the acocunt
     - completion: Callback used to work with Firebase
  */
  class func loginUser(withEmail: String, password: String, completion: @escaping (String?) -> Swift.Void) {
    Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
      if error == nil {
        UserDefaults.standard.set(user?.uid, forKey: "userID")
        completion(nil)
      } else {
        completion(error?.localizedDescription)
      }
    })
  }
  
  /**
   Logout a user and remove userID in UserDefaults
   
   - returns:
   An async callback wich return nill or a String (if any error)
   
   - parameters:
      - completion: Callback used to work with Firebase
  */
  class func logoutUser(completion: @escaping (String?) -> Swift.Void) {
    do {
      try Auth.auth().signOut()
      UserDefaults.standard.removeObject(forKey: "userID")
      completion(nil)
    } catch {
      completion("Unable to logout your user")
    }
  }
  
  class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
    Auth.auth().currentUser?.reload(completion: { (_) in
      let status = (Auth.auth().currentUser?.isEmailVerified)!
      completion(status)
    })
  }
  
  /**
   Get user info
   
   - returns:
   An async callback wich return an error (String) and a user (UserDataSource)

   - parameters:
       - forUserID: (String) UserID from firebase
       - completion: Callback used to work with Firebase
  */
  class func getUser(forUserID: String, completion: @escaping (String?, UserDataSource?) -> Swift.Void) {
    Database.database().reference().child("users").child(forUserID).child("infos").observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists() == false {
        completion("Unable to find your user", nil)
      } else {
        if let data = snapshot.value as? [String: String] {
          let name = data["name"]!
          let email = data["email"]!
          let facebookID = data["facebookID"]!
          let googleID = data["googleID"]!
          let details = data["details"]!
          let link = URL.init(string: data["profilePicLink"]!)
          URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
            if error == nil {
              let profilePic = UIImage.init(data: data!)
              let user = UserDataSource.init(name: name, email: email, facebookID: facebookID, userID: forUserID, googleID: googleID, profilePic: profilePic!, details: details)
              completion(nil, user)
            } else {
              completion(error?.localizedDescription, nil)
            }
          }).resume()
        }
      }
    })
  }
  
  /**
   Update a user info
   
   - returns:
   An async callback wich return nill or a String (if any error)

   - parameters:
     - user: (UserDataSource) user with updated info
     - completion: Callback used to work with Firebase
  */
  class func updateUser(user: UserDataSource, completion: @escaping (String?) -> Swift.Void) {
    let values = ["name": user.name, "facebookID": user.facebookID, "googleID": user.googleID, "details": user.details]
    Database.database().reference().child("users").child(user.userID).child("infos").updateChildValues(values, withCompletionBlock: { (err, _) in
      completion(err?.localizedDescription)
    })
  }
  
  /**
   Get all users info asynchronously
   
   - returns:
   An async callback wich return a user (UserDataSource) or nil if any error
   
   - parameters:
   - forUserID: (String) UserID from firebase
   - completion: Callback used to work with Firebase
   
   This will return every user asynchronously
   */
  class func getUsers(exceptID: String, completion: @escaping (UserDataSource?) -> Swift.Void) {
    Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
      let id = snapshot.key
      let data = snapshot.value as! [String: Any]
      let infos = data["infos"] as! [String: String]
      let name = infos["name"]!
      let email = infos["email"]!
      let facebookID = infos["facebookID"]!
      let googleID = infos["googleID"]!
      let details = infos["details"]!
      let link = URL.init(string: infos["profilePicLink"]!)
      URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
        if error == nil {
          let profilePic = UIImage.init(data: data!)
          let user = UserDataSource.init(name: name, email: email, facebookID: facebookID, userID: id, googleID: googleID, profilePic: profilePic!, details: details)
          completion(user)
        } else {
          completion(nil)
        }
      }).resume()
    })
  }
  
}
