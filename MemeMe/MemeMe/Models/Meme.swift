//
//  Meme.swift
//  MemeMe
//
//  Created by Wagner Souza on 9/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit
import RealmSwift

class Meme: Object {
    // It's needed to set a default value to the properties in order to user Realm
    // See https://github.com/realm/realm-cocoa/issues/3185

    dynamic var uuid = UUID().uuidString
    dynamic var topText = ""
    dynamic var bottomText = ""
    dynamic var originalImageName = ""
    dynamic var memedImageName = ""

    // Read-only properties are ignored by default
    var originalImageURL: URL {
        return  FileUtils.documentDirectory.appendingPathComponent(
            originalImageName)
    }

    var memedImageURL: URL {
        return FileUtils.documentDirectory.appendingPathComponent(
            memedImageName)
    }

    // Realm does not require a standard incremented key like int to serve as a primary key.
    // The unique requirement is that it's need to be unique. In this project UUID has been used
    // to met this requirement, as it often generates a unique string.
    override class func primaryKey() -> String? {
        return "uuid"
    }

    convenience init(topText: String, bottomText: String, originalImageName: String, memedImageName: String) {
        self.init()
        self.topText = topText
        self.bottomText = bottomText
        self.originalImageName = originalImageName
        self.memedImageName = memedImageName
    }

    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError("Error while saving Meme: \(error.localizedDescription)")
        }
    }

    func update(using meme: Meme) {
        do {
            let realm = try Realm()
            try realm.write {
                self.topText = meme.topText
                self.bottomText = meme.bottomText
                self.memedImageName = meme.memedImageName
                self.originalImageName = meme.originalImageName
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            print("It was not possible to update the meme :\(error.localizedDescription)")
        }
    }

    static func clean() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            fatalError("Error while deleting database: \(error.localizedDescription)")
        }

    }

    static func loadAll() -> Results<Meme> {
        do {
            let realm = try Realm()
            return realm.objects(Meme.self)
        } catch let error as NSError {
            fatalError("Error while retriving Memes: \(error.localizedDescription)")
        }
    }
}
