//
//  TencentGetUnReadApi.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/31.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentGetUnReadApi: BaseManager {
    
    override init() {
        super.init()
    }
    
    override func requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func baseUrl() -> String {
        return YTKNetconfig.getCRMService()
    }
    
    override func requestUrl() -> String {
        return "/api/client/v1/chat/unread"
    }
    
}
