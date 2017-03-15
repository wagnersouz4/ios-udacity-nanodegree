//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Wagner Souza on 28/02/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var stopTimer: Timer!

    // Audio processing
    var audioEngine: AVAudioEngine!

    // Supports audio (buffer/file) scheduling the playback
    var audioPlayerNode: AVAudioPlayerNode!

    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudio()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }
}

// MARK: Error Message
private extension PlaySoundsViewController {
    // Default alerts messages used
    struct Message {
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
        // Avoiding initialization as this struct will only contains constants
        private init() {}
    }
}

// MARK: Audio and UI configuration
private extension PlaySoundsViewController {
    func configureAudio() {
        // Initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch let error as NSError {
            Alert.show(Message.AudioFileError, message: error.domain.description)
        }
    }

    func configureUI(_ playState: PlayingState) {
        switch playState {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }

    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }
}

// MARK: @IBActions
private extension PlaySoundsViewController {
    @IBAction func playSoundForButton(_ sender: UINamedButton) {
        var audioEffect = AudioEffectSet()
        switch sender.name {
        case"snail":
            audioEffect.rate = 0.5
        case "rabbit":
            audioEffect.rate = 1.5
        case "chipmunk":
            audioEffect.pitch = 1000
        case "darthVader":
            audioEffect.pitch = -1000
        case "echo":
            audioEffect.echo = true
        case "reverb":
            audioEffect.reverb = true
        default:
            break
        }
        playSound(using: audioEffect)
    }

    @IBAction func stopButtonPressed(_ sender: UIButton) {
        stopAudio()
    }
}

// MARK: Audio Managment
private extension PlaySoundsViewController {
    enum PlayingState {
        case playing, notPlaying
    }

    struct AudioEffectSet {
        var rate: Float?
        var pitch: Float?
        var echo = false
        var reverb = false
    }

    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for index in 0..<nodes.count-1 {
            audioEngine.connect(nodes[index], to: nodes[index+1], format: audioFile.processingFormat)
        }
    }

    func configureAudioEngine(using effectSet: AudioEffectSet) {
        // Initialize audio engine components
        audioEngine = AVAudioEngine()
        // Creating and attaching a new audio playback to the audioEngine
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)

        // Default Node for echo effect
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)

        // Default Node for reverb
        let reverbNode = AVAudioUnitReverb()
        // Using a cathedral environment as default acoustic characteristic
        reverbNode.loadFactoryPreset(.cathedral)

        // Setting the blend to be half dry and wet
        // Dry: unmodified original signal - Wet: signal modified by the device when outputted.
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)

        // Node for pitch/rate effect.
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = effectSet.pitch {
            changeRatePitchNode.pitch = pitch
        }

        if let rate = effectSet.rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)

        // Connecting nodes
        switch (effectSet.echo, effectSet.reverb) {
        case(true, true):
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        case(true, _):
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        case(_, true):
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        default:
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }

    }

    func playSound(using effectSet: AudioEffectSet) {
        configureAudioEngine(using: effectSet)
        // Schedule to play and start the engine using the following traling closure.
        audioPlayerNode.stop()
        // Scheduling to play right after the stop command.
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            var delayInSeconds = 0.0

            // AVAudioNode sample times have an arbitrary zero point.
            // As a consequence AVAudioPlayerNode superimposes a second “player timeline” on the top of it.
            // The calculation bellow is needed to set the stopTimer correctly.
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime,
                let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                let rate = Double(effectSet.rate ?? 1.0)
                //The time as a number of audio samples, as tracked by the current audio device.
                //The number of sample frames in the file
                let actualFramePosition = Double(self.audioFile.length - playerTime.sampleTime)
                delayInSeconds = actualFramePosition / self.audioFile.processingFormat.sampleRate / rate
            }

            // Schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self,
                                   selector: #selector(self.stopAudio), userInfo: nil,
                                   repeats: false)
            RunLoop.main.add(self.stopTimer, forMode: RunLoopMode.defaultRunLoopMode)
        }
        do {
            try audioEngine.start()
        } catch let error as NSError {
            Alert.show(Message.AudioEngineError, message: error.domain.description)
            return
        }

        // Play the recording
        audioPlayerNode.play()
        configureUI(.playing)
    }

    @objc func stopAudio() {
        configureUI(.notPlaying)

        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }

        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }

        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }

}
