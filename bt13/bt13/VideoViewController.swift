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
        
        let video = fetchedResultsController.fetchedObjects
        if video?.count == 0 {
            getData(modifiedS: "0")
        }else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let getContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
            let sortD = NSSortDescriptor(key: "modified", ascending: true)
            fetchRequest.sortDescriptors = [sortD]
            
            do {
                let array2 = try getContext.fetch(fetchRequest) as! [Video]
                let modifiedMax = array2.last?.modified
                let es = modifiedMax?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                getData(modifiedS: es!)
            }catch{}
        }
        
        tableView.dataSource = self
    }
    
    //MARK: get Data
    func getData(modifiedS: String) {
        
        let urlString = "http://nikmesoft.com/apis/englishvideos-api/public/index_debug.php/v1/videos?last_updated=\(modifiedS)"
        guard let url = NSURL(string: urlString) else {
            print("Error url")
            return
        }
        
        let urlRequest = URLRequest(url: url as URL )
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        
        session.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            if error != nil {
                return
            }
            do {
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data!) as! [String : AnyObject] else {
                    return
                }
                
                let arr = jsonObj["videos"] as! [AnyObject]
                for json in arr {
                    
                    let id = json["id"] as! Int16
                    let name = json["name"] as! String
                    let category_id = json["category_id"] as! Int16
                    let thumbnail = json["thumbnail"] as! String
                    let link = json["link"] as! String
                    let duration = json["duration"] as! Int16
                    let number_of_views = json["number_of_views"] as! Int16
                    let deleted = json["deleted"] as! Int16
                    let created = json["created"] as! String
                    let modified = json["modified"] as! String
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let getContext = appDelegate.persistentContainer.viewContext
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
                    let ct = appDelegate.backgroundCT
                    ct.perform ({
                        let predicate = NSPredicate(format: "id == %@", "\(id)")
                        fetchRequest.predicate = predicate
                        let fetched = try! getContext.fetch(fetchRequest) as! [Video]
                        
                        if fetched.count == 0 {
                            
                            let video = Video(context: getContext)
                            video.id = id
                            video.name = name
                            video.category_id = category_id
                            video.thumbnail = thumbnail
                            video.link = link
                            video.duration = Double(duration)
                            video.number_of_views = number_of_views
                            video.delete = deleted
                            video.created = created
                            video.modified = modified
                            
                        } else {
                            
                            fetched.first?.name = name
                            fetched.first?.category_id = category_id
                            fetched.first?.thumbnail = thumbnail
                            fetched.first?.link = link
                            fetched.first?.duration = Double(duration)
                            fetched.first?.number_of_views = number_of_views
                            fetched.first?.delete = deleted
                            fetched.first?.created = created
                            fetched.first?.modified = modified
                            
                        }
                        
                        try! ct.save()
                        
                        
                    })
                }
                
                
            }
            
        }).resume()
    }
    
    
    
    //MARK: Controller
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexpath = newIndexPath {
                tableView.insertRows(at: [indexpath], with: .automatic)
            }
            break
        case NSFetchedResultsChangeType.update:
            if let indexPath = indexPath {
                
                configure(tableView.cellForRow(at: indexPath) as! VideoTableViewCell, at: indexPath)
            }
        default:
            print("No Controller")
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
}
