import Foundation
import UIKit

class LoadingScreen: UITableView {
    
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLoadingScreen()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setLoadingScreen()
    }
    
    private func setLoadingScreen() {
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.startAnimating()
        
        
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        addSubview(loadingView)
        
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        spinner.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 0).isActive = true
        spinner.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 0).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 30).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        loadingLabel.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 0).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: spinner.trailingAnchor, constant: 0).isActive = true
        loadingLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        loadingLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
    }
    
    func removeLoadingScreen() {
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
        
    }
    
}
