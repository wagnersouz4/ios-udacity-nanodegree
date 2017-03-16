//
//  FileUtils.swift
//  MemeMe
//
//  Created by Wagner Souza on 12/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import Foundation
import UIKit
struct FileUtils {
    static var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func readAsync(contentsOfFile path: String, completionHandler handler: @escaping (_:NSData?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = NSData(contentsOfFile: path)
            DispatchQueue.main.async {
                handler(data)
            }
        }
    }
}
