//
//  VideoViewController.swift
//  bt13
//
//  Created by Unima-TD-04 on 1/4/17.
//  Copyright © 2017 Unima-TD-04. All rights reserved.
//

import UIKit
import CoreData

class VideoViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var download = DownloadImage(maxConcurrent: 10)
    
    //MARK: fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Video> = {
        
        let mainCT = (UIApplication.shared.delegate as! AppDelegate).mainCT
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainCT , sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetched results controller")
        }
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Video"
        
        
        tableView.dataSource = self
    }
    

    
    
    
    //MARK: Controller
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexpath = newIndexPath {
                tableView.insertRows(at: [indexpath], with: .automatic)
            }
            break
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configure(cell as! VideoTableViewCell, at: indexPath)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            break
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let indexPath = indexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            break
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func configure(_ cell: VideoTableViewCell, at indexPath: IndexPath) {
        // Fetch
        let video = fetchedResultsController.object(at: indexPath)
        cell.nameCell.text = video.name
        cell.personViewCell.text = "\(video.number_of_views)"
        download.downloadJsonWithTask(url: video.thumbnail!, indexPath: indexPath, callBack: { (returnIndexpath, image) -> Void in
            if indexPath == returnIndexpath {
                cell.imageCell.image = image
            }
        })
        
    }
}

extension VideoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let video = fetchedResultsController.fetchedObjects else { return 0 }
        return video.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("VideoTableViewCell", owner: self, options: nil)?.first as! VideoTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var fetch = fetchedResultsController.fetchedObjects! as [Video]
            fetch.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            ///
        }
    }
}
