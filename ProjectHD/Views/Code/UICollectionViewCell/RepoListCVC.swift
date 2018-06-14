//
//  RepoListCVC.swift
//  ProjectHD
//
//  Created by Stephen Muscarella on 6/13/18.
//  Copyright © 2018 Elite Development. All rights reserved.
//

import UIKit

class RepoListCVC: UICollectionViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var licenseLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    var repository: Repository!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = UIColor.white
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "RepoListCVC", bundle: nil)
    }
    
    func configureCell(repo: Repository) {
        repository = repo
        
        nameLbl.text = repo.name
        licenseLbl.text = repo.license ?? ""
        dateLbl.text = repo.created_at
        
        if let description = repo.description {
            
            descriptionLbl.text = description
            descriptionLbl.font = UIFont(name: "Verdana", size: 12.0)!
            
        } else {
            
            descriptionLbl.text = "No Description"
            descriptionLbl.font = UIFont(name: "Verdana-Italic", size: 12.0)!
        }
    }

}
