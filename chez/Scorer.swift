//
//  Scorer.swift
//  chez
//
//  Created by Fonash, Peter S on 7/16/18.
//  Copyright © 2018 Ente. All rights reserved.
//

import Foundation

class Scorer {
    /* I'm a class wrapper, short and shout, here are my subclasses, here is my snout.
     */
}

class FrenchWordScorer: Scorer {
    
    var baseScore = Float(1.0)
    
    func calculateScore(for frenchWord: FrenchWord, after transaction: Bool) -> Float {
        return add(currentScoreOf: frenchWord, plus: transaction.scoreValue)
    }
    
    private func add(currentScoreOf frenchWord: FrenchWord,
                     plus scoreFromMostRecentReivew: Float) -> Float {
        
        let newScore = frenchWord.score + scoreFromMostRecentReivew
        if newScore <= 1 {
            return self.baseScore
        } else {
            return newScore
        }
    }
}

extension Bool {
    var scoreValue: Float {
        if self {return 1.0}
        else {return -1.0}
    }
}
