import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: LoadingScreen!
    var download = DownloadImage(maxConcurrent: 10)
    weak var categoryID: Video!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: fetched Results Controller Category
    lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        
        let mainCT = self.appDelegate.mainCT
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Category"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        
        
        
        getDataCategory(modifiedS: getModifiedCategorie(), callback: { (checkCategorie) -> Void in
            if checkCategorie == true {
                
                self.getDataVideo(modifiedS: self.getModifiedVideo(),callback: {(checkVideo) -> Void in
                    if checkVideo == true {
                        self.tableView.removeLoadingScreen()
                    }
                })
            }
        })
        
    }
    
//    getModifiedCategorie(chooseClass: Category(), entityName: "Category")
    
    func getModifiedCategorie() -> String {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: true)]
        let array1 = try? self.appDelegate.mainCT.fetch(fetchRequest) as! [Category]
        
        if (array1?.count)! > 0 {
            let modifiedMax = array1?.last?.modified
            let es = modifiedMax?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return es!
        } else {
            return "0"
        }
    }
    
    func getModifiedVideo() -> String {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: true)]
        let array2 = try? self.appDelegate.mainCT.fetch(fetchRequest) as! [Video]
        
        
        
        if (array2?.count)! > 0 {
            let modifiedMax = array2?.last?.modified
            let es = modifiedMax?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return es!
        } else {
            return "0"
        }
    }
    
    
    
    //MARK: get Data categories
    func getDataCategory(modifiedS: String, callback: @escaping (Bool) -> Void) {
        
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
                
                self.tableView.removeLoadingScreen()
                
                let alertCategory = self.alert(view: self.view, message: "Check the connection Category")
                self.present(alertCategory, animated: true, completion: nil)
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
                    let created = json["created"] as! String
                    let modified = json["modified"] as! String
                    
                    
                    let mainCT = self.appDelegate.mainCT
                    let backgroundCT = self.appDelegate.backgroundCT
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
                    
                    backgroundCT.performAndWait({
                        let predicate = NSPredicate(format: "id == %@", "\(id)")
                        fetchRequest.predicate = predicate
                        let fetched = try! backgroundCT.fetch(fetchRequest) as! [Category]
                        
                        if fetched.count == 0 {
                            let categorie = Category(context: backgroundCT)
                            categorie.id = id
                            categorie.name = name
                            categorie.thumbnail = thumbnail
                            
                            categorie.created = created
                            categorie.modified = modified
                            
                            
                        } else {
                            fetched.first?.name = name
                            fetched.first?.thumbnail = thumbnail
                            fetched.first?.created = created
                            fetched.first?.modified = modified
                        }
                        try! backgroundCT.save()
                        mainCT.performAndWait({
                            try! mainCT.save()
                            self.appDelegate.writerCT.perform({
                                try! self.appDelegate.writerCT.save()
                                
                            })
                        })
                    })
                    
                }
                // call back
                callback(true)
                OperationQueue.main.addOperation {
                    self.tableView.removeLoadingScreen()
                }
            }
        }).resume()
        
    }
    
    //MARK: get Data Video
    func getDataVideo(modifiedS: String, callback: @escaping (Bool) -> Void) {
        
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
                
                let alertVideo = self.alert(view: self.view, message: "Check the connection Video")
                self.present(alertVideo, animated: true, completion: nil)
                
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
                    let created = json["created"] as! String
                    let modified = json["modified"] as! String
                    
                    
                    let mainCT = self.appDelegate.mainCT
                    let backgroundCT = self.appDelegate.backgroundCT
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
                    
                    backgroundCT.performAndWait({
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
                            video.delete = false
                            video.created = created
                            video.modified = modified
                            
                            let req:NSFetchRequest = Category.fetchRequest()
                            req.predicate = NSPredicate(format: "id == %ld", category_id)
                            let res = try! backgroundCT.fetch(req)
                            video.category = res[0]
                            
                        } else {
                            
                            fetched.first?.name = name
                            fetched.first?.category_id = category_id
                            fetched.first?.thumbnail = thumbnail
                            fetched.first?.link = link
                            fetched.first?.duration = Double(duration)
                            fetched.first?.number_of_views = number_of_views
                            
                            fetched.first?.created = created
                            fetched.first?.modified = modified
                            
                            
                            let req:NSFetchRequest = Category.fetchRequest()
                            req.predicate = NSPredicate(format: "id == %ld", category_id)
                            let res = try! backgroundCT.fetch(req)
                            fetched.first?.category = res[0]
                        }
                        do{
                            try backgroundCT.save()
                            mainCT.performAndWait({
                                try! mainCT.save()
                                self.appDelegate.writerCT.perform({
                                    try! self.appDelegate.writerCT.save()
                                    callback(true)
                                })
                            })
                        } catch{}
                        
                    })
                    
                }
            }
        }).resume()
    }
    
    func alert(view: UIView, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        return alertController
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
                configure(cell as! CategoriesTableViewCell, at: indexPath)
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
    
    func configure(_ cell: CategoriesTableViewCell, at indexPath: IndexPath) {
        
        let categorie = fetchedResultsController.object(at: indexPath)
        
        cell.cell = categorie
        
        download.downloadImage(url: categorie.thumbnail!, indexPath: indexPath, callBack: { (returnIndexpath, image) -> Void in
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVideo = VideoViewController(nibName: "VideoViewController", bundle: nil)
        self.navigationController?.pushViewController(detailVideo, animated: true)
        let categorie = fetchedResultsController.object(at: indexPath)
        detailVideo.idCategory = categorie.id
        detailVideo.nameCategory = categorie.name
    }
}
