//
//  RepoListCVC.swift
//  ProjectHD
//
//  Created by Stephen Muscarella on 6/13/18.
//  Copyright © 2018 Elite Development. All rights reserved.
//

import UIKit

class RepoListCVC: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.addViewBackedBorder(side: .south, thickness: 1.0, color: UIColor.lightGray)
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "RepoListCVC", bundle: nil)
    }

}
