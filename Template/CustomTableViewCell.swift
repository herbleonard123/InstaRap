//
//  CustomTableViewCell.swift
//  Template
//
//  Created by Mateo Garcia on 4/4/17.
//  Copyright © 2017 StreetCode. All rights reserved.
//

import UIKit

protocol CustomTableViewCellDelegate: class {
    
    func cellPlayVideo(forVideoUrl videoUrl: URL)
}

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    @IBOutlet weak var micCountLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    weak var delegate: CustomTableViewCellDelegate?
    var videourl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onPlayButton(_ sender: UIButton) {
        
        if let delegate = delegate, let videourlString = videourl, let videoUrl = URL(string: videourlString) {
            
            delegate.cellPlayVideo(forVideoUrl: videoUrl)
        }
    }
}
