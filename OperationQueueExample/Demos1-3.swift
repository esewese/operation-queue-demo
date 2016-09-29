
//
//  Demos1-3.swift
//  OperationQueueExample
//
//  Created by Esko Vähämäki on 28/09/16.
//  Copyright © 2016 Tuxera. All rights reserved.
//

import UIKit


// MARK: BASE DEMO
//
// Operations on operation queue without subclassing Operation
extension DemoViewController {
    func baseDemo() {
        operationQueue.maxConcurrentOperationCount = 2
        self.activityIndicator.startAnimating()
        
        for imageView in imageViews() {
            
            // Adding operation with closure
            operationQueue.addOperation {
                if let url = URL(string: "https://placebeard.it/600/300") {
                    do {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    } catch {
                        print("Failed to load image for \(url)")
                    }
                }
            }
            
        }
        
        // Wait until all operations are finished and stop animating the activityIndicator
        DispatchQueue.global().async {
            [weak self] () in
            self?.operationQueue.waitUntilAllOperationsAreFinished()
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}





// MARK: PRIORITY DEMO
//
// Operations on operation queue with priorities

/// Loads an image from given URL and inserts it to given UIImageView
class ImageLoadOperation: Operation {
    let url: URL
    var image: UIImage?
    let imageView: UIImageView
    init(withURL: URL, forImageView: UIImageView) {
        url = withURL
        imageView = forImageView
        super.init()
    }
    override func main() {
        do {
            let data = try Data(contentsOf: url)
            // If cancelled don't do anything
            if isCancelled {
                return
            }
            image = UIImage(data: data)
            // Let's check again before we do another heavy task
            if isCancelled {
                return
            }
            DispatchQueue.main.sync {
                imageView.image = self.image
            }
        } catch {
            print("Failed to load image from: \(url)")
        }
    }
}

extension DemoViewController {
    func priorityDemo() {
        operationQueue.maxConcurrentOperationCount = 1
        self.activityIndicator.startAnimating()
        
        var operations = [Operation]()
        for (index, imageView) in imageViews().enumerated() {
            if let url = URL(string: "https://placebeard.it/600/300") {
                let operation = ImageLoadOperation(withURL: url, forImageView: imageView)
                if index > 1 {
                    operation.queuePriority = .high
                }
                operations.append(operation)
            }
        }
        
        DispatchQueue.global().async {
            [weak self] () in
            self?.operationQueue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}





// MARK: DEPENDENCY DEMO
//
// Operations on operation queue with dependencies
protocol ImageLoader {
    func getLoadedImage() -> UIImage?
}

extension ImageLoadOperation: ImageLoader {
    func getLoadedImage() -> UIImage? {
        return self.image
    }
}

class ImageEditOperation: Operation, ImageLoader {
    let effect: ImageEffectType
    let imageView: UIImageView
    var editedImage: UIImage?
    
    init(forImageView: UIImageView, withEffect: ImageEffectType) {
        imageView = forImageView
        effect = withEffect
        super.init()
        
    }
    
    func getLoadedImage() -> UIImage? {
        return editedImage
    }
    
    override func main() {
        if let loader = self.dependencies.first as? ImageLoader {
            if let sourceImage = loader.getLoadedImage() {
                if isCancelled {
                    return
                }
                editedImage = effect.produceFrom(image: sourceImage)
                if isCancelled {
                    return
                }
                DispatchQueue.main.sync {
                    [weak self] () in
                    self?.imageView.image = self?.editedImage
                }
            }
        }
    }
}

extension DemoViewController {
    
    func dependencyDemo() {
        operationQueue.maxConcurrentOperationCount = 4
        self.activityIndicator.startAnimating()
        
        // Let's create the operation and add the dependencies
        let operation1 = ImageLoadOperation(withURL: URL(string: "https://unsplash.it/600/300?image=18")!, forImageView: imageView1)
        
        let operation2 = ImageEditOperation(forImageView: imageView2, withEffect: .Blur(2.0, UIColor.red))
        operation2.addDependency(operation1)
        
        let operation3 = ImageEditOperation(forImageView: imageView3, withEffect: .dark)
        operation3.addDependency(operation1)
        
        let operation4 = ImageEditOperation(forImageView: imageView4, withEffect: .Blur(5.0, UIColor.yellow))
        operation4.addDependency(operation2)
        
        DispatchQueue.global().async {
            [weak self] () in
            self?.operationQueue.addOperations([operation1, operation2, operation3, operation4], waitUntilFinished: true)
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}
