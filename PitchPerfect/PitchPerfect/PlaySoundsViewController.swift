//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Pan on 28/02/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class PlaySoundsViewController: UIViewController {
    
    var audioRecorderUrl: URL!
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playSoundForButton(_ sender: UIButton) {
        print("play sound")
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        print("stop")
    }
    
}
