//
//  TencentGetVistorApi.swift
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/26.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

import Foundation

class TencentGetVistorApi: BaseManager {
    
    var mTrack_id:String!
    
    init(track_id:String) {
        super.init()
        mTrack_id = track_id
        self.paramsDic.setValue(mTrack_id, forKey: "track_id")
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
        return "/api/client/v1/visitor"
    }
    
}
