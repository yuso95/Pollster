//
//  AllQandAsTableViewController.swift
//  Pollster
//
//  Created by Younoussa Ousmane Abdou on 3/14/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import UIKit
import CloudKit

class AllQandAsTableViewController: UITableViewController {

    var allQandAs = [CKRecord]() {
        didSet {
            
            tableView.reloadData()
        }
    }
    
    // MARK: - View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllQuandAs()
        iCloudSubcribeToQanAs()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        iCloudUnSubcribeToQanAs()
    }
    
    private let database = CKContainer.default().publicCloudDatabase
    
    private func fetchAllQuandAs() {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: Cloud.Entity.QandA, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: Cloud.Attribute.Question, ascending: true)]
        database.perform(query, inZoneWith: nil) { (records, error) in
            
            if records != nil {
                DispatchQueue.main.async {
                    
                    self.allQandAs = records!
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allQandAs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QandAs Cell", for: indexPath)
        cell.textLabel?.text = allQandAs[indexPath.row].question
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show QandA" {
            if let ckQandATVC = segue.destination as? CloudQandATableViewController {
                if let cell = sender as? UITableViewCell, let IndexPath = tableView.indexPath(for: cell) {
                    
                    ckQandATVC.ckQandARecord = allQandAs[IndexPath.row]
                } else {
                    
                    ckQandATVC.ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
                }
            }
        }
    }
    
    // MARK: - Editing TableViewDataSource
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return allQandAs[indexPath.row].wasCreatedByThisUser
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let record = allQandAs[indexPath.row]
            database.delete(withRecordZoneID: record.recordID, completionHandler: { (deletedRecord, error) in
                
                // Handle erros
            })
            
            allQandAs.remove(at: indexPath.row)
        }
    }
    
    // MARK: - Subcription
    
    private let subcriptionID = "All QandA Creations and Deletions"
    private var cloudKitObserver: NSObjectProtocol?
    
    private func iCloudSubcribeToQanAs() {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subcription = CKSubscription(recordType: Cloud.Entity.QandA, predicate: predicate, subscriptionID: self.subcriptionID, options: [.firesOnRecordCreation, .firesOnRecordDeletion])
        
        // subscription.notificationInfo = ... 
        // If you want to set ut the push notification
        
        database.save(subcription) { (savedSubcription, error) in
            if error?.code == CKError.serverRejectedRequest.rawValue {
                
                // ignore
            } else if error != nil {
                
                // report
            }
        }
        
        cloudKitObserver = NotificationCenter.default.addObserverForName(CloudKitNotifications.NotificationRecieved, object: nil, queue: DispatchQueue.main, usingBlock: { (notification) in
            
            if let ckqn = Notification.userInfo?[CloudKitNotifications.NotificationRecieved] as? CKQueryNotification
            self.icloudHandleSubscriptionNotification(ckqn)
        })
    }
    
    private func icloudHandleSubscriptionNotification() {
        
        if ckqn.subscription == self.subcriptionID {
            let recordID = ckqn.recordID {
                
                switch ckqn.queryNotificationReason {
                case .RecordCreated:
                    
                    database.fetch(withRecordID: recordID, completionHandler: { (record, error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                
                                self.allQandAs = (self.allQandAs + [record!]).sort {
                                    
                                    return ($0.question as? String) < ($1.question)
                                }
                            }
                        }
                    })
                case RecoderDeleted:
                    DispatchQueue.main.async {
                        
                        self.allQandAs = self.allQandAs.filter { $0.recordID != recordID }
                            
                        }
                        
                        
                    }
                
                default:
                    break
                }
            }
        }
    }
    
    private func iCloudUnSubcribeToQanAs() {
     
        database.delete(withSubscriptionID: self.subcriptionID) { (subscription, error) in
            
            // Handle it
        }
    }
}
