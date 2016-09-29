//
//  CollectionOperationViewController.swift
//  OperationQueueExample
//
//  Created by Esko Vähämäki on 28/09/16.
//  Copyright © 2016 Tuxera. All rights reserved.
//

import UIKit

/// Operation that loads an UIImage for given Item
class AsyncImageLoadOperation: AsyncOperation {
    
    let item: Item
    var dataTask: URLSessionDataTask?
    let onComplete: (UIImage?) -> Void
    
    init(forItem: Item, execute: @escaping (UIImage?) -> Void) {
        item = forItem
        onComplete = execute
        super.init()
    }
    
    func endOperationWith(image: UIImage?) {
        if !isCancelled {
            onComplete(image)
            completeOperation()
        }
    }
    
    override func startOperation() {
        if let url = item.url() {
            dataTask = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                if let data = data {
                    let image = UIImage(data: data)
                    self?.endOperationWith(image: image)
                } else {
                    self?.endOperationWith(image: nil)
                }
                })
            dataTask?.resume()
        } else {
            endOperationWith(image: nil)
        }
    }
    
    override func cancelOperation() {
        dataTask?.cancel()
    }
}

class CollectionOperationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    var items = [(Item, Operation?)]()
    let imageLoadQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        imageLoadQueue.maxConcurrentOperationCount = 3
        imageLoadQueue.qualityOfService = .userInitiated
        
        // Let's create items for the UICollectionView
        items = Item.createItems(n: 500).map { (item) -> (Item, Operation?) in
            return (item, nil)
        }
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.imageView.image = nil
        return cell
    }
    
    /// When the cell will be displayed, we will create the operation to load the image
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Cell {
            let (item, operation) = items[indexPath.row]
            // Just in case we cancel the old operation
            operation?.cancel()
            weak var weakCell = cell
            let newOperation = AsyncImageLoadOperation(forItem: item, execute: { (image) in
                DispatchQueue.main.sync {
                    weakCell?.imageView.image = image
                }
            })
            // Add it to the operation queue to be executed
            imageLoadQueue.addOperation(newOperation)
            items[indexPath.row] = (item, newOperation)
        }
    }
    
    /// When the cell goes out of display, we cancel it
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < items.count {
            items[row].1?.cancel()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (self.collectionView.frame.size.width/2.0) - 5.0
        return CGSize(width: w, height: w)
    }
    
    @IBAction func doButtonPressed(_ sender: AnyObject) {
        NSLog("Amount of operations: \(imageLoadQueue.operationCount)")
        for operation in imageLoadQueue.operations {
            NSLog("Operation - \(operation) - cancelled: \(operation.isCancelled) - finished: \(operation.isFinished)")
        }
    }
}


