//
//  PictureFootprintTableViewCell.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class FootprintTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
