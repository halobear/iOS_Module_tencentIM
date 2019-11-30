//
//  LeaveMessageApi.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/31.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class LeaveMessageApi: BaseManager {
    
    var mName:String!
    var mPhone:String!
    var mContent:String!
    
    @objc init(name:String, phone:String, content:String) {
        super.init()
        mName = name
        mPhone = phone
        mContent = content
        self.paramsDic.setValue(mName, forKey: "name")
        self.paramsDic.setValue(mPhone, forKey: "phone")
        self.paramsDic.setValue(mContent, forKey: "content")
    }
    
    override func requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func requestArgument() -> Any? {
        return self.paramsDic
    }
    
    override func baseUrl() -> String {
        return YTKNetconfig.getCRMService()
    }
    
    override func requestUrl() -> String {
        return "/api/client/v1/leave/message"
    }
    
}
