import AVFoundation

/// Manages Text-to-Speech (TTS) for recipe instructions.
class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var steps: [String] = []
    private var currentStepIndex = 0
    private var isPlaying = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    /// Start speaking a series of steps.
    func speakSteps(_ steps: [String]) {
        self.stop()
        self.steps = steps
        self.currentStepIndex = 0
        self.isPlaying = true
        
        // Slight initial delay to let the video/audio session stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.speakNextStep()
        }
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        steps = []
        currentStepIndex = 0
        isPlaying = false
    }
    
    private func speakNextStep() {
        guard isPlaying, currentStepIndex < steps.count else {
            isPlaying = false
            return
        }
        
        let step = steps[currentStepIndex]
        let utterance = AVSpeechUtterance(string: "Step \(currentStepIndex + 1): \(step)")
        
        // Standard voice configuration
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 1.5 // Delay before the next step starts
        
        synthesizer.speak(utterance)
        currentStepIndex += 1
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isPlaying {
            speakNextStep()
        }
    }
}
