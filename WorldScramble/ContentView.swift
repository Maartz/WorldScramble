//
//  ContentView.swift
//  WorldScramble
//
//  Created by William Martin on 01/12/2020.
//

import SwiftUI

struct ContentView: View {
  @State private var usedWords = [String]()
  @State private var rootWord = ""
  @State private var newWord = ""
  @State private var score = 0
  
  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingError = false
  
  func addNewWord() {
    let answer = newWord
      .lowercased()
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard answer.count > 0 else {
      return
    }
    
    guard answer.count > 3 else {
      wordError(title: "Word too short", message: "Submitted word should be longer than 3 characters")
      newWord = ""
      return
    }
    
    guard answer != rootWord else {
      wordError(title: "It is the root word", message: "You can't pass the root word as answer…")
      newWord = ""
      return
    }
    
    guard isOriginal(word: answer) else {
      wordError(title: "Word already used", message: "Be more original")
      newWord = ""
      return
    }
    
    guard isPossible(word: answer) else {
      wordError(title: "Word not recognized", message: "You can't make them up, you know!")
      newWord = ""
      return
    }
    
    guard isReal(word: answer) else {
      wordError(title: "Word not possible", message: "That isn't a real word.")
      return
    }
    
    score += (newWord.count / 2) + Int.random(in: 0..<10)
    
    usedWords.insert(answer, at: 0)
    newWord = ""
  }
  
  func startGame() {
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords = try? String(contentsOf: startWordsURL) {
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
        return
      }
    }
    fatalError("Could not load start.txt from bundle")
  }
  
  func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
  }
  
  func isPossible(word: String) -> Bool {
    var tempWord = rootWord
    
    for letter in word {
      if let pos = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: pos)
      } else {
        return false
      }
    }
    return true
  }
  
  func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
    return misspelledRange.location == NSNotFound // NSNotFound is equal to 0
  }
  
  func wordError(title: String, message: String) {
    errorTitle = title
    errorMessage = message
    showingError = true
  }
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter your word", text: $newWord, onCommit: addNewWord)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(.none)
          .padding()
        List(usedWords, id: \.self) {
          Image(systemName: "\($0.count).circle")
          Text($0)
        }
        
        Text("Score: \(score)")
      }.navigationBarTitle(rootWord).onAppear(perform: startGame)
      .navigationBarItems(trailing: Button("New Word") {
        startGame()
      })
      .alert(isPresented: $showingError) {
        Alert(title: Text(errorTitle),
              message: Text(errorMessage),
              dismissButton: .default(Text("OK"))
        )
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
