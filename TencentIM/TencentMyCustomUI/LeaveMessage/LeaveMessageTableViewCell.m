//
//  LeaveMessageTableViewCell.m
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/27.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import "LeaveMessageTableViewCell.h"

@interface LeaveMessageTableViewCell ()<UITextFieldDelegate>

@end

@implementation LeaveMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI {
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(20, 15, kScreen_Width-40, 50)];
    bgView.backgroundColor = kBackGroundColor_gray;
    bgView.layer.cornerRadius = 3;
    [self.contentView addSubview:bgView];
    
    self.textField = [[UITextField alloc] init];
    self.textField.frame = CGRectMake(30, 15, kScreen_Width-60, 50);
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.textField.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.textField];
    self.textField.tintColor = kColorRed;
    self.textField.delegate = self;
    
    [self.textField addTarget:self action:@selector(change:) forControlEvents:UIControlEventEditingChanged];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    return YES;
}

- (void)change: (UITextField *)textF {
    self.backInformation(textF.text);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

