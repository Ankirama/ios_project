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
  class func createUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void) {
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
                completion(true)
              }
            })
          }
        })
      }
      else {
        completion(false)
      }
    })
  }
  
  class func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
    Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
      if error == nil {
        UserDefaults.standard.set(user?.uid, forKey: "userID")
        completion(true)
      } else {
        completion(false)
      }
    })
  }
  
  class func logoutUser(completion: @escaping (Bool) -> Swift.Void) {
    do {
      try Auth.auth().signOut()
      UserDefaults.standard.removeObject(forKey: "userID")
      completion(true)
    } catch _ {
      completion(false)
    }
  }
  
  class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
    Auth.auth().currentUser?.reload(completion: { (_) in
      let status = (Auth.auth().currentUser?.isEmailVerified)!
      completion(status)
    })
  }
  
  class func getUser(forUserID: String, completion: @escaping (UserDataSource) -> Swift.Void) {
    Database.database().reference().child("users").child(forUserID).child("infos").observeSingleEvent(of: .value, with: { (snapshot) in
      if snapshot.exists() == false {
        fatalError("Unable to find your user, it may have been deleted")
      }
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
            completion(user)
          }
        }).resume()
      }
    })
  }
  
  class func updateUserMe(withValues: [String: String], completion: @escaping (Bool) -> Swift.Void) {
    Database.database().reference().child("users").child(UserDefaults.standard.string(forKey: "userID")!).child("infos").updateChildValues(withValues, withCompletionBlock: { (err, user) in
      if err == nil {
        completion(true)
      } else {
        completion(false)
      }
    })
  }
  
  class func getUsers(exceptID: String, completion: @escaping (UserDataSource) -> Swift.Void) {
    Database.database().reference().child("users").observe(.value, with: { (snapshot) in
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
        }
      }).resume()
    })
  }
  
}
