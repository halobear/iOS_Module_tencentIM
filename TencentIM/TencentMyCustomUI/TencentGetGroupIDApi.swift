//
//  TencentGetGroupIDApi.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/29.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentGetGroupIDApi: BaseManager {
    
    override func requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func requestArgument() -> Any? {
        return self.paramsDic
    }
    
    override func requestUrl() -> String {
        return "/api/app-licheng/v1/agent"
    }
    
}
