//
//  TencentBeginChatApi.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/27.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentBeginChatApi: BaseManager {
    
    var mGroup_id:String!
    var mAgent_id:String!
    
    @objc init(group_id:String,agent_id:String) {
        super.init()
        mGroup_id = group_id
        mAgent_id = agent_id
        self.paramsDic.setValue(mGroup_id, forKey: "group_id")
        if mAgent_id.count != 0 {
            self.paramsDic.setValue(mAgent_id, forKey: "agent_id")
        }
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
        return "/api/client/v1/chat/conversation"
    }
    
}
