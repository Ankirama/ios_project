//
//  TaskDataSource.swift
//  ios_project
//
//  Created by Fabien Martinez on 12/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

import Firebase

final class TaskDataSource {

  //MARK: Properties
  let uid: String
  let collaborators: [UserDataSource]
  let title: String
  let description: String
  let is_urgent: Bool
  let is_important: Bool
  let due_date: Date
  
  init(uid: String, collaborators: [UserDataSource], title: String, description: String, is_urgent: Bool, is_important: Bool, due_date: Date){
    self.uid = uid
    self.collaborators = collaborators
    self.title = title
    self.description = description
    self.is_urgent = is_urgent
    self.is_important = is_important
    self.due_date = due_date
  }
  
  //MARK: Methods
  class func getTasks(completion: @escaping (String?, TaskDataSource?) -> Swift.Void) {
    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "d MMM yyyy"
    dateFormatter.dateFormat = "yyyy-MM-dd"

    Database.database().reference().child("tasks").observe(.childAdded, with: {(snapshot) in
      let id = snapshot.key
      let data = snapshot.value as! [String: Any]
      let title = data["title"] as! String
      let description = data["description"] as! String
      let is_urgent = data["is_urgent"] as! Bool
      let is_important = data["is_important"] as! Bool
      var collaborators = [UserDataSource]()
      let myGroup = DispatchGroup()
      for collaboratorID in data["collaborators"] as! [String] {
        myGroup.enter()
        UserDataSource.getUser(forUserID: collaboratorID, completion: { (_, user) in
          if user != nil {
            collaborators.append(user!)
          }
          myGroup.leave()
        })
      }
      guard let due_date = dateFormatter.date(from: data["due_date"] as! String) else {
        completion("Date convertion failed due to mismatched format", nil)
        return
      }
      myGroup.notify(queue: .main) {
        let task = TaskDataSource.init(uid: id, collaborators: collaborators, title: title, description: description, is_urgent: is_urgent, is_important: is_important, due_date: due_date)
        completion(nil, task)
      }
    })
  }
  
  class func getTask(forTaskID: String, completion: @escaping (String?, TaskDataSource?) -> Swift.Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    Database.database().reference().child("tasks").child(forTaskID).observeSingleEvent(of: .value, with: {(snapshot) in
      if snapshot.exists() == false {
        completion("Unable to find your task, it may have been deleted", nil)
      } else {
        let id = snapshot.key
        let data = snapshot.value as! [String: Any]
        let title = data["title"] as! String
        let description = data["description"] as! String
        let is_urgent = data["is_urgent"] as! Bool
        let is_important = data["is_important"] as! Bool
        var collaborators = [UserDataSource]()
        let myGroup = DispatchGroup()
        for collaboratorID in data["collaborators"] as! [String] {
          myGroup.enter()
          UserDataSource.getUser(forUserID: collaboratorID, completion: { (_, user) in
            if user != nil {
              collaborators.append(user!)
            }
            myGroup.leave()
          })
        }
        guard let due_date = dateFormatter.date(from: data["due_date"] as! String) else {
          completion("Date convertion failed due to mismatched format", nil)
          return
        }
        myGroup.notify(queue: .main) {
          let task = TaskDataSource.init(uid: id, collaborators: collaborators, title: title, description: description, is_urgent: is_urgent, is_important: is_important, due_date: due_date)
          completion(nil, task)
        }
      }
    })
  }
  
  class func createTask(task: TaskDataSource, completion: @escaping (String?) -> Swift.Void) {
    var collaborators = [String]()
    for collaborator in task.collaborators {
      collaborators.append(collaborator.userID)
    }
    let values = ["title": task.title, "collaborators": collaborators, "description": task.description, "is_urgent": task.is_urgent, "is_important": task.is_important, "due_date": task.due_date] as [String: Any]
    Database.database().reference().child("tasks").childByAutoId().setValue(values, withCompletionBlock: {(error, _) in
      completion(error?.localizedDescription)
    })
  }
  
  class func updateTask(task: TaskDataSource, completion: @escaping (String?) -> Swift.Void) {
    var collaborators = [String]()
    for collaborator in task.collaborators {
      collaborators.append(collaborator.userID)
    }
    Database.database().reference().child("tasks").child(task.uid).observeSingleEvent(of: .value) { (snapshot) in
      if snapshot.exists() == false {
        fatalError("Unable to find your task, it may have been deleted")
      } else {
        let values = ["title": task.title, "collaborators": collaborators, "description": task.description, "is_urgent": task.is_urgent, "is_important": task.is_important, "due_date": task.due_date] as [String: Any]
        Database.database().reference().child("tasks").child(task.uid).updateChildValues(values, withCompletionBlock: { (err, _) in
          completion(err?.localizedDescription)
        })
      }
    }
  }
  
  class func removeTask(forTaskID: String, completion: @escaping (Bool) -> Swift.Void) {
    // delete
  }
}
