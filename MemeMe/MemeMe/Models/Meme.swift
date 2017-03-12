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
    dynamic var topText = ""
    dynamic var bottomText = ""
    dynamic var originalImageName = ""
    dynamic var memedImageName = ""

    var originalImageAsUIImage: UIImage? {
        return UIImage(contentsOfFile: FileUtils.documentDirectory.appendingPathComponent(
            originalImageName).path)
    }

    var memedImageAsUIImage: UIImage? {
        return UIImage(contentsOfFile: FileUtils.documentDirectory.appendingPathComponent(
            memedImageName).path)
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
            //realm.deleteAll()
            return realm.objects(Meme.self)
        } catch let error as NSError {
            fatalError("Error while retriving Memes: \(error.localizedDescription)")
        }
    }
}
