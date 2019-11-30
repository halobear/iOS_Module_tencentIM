//
//  TencentIMMessage.m
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/28.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import "TencentIMMessage.h"

@implementation TencentIMMessage

-(instancetype)init{
    self = [super init];
    if (self) {
        _imMessageArr = [NSMutableArray array];
    }
    return self;
}

//重写isSelf
//- (void)setIsSelf:(BOOL)isSelf{
//    if (_isSelf != isSelf) {
//        _isSelf = isSelf;
//    }
//}

- (BOOL)isSelf{
    return _isSelf;
}

//重写时间
-(void)setTime:(long)time{
    if (_time != time) {
        _time = time;
    }
}

- (NSDate *)timestamp{
    return [NSDate dateWithTimeIntervalSince1970:_time];
}

- (TIMMessageStatus)status{
    return 2;
}

- (int)addElem:(TIMElem *)elem{
    [self.imMessageArr addObject:elem];
    return 0;
}

- (TIMElem *)getElem:(int)index{
    if (index > self.imMessageArr.count-1) {
        return nil;
    }
    return self.imMessageArr[index];
}

- (int)elemCount{
    int count = (int)self.imMessageArr.count;
    return count;
}

@end
