//
//  WordManager.swift
//  chez
//
//  Created by Fonash, Peter S on 7/16/18.
//  Copyright © 2018 Ente. All rights reserved.
//

import Foundation

class WordManager {

    let calender = Calendar.current

    func isWordReady(word: FrenchWord) -> Bool {
        
        if word.score == 1 {
            return true
        } else {
            if let readyDate = calender.date(byAdding: .day, value: word.score.asInt, to: word.ldr.asDate) {
                return (readyDate < Date() || readyDate == Date() )                
            }
        }
        return true // If there's a problem processing above, just include the word for review
    }
}

extension NSDate: Comparable {
    
    public static func <(lhs: NSDate, rhs: NSDate) -> Bool {
        return lhs.compare(rhs as Date) == .orderedAscending
    }
    
    static func == (lhs: NSDate, rhs: NSDate) -> Bool {
        return lhs === rhs || lhs.compare(rhs as Date) == .orderedSame
    }
    
    var asDate: Date {
        return self as Date
    }
}

extension Float {
    var asInt: Int {
        return Int(self)
    }
}
