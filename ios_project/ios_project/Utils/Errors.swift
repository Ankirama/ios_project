//
//  Errors.swift
//  ios_project
//
//  Created by Fabien Martinez on 13/03/2018.
//  Copyright © 2018 Zero. All rights reserved.
//

enum FirebaseError: Error {
  case NotFound(String)
}

enum DateError: Error {
  case BadConvertion(String)
}
