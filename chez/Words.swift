//
//  Words.swift
//  chez
//
//  Created by Fonash, Peter S on 7/10/18.
//  Copyright © 2018 Ente. All rights reserved.
//

import Foundation

enum RearrangeMethod {
    case forward
    case back
    case shuffle
    case reshuffle
}

let scorer = FrenchWordScorer()
let wordsManager = WordManager()
let gcfsInterance = FirestoreInterface()

class Words: NSObject {
    
    let unitStringToEnum = [
        "adjective": GrammarUnit.adjective,
        "adverb": GrammarUnit.adverb,
        "article": GrammarUnit.article,
        "conjunction": GrammarUnit.conjunction,
        "noun": GrammarUnit.noun,
        "preposition": GrammarUnit.preposition,
        "pronoun": GrammarUnit.pronoun,
        "verb": GrammarUnit.verb,
        "phrase": GrammarUnit.phrase,
        "pronunciation": GrammarUnit.pronunciation,
        "numeral": GrammarUnit.numeral
    ]
    
    @objc dynamic var currentWord: FrenchWord
    
    private(set) var wordsDownloaded = [FrenchWord]()
    private(set) var wordsToReview = [FrenchWord]()
    private(set) var wordsReviewed = [FrenchWord]()
    
    override init() {
        self.currentWord = FrenchWord (
            score: 1.0,
            ldr: NSDate(),
            english: "such is life",
            grammarUnit: GrammarUnit.phrase,
            french: "c'est la vie",
            sentence: nil,
            plural: nil,
            gender: nil, 
            pronunciation: nil,
            other: nil
        )
    }
    
    func setCurrentWord(currentWord: FrenchWord) {
        self.currentWord = currentWord
    }
    
    // 50% chance the function returns true (french); 50% chance the function returns false English).
    func setLanguage(for word: FrenchWord) -> Language {
        if word.grammarUnit.rawValue == "phrase" || word.grammarUnit.rawValue == "numeral" {
            return Language.english
        }
        
        if word.grammarUnit.rawValue == "pronunciation" {
            return Language.french
        }
        
        if 6.arc4random > 2 {
            return Language.french
        }
        return Language.english
    }
    
    func determineGrammarUnit(unit: String) -> GrammarUnit? {
        return unitStringToEnum[unit]
    }
    
    func determineGender(from str: String?) -> Gender? {
        
        if str != nil {
            switch str {
            case "male": return Gender.male
            case "female": return Gender.female
            default:
                return nil
            }
        }
        return nil
    }
    
    func parse(word: [String: Any]) -> FrenchWord? {
        
        if let score = word["score"] as? Float {
            if let grammarUnitString = word["grammar_unit"] as? String {
                if let grammarUnit = determineGrammarUnit(unit: grammarUnitString) {
                    if let french = word["french"] as? String {
                        if let english = word["english"] as? String {
                            if let ldr = word["ldr"] as? NSDate {
                                return FrenchWord (
                                    score: score,
                                    ldr: ldr,
                                    english: english,
                                    grammarUnit: grammarUnit,
                                    french: french,
                                    sentence: word["sentence"] as? String,
                                    plural: word["plural"] as? String,
                                    gender: (determineGender(from: word["gender"] as? String)),
                                    pronunciation: word["pronunciation"] as? String,
                                    other: word["other"] as? String
                                )
                            }
                        }
                    }
                }
            }
        }
        return nil
        
    }

    func add(words: [[String : Any]]) -> [FrenchWord] {
        for word in words {
            if let parsedWord = parse(word: word) {
                self.wordsDownloaded.append(parsedWord)
            }
        }
        return self.wordsDownloaded
    }
    
    func setWordsToReview(words: [FrenchWord]) {
        self.wordsToReview = words
        self.wordsToReview.shuffle()
    }
    
    func markReviewed(word: FrenchWord) {
        self.wordsReviewed.append(word)
    }
    
    func resetReviewedWords() {
        self.wordsReviewed.removeAll()
    }
    
    func updateCurrentWordScore(with result: Bool) {
        let newScore = scorer.calculateScore(for: self.currentWord, after: result)
        self.currentWord.score = newScore
    }
    
    func getNext(using method: RearrangeMethod, result: Bool) {
        updateCurrentWordScore(with: result)
        markReviewed(word: self.currentWord)
        rearrange(using: method)
    }
    
    func reshuffle() {
        setWordsToReview(words: self.wordsDownloaded)
        self.currentWord = self.wordsToReview.removeFirst()
    }
    
    private func rearrange(using method: RearrangeMethod) {
        
        switch method  {
        case .back:
            break
        case .forward:
            if !self.wordsToReview.isEmpty {
               self.currentWord = self.wordsToReview.removeFirst()
            }
        case .shuffle:
            break
        case .reshuffle:
            break
        }
    }
}

// Extension to get random numbers in a readable way
extension Int {
    
    var arc4random: Int {
        
        if self  > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }
        else if self < 0 {
            return -(Int(arc4random_uniform(UInt32(self))))
        }
        else {
            return 0
        }
    }
}

// Extension to shuffle words
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
