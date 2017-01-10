import Foundation
import UIKit


class DownloadImage : NSObject {
    let queue = OperationQueue()
    var cache = [String:Bool]()
    init(maxConcurrent : Int) {
        self.queue.maxConcurrentOperationCount = maxConcurrent
    }
    func downloadImage(url : String, indexPath : IndexPath, callBack : @escaping ((IndexPath, UIImage?) -> Void)) {
        if let image = getImage(url: url) {
            callBack(indexPath, image)
        } else {
            queue.addOperation {
                do {
                    let data = try Data(contentsOf: URL(string: url)!)
                    OperationQueue.main.addOperation {
                        let image = UIImage(data: data)
                        self.saveImageDocument(url: url, data: data as NSData)
                        callBack(indexPath,image)
                    }
                } catch {
                    print("not internet")
                }
                
            }
            
        }
    }
    
    
    func saveImageDocument(url: String, data : NSData){
        let fileManager = FileManager.default
        let imageString = url.md5()
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageString!)
        fileManager.createFile(atPath: paths as String, contents: data as Data, attributes: nil)
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func getImage(url: String) -> UIImage? {
        let fileManager = FileManager.default
        let imageString = url.md5()
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(imageString!)
        var image: UIImage? = nil
        
        if fileManager.fileExists(atPath: imagePAth){
            image = UIImage(contentsOfFile: imagePAth)
        }
        return image
    }
}


// MARK: MD5
extension String {
    
    func md5() -> String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize()
        
        return String(format: hash as String)
    }
}
