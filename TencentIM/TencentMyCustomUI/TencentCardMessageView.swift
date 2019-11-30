//
//  TencentCardMessageView.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/28.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentCardMessageView: BaseView {
    
    var mImageView:UIImageView!
    var mTitleLabel:UILabel!
    var mDesclabel:UILabel!
    var mPriceLabel:UILabel!
    var mCloseBtn:UIButton!
    var mSendBtn:UIButton!
    
    typealias CardSendBlock = () ->()
    @objc var cardSendBlock:CardSendBlock!
    
    typealias CardCloseBlock = () ->()
    @objc var cardCloseBlock:CardCloseBlock!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        
        self.backgroundColor = UIColor.white
        
        mImageView = UIImageView.init(frame: CGRect(x:16,y:16,width:90,height:60))
        mImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mImageView.layer.masksToBounds = true
        self.addSubview(mImageView)
        mImageView.backgroundColor = UIColor.white
        
        mTitleLabel = UILabel.init(frame: CGRect(x:mImageView.right+11,y:17,width:kScreen_Width-mImageView.right-50,height:14))
        mTitleLabel.textColor = UIColor.customBlack
        mTitleLabel.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(mTitleLabel)
        
        mDesclabel = UILabel.init(frame: CGRect(x:mImageView.right+11,y:mTitleLabel.bottom+9,width:kScreen_Width-mImageView.right-15,height:12))
        mDesclabel.textColor = UIColor.customGray
        mDesclabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(mDesclabel)
        
        mPriceLabel = UILabel.init(frame: CGRect(x:mImageView.right+11,y:mImageView.bottom-16,width:mDesclabel.width,height:16))
        mPriceLabel.textColor = UIColor.customRed
        mPriceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(mPriceLabel)
        
        mSendBtn = UIButton.init(frame: CGRect(x:kScreen_Width/2-60,y:self.height-15-27,width:120,height:27))
        mSendBtn.layer.cornerRadius = 27/2
        mSendBtn.layer.borderColor = UIColor.customRed.cgColor
        mSendBtn.layer.borderWidth = 1
        mSendBtn.setTitle("发送", for: UIControl.State.normal)
        mSendBtn.setTitleColor(UIColor.customRed, for: UIControl.State.normal)
        mSendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(mSendBtn)
        mSendBtn.addTarget(self, action: #selector(sendClick), for:UIControl.Event.touchUpInside)
        
        let image = UIImage.init(named: "card_close")
        mCloseBtn = UIButton.init(frame: CGRect(x:kScreen_Width-30-(image?.size.width)!,y:0,width:30+(image?.size.width)!,height:30+(image?.size.height)!))
        mCloseBtn.setImage(image, for: UIControl.State.normal)
        mCloseBtn.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.addSubview(mCloseBtn)
        mCloseBtn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc func sendClick() {
        if cardSendBlock != nil {
            cardSendBlock()
        }
    }
    
    @objc func closeClick() {
        self.removeFromSuperview()
        if cardCloseBlock != nil {
            cardCloseBlock()
        }
    }
    
    @objc func configData(){
        if TencentManger.shared()?.isShowCard==true {
            let dic = TencentManger.shared()?.card! as! NSDictionary
            mImageView?.setProgressImageURL(URL(string: dic.object(forKey: "cover") as! String), withPlaceholder: UIImage.init(named: img_placeholder), options: YYWebImageOptions(rawValue: YYWebImageOptions.setImageWithFadeAnimation.rawValue | YYWebImageOptions.progressiveBlur.rawValue | YYWebImageOptions.showNetworkActivity.rawValue)) { (image, url, from, stage, error) in  }
            mTitleLabel.text = (dic.object(forKey: "title") as! String)
            mDesclabel.text = (dic.object(forKey: "subtitle") as! String)
            mPriceLabel.text = (dic.object(forKey: "price") as! String)
        }
    }
    
}
