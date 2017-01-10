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
    var idCategory : Int16?
    var nameCategory : String?
    
    //MARK: fetched Results Controller
    
    var fetchedResultsController: NSFetchedResultsController<Video>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = nameCategory!
        
        fetchedResultsController = fetchRQControll(by: "id", ascending: true)
        
        
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
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            break
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func configure(_ cell: VideoTableViewCell, at indexPath: IndexPath) {
        
        let video = fetchedResultsController?.object(at: indexPath)
        
        
        cell.nameCell.text = video?.name
        cell.personViewCell.text = "\((video?.number_of_views)!)"
        download.downloadImage(url: (video?.thumbnail!)!, indexPath: indexPath, callBack: { (returnIndexpath, image) -> Void in
            if indexPath == returnIndexpath {
                cell.imageCell.image = image
            }
        })
        
    }
    
    @IBAction func SortName(_ sender: UIButton) {
        
        fetchedResultsController = fetchRQControll(by: "name", ascending: true)
        self.tableView.reloadData()
    }
    
    @IBAction func SortNumber(_ sender: UIButton) {
        fetchedResultsController = fetchRQControll(by: "number_of_views", ascending: false)
        self.tableView.reloadData()
    }
    
    @IBAction func SortCreated(_ sender: UIButton) {
        fetchedResultsController = fetchRQControll(by: "created", ascending: true)
        self.tableView.reloadData()
    }
    
    func fetchRQControll(by: String, ascending: Bool) -> NSFetchedResultsController<Video> {
        var fetchedResultsController: NSFetchedResultsController<Video>
        let mainCT = (UIApplication.shared.delegate as! AppDelegate).mainCT
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: " (delete == false) AND category_id == %ld", self.idCategory!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: by, ascending: ascending)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainCT , sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetched results controller")
        }
        return fetchedResultsController
    }
    
    
}

extension VideoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let video = fetchedResultsController?.fetchedObjects else { return 0 }
        return video.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("VideoTableViewCell", owner: self, options: nil)?.first as! VideoTableViewCell
        configure(cell, at: indexPath)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
            
            let videos = fetchedResultsController?.object(at: indexPath)
            appDelegate.backgroundCT.perform {
                videos?.setValue(true, forKey: "delete")
                videos?.category = nil
                try! appDelegate.backgroundCT.save()
                appDelegate.mainCT.perform({
                    try! appDelegate.mainCT.save()
                    appDelegate.writerCT.perform({
                        try! appDelegate.writerCT.save()
                    })
                })
            }
        }
    }
}
