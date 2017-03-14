//
//  CloudKitNotifications.swift
//  Pollster
//
//  Created by Younoussa Ousmane Abdou on 3/13/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import CloudKit

struct CloudKitNotifications {
    static let NotificationRecieved = "iCloudRemoteNotificationReceived"
    static let NotificationKey = "Notification"
}

struct Cloud {
    struct Entity {
        static let QandA = "QandA"
        static let Response = "Response"
    }
    struct Attribute {
        static let Question = "question"
        static let Answers = "answers"
        static let ChosenAnswer = "chosenAnswer"
        static let QandA = "qanda"
    }
}

extension CKRecord {
    var wasCreatedByThisUser: Bool {
        // is this really the right way to do this?
        // seems like this Bool property should be built in to CKRecord
        return (creatorUserRecordID == nil) || (creatorUserRecordID?.recordName == "_defaultOwner_")
    }
}

// New extension for Sorting handling icloudHandleSubscriptionNotification

extension CKRecord {
    var question: String {
        
        return self[Cloud.Attribute.Question] as? String ?? ""
    }
}
