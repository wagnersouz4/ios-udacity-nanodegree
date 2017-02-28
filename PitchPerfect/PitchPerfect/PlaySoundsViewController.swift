//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by @wagnersouz4 on 28/02/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var recordedAudioURL:URL!
    var audioFile:AVAudioFile!
    
    // Audio processing
    var audioEngine:AVAudioEngine!
    
    // Supports audio (buffer/file) scheduling the playback
    var audioPlayerNode: AVAudioPlayerNode!
    
    var stopTimer: Timer!
    
    // Default alerts messages used
    struct Message {
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
        // Avoiding initialization as this struct will only contains constants
        private init() {}
    }
    
    enum PlayingState {
        case playing, notPlaying
    }
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }

    // MARK: Audio Functions
    
    func setupAudio() {
        // Initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch let error as NSError{
            Alert.show(Message.AudioFileError, message: error.domain.description)
        }
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        // Initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // Creating and attaching a new audio playback to the audioEngine
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // Node for pitch/rate effect.
        let changeRatePitchNode = AVAudioUnitTimePitch()
        
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        
        audioEngine.attach(changeRatePitchNode)
        
        // Node for echo effect
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // Node for reverb
        let reverbNode = AVAudioUnitReverb()
        // Using a cathedral environment as default acoustic characteristic
        reverbNode.loadFactoryPreset(.cathedral)
        
        // Setting the blend to be half dry and wet (dry: unmodified original signal, wet: signal modified by the device when outputted).
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // Connecting nodes
        switch (echo, reverb) {
        case(true, true):
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        case(true, _):
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        case(_, true):
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        default:
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // Schedule to play and start the engine using the following traling closure. Using at: nil means that there is no handler after the audio has been played
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            // AVAudioNode sample times have an arbitrary zero point. As a consequence AVAudioPlayerNode superimposes a second “player timeline” on the top of it. The calculation bellow is nedded to set the stopTimer correctly.
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                let rate = rate ?? 1
                delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
            }
            
            // Schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        do {
            try audioEngine.start()
        } catch let error as NSError{
            Alert.show(Message.AudioEngineError, message: error.domain.description)
            return
        }
        
        // Play the recording
        audioPlayerNode.play()
        configureUI(.playing)
    }
    
    func stopAudio() {
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for index in 0..<nodes.count-1 {
            audioEngine.connect(nodes[index], to: nodes[index+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions
    
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
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
    
    @IBAction func playSoundForButton(_ sender: UINamedButton) {
        
        switch sender.name {
        case"snail":
            playSound(rate: 0.5)
        case "rabbit":
            playSound(rate: 1.5)
        case "chipmunk":
            playSound(pitch: 1000)
        case "darthVader":
            playSound(pitch: -1000)
        case "echo":
            playSound(echo: true)
        case "reverb":
            playSound(reverb: true)
        default:
            break
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        stopAudio()
    }
}
