//
//  FileUtils.swift
//  MemeMe
//
//  Created by Pan on 12/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import Foundation

struct FileUtils {
    static var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
