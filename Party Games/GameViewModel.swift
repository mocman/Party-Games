//
//  GameViewModel.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/15/23.
//

import SwiftUI
import Combine
import AVKit

class GameViewModel: ObservableObject {
    
    @Published var fetchError: FetchError? = nil
    @Published var showError = false

    @Published var isGameStarted = false
    @Published var isGameOver = false
    @Published var isGameLoaded = false
    
    @Published var startButtonScale: Double = 1
    @Published var startButtonRotation: Double = 0
    
    @Published var isCorrect: Bool? = nil
    
    @Published var playerOneCurrentFraction: CGFloat = 0.5
    @Published var playerTwoCurrentFraction: CGFloat = 0.5
    
    @Published var playerOnePoints: CGFloat = 0.5
    @Published var playerTwoPoints: CGFloat = 0.5
    
    @Published var isHolding = false
    
    @Published var playerOneIsActive = true
 
    @Published var timer: AnyCancellable?
    @Published var touchStartTime: Date?
    
    @Published var movies: [Movie] = []
    @Published var currentMovieIndex = 0
    
    @Published var actors: [String] = ["Oliver Carlock"]
    @Published var currentActorIndex = 0
    
    @Published var additionalActorsInCurrentMovie: [String] = []
    
    @Published var audioPlayer: AVAudioPlayer?
    
    // MARK: - Game Functions
    
    func loadGame() {
        if !isGameLoaded {
            Task {
                await prepareNewGame()
            }
            
            prepareSound(soundName: "finish", type: "m4a")
        }
    }
    
    func prepareNewGame() async {
        DispatchQueue.main.async { [self] in
            isGameLoaded = false
            currentActorIndex = 0
            
            isCorrect = nil
            isGameStarted = false
            
            playerTwoCurrentFraction = 0.5
            playerOneCurrentFraction = 0.5
            
            nextMovie()
            
            withAnimation(.easeIn(duration: 0.4)) {
                isGameOver = false
            }
        }
        
        await fetchNewGame()
        
        DispatchQueue.main.async { [self] in
            nextMovie()
        }
    }
    
    func startGame() {
        playerTwoPoints = 0.5
        playerOnePoints = 0.5
        
        withAnimation(.easeIn(duration: 0.25)) {
            isGameStarted = true
        }
        
        startTimer()
    }
    
    func gameOver() {
        isGameOver = true
        playSound()
    }
    
    func nextMovie() {
        
        let current = currentMovieIndex
        
        var random = (0..<movies.count).randomElement()
        
        if movies.count > 0 {
            while random == current {
                random = (0..<movies.count).randomElement()
            }
            
            for actor in additionalActorsInCurrentMovie {
                   if let indexOfActors = actors.firstIndex(of: actor) {
                       actors.remove(at: indexOfActors)
                       if let indexOfAdditionals = additionalActorsInCurrentMovie.firstIndex(of: actor) {
                           additionalActorsInCurrentMovie.remove(at: indexOfAdditionals)
                       }
                   }
            }
    
            if let cast = movies[random ?? 0].cast {
                let mainCast = Array(cast.prefix(4))
                
                actors.append(contentsOf: mainCast)
                actors.append(contentsOf: mainCast)
                
                additionalActorsInCurrentMovie = mainCast
                additionalActorsInCurrentMovie.append(contentsOf: mainCast)
            }
        }
        
        currentMovieIndex = random ?? 0
    }
    
    func nextActor() {
        
        let current = currentActorIndex
        
        var random = (0..<actors.count).randomElement()
        
        if actors.count > 0 {
            while random == current {
                random = (0..<actors.count).randomElement()
            }
        }
        
        currentActorIndex = random ?? 0
    }
    
    
    // MARK: - Timer & Sound Functions
    
