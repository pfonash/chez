//
//  ViewController.swift
//  chez
//
//  Created by Fonash, Peter S on 7/9/18.
//  Copyright © 2018 Ente. All rights reserved.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var numberDisplay: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
    @IBOutlet var swipeDown: UISwipeGestureRecognizer!
    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet weak var wordsProgressView: UIProgressView!
    @IBOutlet weak var vocabImage: UIImageView!
    
    
    // MARK: IBActions
    @IBAction func handleSwipeRightGesture(_ sender: Any) {
        getNext()
    }
    @IBAction func handleSwipeDown(_ sender: UISwipeGestureRecognizer) {
        isRight = !isRight
    }
    
    // MARK: Global classes
    lazy var gcfsInterface = FirestoreInterface()    
    let words = Words()
    let wordsManager = WordManager()
    var dataFromGCFS = [[String: Any]]() {
        didSet {
            let downloadedWords = words.add(words: self.dataFromGCFS)
            let wordsToReview = downloadedWords.filter { wordsManager.isWordReady(word: $0) }
            words.setWordsToReview(words: wordsToReview)
            self.getNext()
        }
    }
    
    // MARK: Global vars
    let colorRight = #colorLiteral(red: 0, green: 0.6491959691, blue: 0.1914409697, alpha: 1).cgColor
    let colorWrong = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
    var currentLanguage = Language.english
    var isRight = true {
        didSet {
            drawLabelBorder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        wordLabel.layer.borderWidth = 2.0
        wordLabel.layer.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        wordLabel.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    private func setup() {
        setObservers()
        gcfsInterface.get(collection: Collection.all)
        getData()
        setTappers()
    }
    
    // MARK: UI functions
    func setTappers() {
        let labelTapper = UITapGestureRecognizer(
            target: self, action: #selector(ViewController.flipLabel)
        )
        wordLabel.isUserInteractionEnabled = true
        wordLabel.addGestureRecognizer(labelTapper)
        
        let imageTapper = UITapGestureRecognizer(target: self, action: #selector(ViewController.getNext))
        vocabImage.isUserInteractionEnabled = true
        vocabImage.addGestureRecognizer(imageTapper)
    }
    
    private func makeAttributedText() {
        
    }
    
    @objc func flipLabel(sender: UITapGestureRecognizer) {
        flip()
    }
    
    private func hideImage(imageView: UIImageView) {
        imageView.isHidden = true
    }
    
    // MARK: GCP download functions
    func getData() {
        gcfsInterface.db.collection(Collection.all.rawValue).getDocuments()
            { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.dataFromGCFS = querySnapshot!.documents.map {$0.data()}
                }
            }
    }
    
//    func download(reference: StorageReference) {
//        
//        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                // Data for "images/island.jpg" is returned
//                self.downloadedImage = UIImage(data: data!)
//            }
//        }
//    }
    
    private func drawLabelBorder() {
        if isRight {
            drawBorder(for: wordLabel, with: colorRight)
        }
        else {
            drawBorder(for: wordLabel, with: colorWrong)
        }
    }
    
    private func drawBorder(for label: UILabel, with color: CGColor) {
        label.layer.borderWidth = 2.0
        label.layer.borderColor = color
    }
    
    private func setLabels() {
        let word = self.words.currentWord
        
        if word.grammarUnit == .numeral {
            wordLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        else if word.grammarUnit == .pronunciation {
            wordLabel.textColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        }
        else {
            wordLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)            
        }
        
        switch currentLanguage {
        case .english:
            wordLabel.text = word.english
            moreLabel.text = ""
            sentenceLabel.text = ""
        case .french:
            wordLabel.text = word.french
            wordLabel.text = word.french
            sentenceLabel.text = word.sentence
            moreLabel.text = word.forMoreUILabel()
        }
    }
    
    private func sendReviewedWords(to collection: Collection) {
        gcfsInterface.update(collection: Collection.all, with: words.wordsReviewed)
        words.resetReviewedWords()
    }
    
    func flipCurrentLanguage(language: Language) {
        switch currentLanguage {
        case .english:
            currentLanguage = Language.french
        case .french:
            currentLanguage = Language.english
        }
    }
    
    private func flip() {
        flipCurrentLanguage(language: currentLanguage)
        setLabels()
    }
    
    @objc private func getNext() {
        hideImage(imageView: vocabImage)
        words.getNext(using: .forward, result: isRight)
        setCurrentLanguage()
        isRight = true
        setLabels()
        updateProgressBar()
        numberDisplay.text = "Word \(self.words.wordsToReview.count) / \(self.words.wordsDownloaded.count)"
    }
    
    private func setCurrentLanguage() {
        self.currentLanguage = self.words.setLanguage(for: self.words.currentWord)
    }
    
    private func setObservers() {
        
//        // When data is recieved from gcfs, move to next word
//        let _  = gcfsInterface.observe(\FirestoreInterface.data, options: .new) { interface, change in
//            print("yes")
//            self.getNext()
//        }
//
//        let _  = words.observe(\Words.currentWord, options: .new) { interface, change in
//            self.setCurrentLanguage()
//            print("yes")
//            self.set(label: self.wordLabel, with: self.words.currentWord)
//        }
        
        // When losing control, send reviewed words to GCP
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationWillTerminate(notification:)), name: NSNotification.Name.UIApplicationWillTerminate, object: app)
    }
    
    private func updateProgressBar() {
        
        let difference = self.words.wordsDownloaded.count - self.words.wordsToReview.count
        let progress = Float(difference) / Float(self.words.wordsDownloaded.count)
        wordsProgressView.setProgress(progress, animated: true)
    }
    
    @objc private func applicationWillResignActive(notification: NSNotification) {
        sendReviewedWords(to: Collection.all)
    }
    @objc private func applicationWillTerminate(notification: NSNotification) {
        sendReviewedWords(to: Collection.all)
    }
}
