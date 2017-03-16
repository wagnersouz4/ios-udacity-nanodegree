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

    static func readAsync(contentsOfFile url: URL, completionHandler handler: @escaping (_:Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                handler(data)
            }
        }
    }
}
