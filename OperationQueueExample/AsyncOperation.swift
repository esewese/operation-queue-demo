//
//  AsyncOperation.swift
//  OperationQueueExample
//
//  Created by Esko Vähämäki on 26/09/16.
//  Copyright © 2016 Tuxera. All rights reserved.
//

import Foundation

/// Subclass of Operation that can have asynchronous implementation
/// startOperation and cancellOperation methods should be implemented in subclass
class AsyncOperation: Operation {
    open override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    override open var isExecuting : Bool {
        get { return _executing }
        set {
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _executing : Bool = false
    
    override open var isFinished : Bool {
        get { return _finished }
        set {
            if newValue != _finished {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    fileprivate var _finished : Bool = false
    
    open override func start() {
        if !isCancelled {
            isExecuting = true
            isFinished = false
            startOperation()
        } else {
            isFinished = true
        }
    }
    
    open override func cancel() {
        if !isCancelled {
            cancelOperation()
        }
        super.cancel()
        completeOperation()
    }
    
    /// Call when operation is finished
    open func completeOperation() {
        if isExecuting && !isFinished {
            isExecuting = false
            isFinished = true
        }
    }
    
    // MARK: Implement in subclass
    /// Should start the "task"
    open func startOperation() {
        completeOperation()
    }
    
    /// Should end the execution of the "task"
    open func cancelOperation() {
        
    }
}
