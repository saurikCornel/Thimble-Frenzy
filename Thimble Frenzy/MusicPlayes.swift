import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    @Published var isSoundOn: Bool = false {
        didSet {
            if isSoundOn {
                playMusic()
            } else {
                stopMusic()
            }
        }
    }

    private init() {
        // Загружаем музыку из файла
        if let url = Bundle.main.url(forResource: "audio", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }

    func playMusic() {
        audioPlayer?.play()
    }

    func stopMusic() {
        audioPlayer?.stop()
    }
}
