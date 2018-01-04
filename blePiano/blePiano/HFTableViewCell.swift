//
//  HFTableViewCell.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/6/5.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit

class HFTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func addData(anyObject: AnyObject) -> CGFloat {
        return 60
    }

}
