//
//  CloudQandATableViewController.swift
//  Pollster
//
//  Created by Younoussa Ousmane Abdou on 3/13/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import UIKit
import CloudKit

class CloudQandATableViewController: QandATableViewController {
    
    var ckQandARecord: CKRecord {
        get {
            
            if _ckQandARecord == nil {
                
                _ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
            }
            
            return _ckQandARecord!
        }
        set {
            
            _ckQandARecord = newValue
        }
    }
    
    private var _ckQandARecord: CKRecord? {
        didSet {
            let question = ckQandARecord[Cloud.Attribute.Question] as? String ?? ""
            let answers = ckQandARecord[Cloud.Attribute.Answers] as? String ?? ""
            qanda = QandA(question: question, answers: [answers])
            
            asking = ckQandARecord.wasCreatedByThisUser
        }
    }
    
    // MARK: - textView and iCloud saving
    
    private let database = CKContainer.default().publicCloudDatabase
    
    private func iCLoudUpdate() {
        
        if !qanda.question.isEmpty && !qanda.answers.isEmpty {
            
            ckQandARecord[Cloud.Attribute.Question] = qanda.question as CKRecordValue?
            ckQandARecord[Cloud.Attribute.Answers] = qanda.answers as CKRecordValue?
            iCloudSaveRecord(recordToSave: ckQandARecord)
        }
    }}

private func iCloudSaveRecord(recordToSave: CKRecord) {
    
    database.save(recordToSave) { (savedRecord, error) in
        
        if error?.code == CKErrorCode.ServerRecordChanged.rawValue {
            
            // ignore
        } else if error != nil {
            
            self.retryAfterError(error: error as NSError?, withSelector: #selector(self.retryAfterError(error:)))
        }
    }
}


private func retryAfterError(error: NSError?,  withSelector selector: Selector) {
    
    if let retryInterval = error?.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
        
        DispatchQueue.main.async {
            
            Timer.scheduledTimer(timeInterval: retryInterval, target: self, selector: selector, userInfo: nil, repeats: false)
        }
    }
}

func textViewDidEndEditing(_ textView: UITextView) {
    super.textViewDidEndEditing(textView)
    
    iCLoudUpdate()
}



// MARK: - View

func viewDidLoad() {
    super.viewDidLoad()
    
    // Otherwise It will show this
    //    ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
    
    // If you want to edit use this
    // asking = true
}
