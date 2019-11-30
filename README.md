# TencentIM
在线聊天系统


# 初始化SDK

    Appdelegate：
    [[TencentManger sharedManger] initTencentSDK];


# 文件引用

Prefix.pch    
桥接文件

#import "TencentManger.h"


#  登录/退出IM

    [[TencentManger sharedManger] loginTencentIM];
    [[TencentManger sharedManger] loginOutTencentIm];


#  使用
    
    //是否显示卡片
    TencentManger.shared()?.isShowCard = true
    //卡片类型 hotel_card酒店 
    TencentManger.shared()?.cardType = "hotel_card"
    //卡片信息
    TencentManger.shared()?.card = (data as! [AnyHashable : Any])
    //自动发送的文字
    TencentManger.shared()?.automaticText = ""
    //开始聊天 客服类型：case_detail
    TencentManger.shared()?.beginChat(withType: "case_detail")
