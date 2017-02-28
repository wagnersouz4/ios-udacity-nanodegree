//
//  Alert.swift
//  PitchPerfect
//
//  Created by @wagnersouz4 on 28/02/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

struct Alert {
    
    private init() {}
    
    static func show(_ title: String, message: String, actionTitle: String = "Dismiss") {
        if let view = UIApplication.shared.keyWindow?.rootViewController {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
            view.present(alert, animated: true, completion: nil)
        } else {
            print("Alert Error: There is no views set. Be sure to call it after the viewDidLoad")
        }
    }
}
