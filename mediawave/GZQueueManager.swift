//
//  GZQueueManager.swift
//  mediawave
//
//  Created by George Zinyakov on 3/18/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZQueueManager {
    static var searchQueue:GZOperationQueue = GZOperationQueue()
}

class GZOperationQueue: NSOperationQueue {
    override func cancelAllOperations() {
        super.cancelAllOperations()
        print("operations in queue: \(self.operations)")
    }
    
    override func addOperation(op: NSOperation) {
        super.addOperation(op)
        print("operations in queue: \(self.operations)")
    }
}