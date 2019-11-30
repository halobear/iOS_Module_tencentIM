//
//  TencentCardMessageCell.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/29.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentCardMessageCell: BaseView {
    
    @objc var mImageView:UIImageView!
    @objc var mTitleLabel:UILabel!
    @objc var mDesclabel:UILabel!
    @objc var mPriceLabel:UILabel!
    
    typealias CardClickBlock = () ->()
    @objc var cardClickBlock:CardClickBlock!
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configView()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cardAction))
        self.addGestureRecognizer(tap)
        
    }
    
    @objc func cardAction() {
        if cardClickBlock != nil {
            cardClickBlock()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        
//        self.layer.cornerRadius = 3
//        self.backgroundColor = UIColor.white
        
        mImageView = UIImageView.init(frame: CGRect(x:0,y:0,width:215,height:160))
        mImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mImageView.layer.masksToBounds = true
        mImageView.layer.cornerRadius = 3
        self.addSubview(mImageView)
        
        mTitleLabel = UILabel.init(frame: CGRect(x:mImageView.left,y:mImageView.bottom+14,width:mImageView.width,height:16))
        mTitleLabel.textColor = UIColor.white
        mTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(mTitleLabel)
        
        mDesclabel = UILabel.init(frame: CGRect(x:mImageView.left,y:mTitleLabel.bottom+8,width:mImageView.width,height:11))
        mDesclabel.textColor = UIColor.white
        mDesclabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(mDesclabel)
        
        mPriceLabel = UILabel.init(frame: CGRect(x:mImageView.left,y:mDesclabel.bottom+12,width:mDesclabel.width,height:16))
        mPriceLabel.textColor = UIColor.white
        mPriceLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(mPriceLabel)
        
    }
    
}
