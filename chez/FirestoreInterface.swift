//
//  FirestoreInterface.swift
//  chez
//
//  Created by Fonash, Peter S on 7/10/18.
//  Copyright © 2018 Ente. All rights reserved.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

enum Collection: String {
    case all = "all-french-words"
    case ready = "french-words-ready-for-review"
}

class FirestoreStorageInterface {
    
    let storage = Storage.storage()
    
    func get(reference from: String) -> StorageReference {
        return self.storage.reference(forURL: from)
    }
}

@objc class FirestoreInterface: NSObject {
    
    let db = Firestore.firestore()
        
    @objc dynamic var data = [[String : Any]]()
    
    func update(collection: Collection, with reviewedFrenchWords: [FrenchWord]) {
        
        let batch = db.batch()
        for reviewedWord in reviewedFrenchWords {
            let wordRef = db.collection(collection.rawValue).document(reviewedWord.french)
            batch.updateData(reviewedWord.for_gcfs_update(), forDocument: wordRef)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
    
    func get(collection: Collection)  {
        db.collection(collection.rawValue).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.data = querySnapshot!.documents.map {$0.data()}
            }
        }
    }
}


