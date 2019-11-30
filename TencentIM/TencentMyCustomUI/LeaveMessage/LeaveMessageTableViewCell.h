//
//  LeaveMessageTableViewCell.h
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/27.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaveMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *fieldLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) void(^backInformation)(NSString *);

@end

