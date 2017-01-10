//
//  CategoriesTableViewCell.swift
//  bt13
//
//  Created by Unima-TD-04 on 1/4/17.
//  Copyright © 2017 Unima-TD-04. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTableViewCell: UITableViewCell, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var imageCategorie: UIImageView!
    @IBOutlet weak var nameCategorie: UILabel!
    @IBOutlet weak var videoCountCategorie: UILabel!
    
    var cell: Category! {
        didSet {
            nameCategorie.text = cell.name
            videoCountCategorie.text = String(describing: cell.videos!.count)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
