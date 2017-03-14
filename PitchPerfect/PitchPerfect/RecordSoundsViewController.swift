//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Wagner Souza on 27/02/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopRecordingButton.isEnabled = false
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            Alert.show("error", message: "There was an audio encoding error")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let avError = error {
            Alert.show("Error", message: avError.localizedDescription)
        } else {
            Alert.show("Error", message: "The audio recording failed!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            if let playSoundVC = segue.destination as? PlaySoundsViewController, let url = sender as? URL {
                playSoundVC.recordedAudioURL = url
            }
        }
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        recordButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        recordingLabel.text = "Recording in Progress"

        // Obtaining the app directory as String
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // shared instance means that this resource/hardware (audio circuit) is shared between the apps in the system
        let session = AVAudioSession.sharedInstance()
        do {
            // Category used when recording and playing back audio.
            // The category opation .defaultToSpeaker is only valid with AVAudioSessionCategoryPlayAndRecord
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)

            // URL(string:) is a failable initializer. Is there is an invalid character in the string it will return null
            if let stringifiedFilePath = filePath {
                try audioRecorder = AVAudioRecorder(url: stringifiedFilePath, settings: [:])
                audioRecorder.delegate = self
                //Before using metering for an audio player metering should be true. Meters are the displays that shows the audio's signal level and/or the amount of gain reduction being applyied by a compressor/limiter
                audioRecorder.isMeteringEnabled = true
                
                // creates the file and gets ready to record
                if audioRecorder.prepareToRecord() {
                    audioRecorder.record()
                }
            }
        } catch let error as NSError {
            Alert.show("Error", message: error.domain.description)
        }
    }

    @IBAction func stopRecording(_ sender: UIButton) {
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        recordingLabel.text = "Tap to Record"
        if audioRecorder.isRecording {
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch let error as NSError {
                Alert.show("Error", message: error.domain.description)
            }
        }
    }
}

