//
//  TencentSystemMessageCell.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/29.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentSystemMessageCell: BaseView {
    
    @objc var mTitleLabel:UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configViewSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViewSystem() {
        self.backgroundColor = UIColor.clear
        mTitleLabel = UILabel.init(frame: CGRect(x:-50,y:10,width:kScreen_Width-40,height:13))
        mTitleLabel.textColor = UIColor.customGray
        mTitleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        mTitleLabel.textAlignment = NSTextAlignment.center
        self.addSubview(mTitleLabel)
    }
    
}
