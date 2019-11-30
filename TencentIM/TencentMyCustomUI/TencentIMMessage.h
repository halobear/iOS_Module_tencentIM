//
//  TencentIMMessage.h
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/28.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import <ImSDK/ImSDK.h>

@interface TencentIMMessage : TIMMessage

@property (nonatomic, strong) NSMutableArray *imMessageArr; // <>

@property (nonatomic, assign) BOOL isSelf;

@property (nonatomic, assign) long time;

@end