    func startTimer() {
        timer?.cancel() // Cancel the previous timer if it exists
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.nextActor()
            }
    }
    
    func cancelTimer() {
            timer?.cancel()
    }
    
    func prepareSound(soundName: String, type: String) {
        if let path = Bundle.main.path(forResource: soundName, ofType: type) {
            
            self.audioPlayer = AVAudioPlayer()
            
            let url = URL(fileURLWithPath: path)
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.volume = 0.25
            }catch {
                print("Error")
            }
        }
    }
    
    func playSound() {
        audioPlayer?.play()
    }
    
    
    // MARK: - Gesture Functions
    
    func handleDragChanged(isPlayerOne: Bool) {
        if !isHolding {
            isHolding = true
            cancelTimer()
            touchStartTime = Date()
            
            playerOneIsActive = isPlayerOne
            
            withAnimation(.easeOut(duration: 0.15)) {
                
                if isPlayerOne {
                    playerOneCurrentFraction = 1.0
                    playerTwoCurrentFraction = 0.0
                } else {
                    playerOneCurrentFraction = 0.0
                    playerTwoCurrentFraction = 1.0
                }
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [self] in
                if let startTime = touchStartTime {
                    let holdDuration = Date().timeIntervalSince(startTime)
                    
                    if isHolding && holdDuration >= 0.15 {
                        // Ensure the user is still holding after the delay
                        withAnimation(.easeOut(duration: 0.1)) {
                            if currentMovieIndex < movies.count {
                                isCorrect = movies[currentMovieIndex].cast?.contains { $0 == actors[currentActorIndex] }
                            }
                        }
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                        
                        if isPlayerOne {
                            
                            if isCorrect != nil && isCorrect! {
                                playerOnePoints += 0.15
                                playerTwoPoints -= 0.15
                            } else {
                                playerOnePoints -= 0.15
                                playerTwoPoints += 0.15
                            }
                        } else {
                            if isCorrect != nil && isCorrect! {
                                playerTwoPoints += 0.15
                                playerOnePoints -= 0.15
                            } else {
                                playerTwoPoints -= 0.15
                                playerOnePoints += 0.15
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleDragEnded() {

        startTimer()
        withAnimation(.easeOut(duration: 0.25)) {
            isCorrect = nil
        }
        
        if let startTime = touchStartTime {
            let holdDuration = Date().timeIntervalSince(startTime)
            if isHolding && holdDuration >= 0.15 {
                nextActor()
            }
            
            withAnimation(.spring) {
                if playerTwoPoints < 0.10 || playerOnePoints < 0.10 {
                    cancelTimer()
                    gameOver()
                }
            }
        }
        
        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.125)) {
            
            if let startTime = touchStartTime {
                let holdDuration = Date().timeIntervalSince(startTime)
                if isHolding && holdDuration >= 0.15 {
                    nextMovie()
                }
            }
            touchStartTime = nil
            
            playerOneCurrentFraction = playerOnePoints
            playerTwoCurrentFraction = playerTwoPoints
            isHolding = false
            
        }
        
    }
    
    
    // MARK: - Network Functions
    
    func fetchNewGame() async {
        do {
            
            let fetchedMovies = try await fetchTopMovies()
            
            DispatchQueue.main.async { [self] in
                movies = Array(fetchedMovies)
                actors = ["Oliver Carlock"]
            }
            
            for i in 0 ..< fetchedMovies.count {
                let cast = try await fetchCastForMovie(movieID: fetchedMovies[i].id)
                
                let actorNames = cast.map { $0.name }
                let mainCast = Array(cast.prefix(2))
                let mainActorNames = mainCast.map { $0.name }
                
                DispatchQueue.main.async { [self] in
                    movies[i].cast = actorNames
                    actors.append(contentsOf: mainActorNames)
                }
            
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [self] in
                withAnimation(.easeIn(duration: 0.4)) {
                    isGameLoaded = true
                }
            })
            
        } catch let error as FetchError {
            DispatchQueue.main.async { [self] in
                fetchError = error
                showError = true
            }
        } catch {
            DispatchQueue.main.async { [self] in
                print("Unknown Error")
                fetchError = nil
                showError = true
            }
        }
    }
    
    //API Documentation: https://developer.themoviedb.org/reference/discover-movie
    func fetchTopMovies() async throws -> [Movie] {
        guard let apiKey = getAPIKey(named: "TMDB_API") else {
            throw FetchError.apiKeyError
        }
        
        let randomPage = "\((1...6).randomElement() ?? 1)"
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&sort_by=revenue.desc&primary_release_date.gte=2000-01-01&region=US&with_original_language=en&with_release_type=3&page=\(randomPage)"
        let url = URL(string: urlString)!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw FetchError.connectionError
            }
            
            let decoder = JSONDecoder()
            let movieList = try decoder.decode(MovieResponse.self, from: data)
            
            return movieList.results

        } catch {
            throw FetchError.connectionError
        }
    }

    //API Documentation: https://developer.themoviedb.org/reference/movie-credits
    //API Key is located in Secrets.plist
    func fetchCastForMovie(movieID: Int) async throws -> [Actor] {
        guard let apiKey = getAPIKey(named: "TMDB_API") else {
            throw FetchError.apiKeyError
        }
        
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/credits?api_key=\(apiKey)"
        let url = URL(string: urlString)!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw FetchError.connectionError
            }
            
            let decoder = JSONDecoder()
            let castList = try decoder.decode(CastResponse.self, from: data)
            
            return castList.cast
            
        } catch {
            throw FetchError.connectionError
        }
    }
    
    func getAPIKey(named keyname:String) -> String? {
        if let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            
            let plist = NSDictionary(contentsOfFile:filePath)
            let value = plist?.object(forKey: keyname) as? String
            return value
            
        } else {
            return nil
        }
    }

}
