//
//  TencentGetChatRecordApi.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/27.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentGetChatRecordApi: BaseManager {
    
    var mConversation_id:String!
    
    @objc init(conversation_id:String) {
        super.init()
        mConversation_id = conversation_id
        self.paramsDic.setValue(mConversation_id, forKey: "conversation_id")
    }
    
    override func requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func baseUrl() -> String {
        return YTKNetconfig.getCRMService()
    }
    
    override func requestArgument() -> Any? {
        return ["conversation_id":mConversation_id]
    }
    
    override func requestUrl() -> String {
        return "/api/client/v1/chat/record"
    }
    
}
