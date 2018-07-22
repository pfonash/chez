//
//  Word.swift
//  chez
//
//  Created by Fonash, Peter S on 7/10/18.
//  Copyright © 2018 Ente. All rights reserved.
//

import Foundation

enum Language: String {
    case french
    case english
}

enum Gender: String {
    case male = "le"
    case female = "la"
    case either = "le or la"
}

enum TextType {
    case sentence
    case gender
    case more
    case emphasis
    case score
}

enum GrammarUnit: String {
        
    case adjective = "adjective"
    case adverb = "adverb"
    case article = "article"
    case conjunction = "conjunction"
    case noun = "noun"
    case preposition = "preposition"
    case pronoun = "pronoun"
    case verb = "verb"
    case phrase = "phrase"
    case pronunciation = "pronunciation"
    case numeral = "numeral"
}

@objc class FrenchWord: NSObject {
    
    var french: String
    var english: String
    var score: Float
    var ldr: NSDate // ldr = last date reviewed
    var grammarUnit: GrammarUnit
    var sentence: String?
    var plural: String?
    var gender: Gender?
    var pronunciation: String?
    var other: String?
    
    init(score: Float, ldr: NSDate, english: String, grammarUnit: GrammarUnit,
         french: String, sentence: String?, plural: String?, gender: Gender?,
         pronunciation: String?, other: String?) {
        
        self.french = french
        self.english = english
        self.ldr = ldr
        self.grammarUnit = grammarUnit
        self.score = score
        self.sentence = sentence
        self.plural = plural
        self.gender = gender
        self.pronunciation = pronunciation
        self.other = other
        
    }
    
    func forMoreUILabel() -> String {
        
        let firstPart = "\(self.gender?.rawValue ?? "-") | \(self.score)"
        let secondPart = "| \(self.plural ?? "-") | \(self.pronunciation ?? "-") "
        let thirdPart = "| \(self.other ?? "-")"
        return firstPart + secondPart + thirdPart
    }
    
    func for_gcfs_update() -> [String: Any] {
        return
            [
                "ldr": NSDate(),
                "score": score
            ]
    }
}








