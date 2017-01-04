//
//  ViewController.swift
//  bt13
//
//  Created by Unima-TD-04 on 1/4/17.
//  Copyright © 2017 Unima-TD-04. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: LoadingScreen!
    var download = DownloadImage(maxConcurrent: 10)
    var dicIdCategorie: [String: Int16] = [:]
    
    //MARK: fetched Results Controller Categorie
    lazy var fetchedResultsController: NSFetchedResultsController<Categorie> = {
        
        let mainCT = (UIApplication.shared.delegate as! AppDelegate).mainCT
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Categorie> = Categorie.fetchRequest()
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
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
    
    //MARK: fetched Results Controller Video
    lazy var fetchedVideoResultsController: NSFetchedResultsController<Video> = {
        
        let mainCT = (UIApplication.shared.delegate as! AppDelegate).mainCT
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // Create Fetched Results Controller
        let fetchedVideoResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainCT , sectionNameKeyPath: nil, cacheName: nil)
        fetchedVideoResultsController.delegate = self
        do {
            try fetchedVideoResultsController.performFetch()
        } catch {
            print("Error fetched results controller")
        }
        return fetchedVideoResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Categories"
        
        let Categorie = fetchedResultsController.fetchedObjects
        if Categorie?.count == 0 {
            getData(modifiedS: "0")
            getDataVideo(modifiedS: "0")
        }else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let getContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categorie")
            let sortD = NSSortDescriptor(key: "modified", ascending: true)
            fetchRequest.sortDescriptors = [sortD]
            
            do {
                let array2 = try getContext.fetch(fetchRequest) as! [Categorie]
                let modifiedMax = array2.last?.modified
                let es = modifiedMax?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                getData(modifiedS: es!)
                getDataVideo(modifiedS: es!)
            }catch{}
        }
        
        
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
    }
    
    //MARK: get Data categories
    func getData(modifiedS: String) {
        
        let urlString = "http://nikmesoft.com/apis/englishvideos-api/public/index_debug.php/v1/categories?last_updated=\(modifiedS)"
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
                
                let arr = jsonObj["categories"] as! [AnyObject]
                for json in arr {
                    
                    
                    let name = json["name"] as! String
                    let thumbnail = json["thumbnail"] as! String
                    let id = json["id"] as! Int16
                    let deleted = json["deleted"] as! Int16
                    let created = json["created"] as! String
                    let modified = json["modified"] as! String
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let mainCT = appDelegate.mainCT
                    let backgroundCT = appDelegate.backgroundCT
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categorie")
                    
                    backgroundCT.perform({
                        let predicate = NSPredicate(format: "id == %@", "\(id)")
                        fetchRequest.predicate = predicate
                        let fetched = try! backgroundCT.fetch(fetchRequest) as! [Categorie]
                        
                        if fetched.count == 0 {
                            
                            let video = Categorie(context: backgroundCT)
                            video.id = id
                            video.name = name
                            video.thumbnail = thumbnail
                            video.delete = deleted
                            video.created = created
                            video.modified = modified
                            
                        } else {
                            fetched.first?.name = name
                            fetched.first?.thumbnail = thumbnail
                            fetched.first?.delete = deleted
                            fetched.first?.created = created
                            fetched.first?.modified = modified
                        }
                        try! backgroundCT.save()
                        mainCT.perform({
                            try! mainCT.save()
                            appDelegate.writerCT.perform({
                                try! appDelegate.writerCT.save()
                            })
                        })
                    })
                }
            }
            OperationQueue.main.addOperation {
                self.tableView.removeLoadingScreen()
            }
        }).resume()
    }
    
    //MARK: get Data Video
    func getDataVideo(modifiedS: String) {
        
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
                    let mainCT = appDelegate.mainCT
                    let backgroundCT = appDelegate.backgroundCT
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
                    
                    backgroundCT.perform({
                        let predicate = NSPredicate(format: "id == %@", "\(id)")
                        fetchRequest.predicate = predicate
                        let fetched = try! backgroundCT.fetch(fetchRequest) as! [Video]
                        
                        if fetched.count == 0 {
                            
                            let video = Video(context: backgroundCT)
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
                        try! backgroundCT.save()
                        mainCT.perform({
                            try! mainCT.save()
                            appDelegate.writerCT.perform({
                                try! appDelegate.writerCT.save()
                            })
                        })
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
                
                configure(tableView.cellForRow(at: indexPath) as! CategoriesTableViewCell, at: indexPath)
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
    
    func configure(_ cell: CategoriesTableViewCell, at indexPath: IndexPath) {
        
        let categorie = fetchedResultsController.object(at: indexPath)
        cell.nameCategorie.text = categorie.name
        
        cell.videoCountCategorie.text = "\(dicIdCategorie["\(categorie.id)"])"
        download.downloadJsonWithTask(url: categorie.thumbnail!, indexPath: indexPath, callBack: { (returnIndexpath, image) -> Void in
            if indexPath == returnIndexpath {
                cell.imageCategorie.image = image
            }
        })
    }
}

//MARK: Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let categorie = fetchedResultsController.fetchedObjects else { return 0 }
        return categorie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CategoriesTableViewCell", owner: self, options: nil)?.first as! CategoriesTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
}

//MARK: Table View Delegate
extension ViewController: UITableViewDelegate {
    
}
