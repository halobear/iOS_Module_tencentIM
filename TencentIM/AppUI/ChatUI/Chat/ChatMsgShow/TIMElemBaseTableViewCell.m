//
//  TIMElemBaseTableViewCell.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/8.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TIMElemBaseTableViewCell.h"

@implementation TIMElemBaseTableViewCell

- (void)dealloc
{
    [_msgKVO unobserveAll];
//    DebugLog(@"[%@] relase", [self class]);
}

+ (UIFont *)defaultNameFont
{
    return kIMASmallTextFont;
}
+ (UIFont *)defaultTextFont
{
    return kIMAMiddleTextFont;
}

- (BOOL)canBecomeFirstResponder
{
    return [self canShowMenu];
}

- (BOOL)canShowMenu
{
    return YES;
}

- (BOOL)canShowMenuOnTouchOf:(UIGestureRecognizer *)ges
{
    CGPoint p = [ges locationInView:_contentBack];
    BOOL contain = CGRectContainsPoint(_contentBack.bounds, p);
    return contain;
}

- (instancetype)initWithC2CReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        self.contentView.backgroundColor = kClearColor;
        self.backgroundColor = kClearColor;
        _cellStyle = TIMElemCell_C2C;
        [self addC2CCellViews];

    }
    return self;
}
- (instancetype)initWithGroupReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super init])
    {
        self.contentView.backgroundColor = kClearColor;
        self.backgroundColor = kClearColor;
        _cellStyle = TIMElemCell_Group;
        [self addGroupCellViews];

    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    _pickedViewRef.hidden = !editing;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    switch (_cellStyle)
    {
        case TIMElemCell_C2C:
        {
            [self relayoutC2CCellViews];
        }
            break;
        case TIMElemCell_Group:
        {
            [self relayoutGroupCellViews];
        }
            break;
        default:
            break;
    }
}


- (void)addC2CCellViews
{
    _icon = [[UIButton alloc] init];
    _icon.layer.cornerRadius = 20;
    _icon.layer.masksToBounds = YES;
    [self.contentView addSubview:_icon];
    _icon.backgroundColor = UIColor.whiteColor;
    
    _contentBack = [[UIImageView alloc] init];
    _contentBack.userInteractionEnabled = YES;
    [self.contentView addSubview:_contentBack];
    _elemContentRef = [self addElemContent];
    if (_elemContentRef)
    {
        [_contentBack addSubview:_elemContentRef];
    }
    
    _sendingTipRef = [self addSendingTips];
    if (_sendingTipRef)
    {
        [self.contentView addSubview:_sendingTipRef];
    }
    
    _pickedViewRef = [self addPickedView];
    if (_pickedViewRef)
    {
        _pickedViewRef.hidden = YES;
        [self.contentView addSubview:_sendingTipRef];
    }
    
}

// 只创建，外部统一添加
- (UIView *)addElemContent
{
    return nil;
}


// 只创建，外部统一添加
- (UIView<TIMElemSendingAbleView> *)addSendingTips
{
    return nil;
}

// 只创建，外部统一添加
- (UIView *)addPickedView
{
    return nil;
}


- (void)addGroupCellViews
{
    [self addC2CCellViews];
    
    _remarkTip = [[UILabel alloc] init];
    _remarkTip.textColor = kLightGrayColor;
    _remarkTip.font = [TIMElemBaseTableViewCell defaultNameFont];
    [self.contentView addSubview:_remarkTip];
}

- (void)relayoutC2CCellViews
{
    CGRect rect = self.contentView.bounds;
    NSInteger hor = [_msg horMargin];
    NSInteger ver = kDefaultMargin/2;
    if ([_msg isMineMsg])
    {
        if (self.isEditing)
        {
            if (_pickedViewRef)
            {
                [_pickedViewRef sizeWith:CGSizeMake([_msg pickedViewWidth], rect.size.height)];
                [_pickedViewRef alignParentLeftWithMargin:hor];
                [_pickedViewRef relayoutFrameOfSubViews];
            }
        }
        
        [_icon sizeWith:[_msg userIconSize]];
        [_icon alignParentRightWithMargin:hor];
        [_icon alignParentBottomWithMarginAratar:ver];
        
        CGSize contentBackSize = [_msg contentBackSizeInWidth:rect.size.width];
        [_contentBack sizeWith:contentBackSize];
        [_contentBack layoutToLeftOf:_icon margin:hor];
        [_contentBack alignParentBottomWithMarginAratar:ver];
        
        
        UIEdgeInsets inset = [_msg contentBackInset];
        contentBackSize.width -= inset.left + inset.right;
        contentBackSize.height -= inset.top + inset.bottom;
        
        if (_elemContentRef)
        {
            [_elemContentRef sizeWith:contentBackSize];
            [_elemContentRef alignParentLeftWithMargin:inset.left];
            [_elemContentRef alignParentTopWithMargin:inset.top];
            [_elemContentRef relayoutFrameOfSubViews];
        }
        
        if (_sendingTipRef)
        {
            NSInteger width = [_msg sendingTipWidth];
            [_sendingTipRef sizeWith:CGSizeMake(width, rect.size.height)];
            [_sendingTipRef layoutToLeftOf:_contentBack margin:hor];
            [_sendingTipRef relayoutFrameOfSubViews];
        }
    }
    else
    {
        // 对方的C2C消息
        
        [_icon sizeWith:[_msg userIconSize]];
        [_icon alignParentTopWithMargin:ver];
        
        if (_pickedViewRef && !_pickedViewRef.hidden)
        {
            [_pickedViewRef sizeWith:CGSizeMake([_msg pickedViewWidth], rect.size.height)];
            [_pickedViewRef alignParentLeftWithMargin:hor];
            [_pickedViewRef relayoutFrameOfSubViews];
            
            [_icon layoutToRightOf:_pickedViewRef margin:hor];
        }
        else
        {
            [_icon alignParentLeftWithMargin:hor];
        }
        
        CGSize contentBackSize = [_msg contentBackSizeInWidth:rect.size.width];
        [_contentBack sizeWith:contentBackSize];
        [_contentBack layoutToRightOf:_icon margin:hor];
        [_contentBack alignTop:_icon];
        
        
        UIEdgeInsets inset = [_msg contentBackInset];
        contentBackSize.width -= inset.left + inset.right;
        contentBackSize.height -= inset.top + inset.bottom;
        
        if (_elemContentRef)
        {
            [_elemContentRef sizeWith:contentBackSize];
            [_elemContentRef alignParentLeftWithMargin:inset.left];
            [_elemContentRef alignParentTopWithMargin:inset.top];
            [_elemContentRef relayoutFrameOfSubViews];
        }
        
        if (_sendingTipRef)
        {
            //            _sendingTipRef.hidden = YES;
            NSInteger width = [_msg sendingTipWidth];
            [_sendingTipRef sizeWith:CGSizeMake(width, rect.size.height)];
            [_sendingTipRef layoutToRightOf:_contentBack margin:hor];
            [_sendingTipRef relayoutFrameOfSubViews];
        }
        
    }
}
- (void)relayoutGroupCellViews
{
    CGRect rect = self.contentView.bounds;
    NSInteger hor = [_msg horMargin];
    NSInteger ver = kDefaultMargin/2;
    if ([_msg isMineMsg])
    {
        // 与C2C消息一致
        [self relayoutC2CCellViews];
    }
    else
    {
        // 对方的Group消息
        [_icon sizeWith:[_msg userIconSize]];
        [_icon alignParentTopWithMargin:ver];
        
        if (_pickedViewRef && !_pickedViewRef.hidden)
        {
            [_pickedViewRef sizeWith:CGSizeMake([_msg pickedViewWidth], rect.size.height)];
            [_pickedViewRef alignParentLeftWithMargin:hor];
            [_pickedViewRef relayoutFrameOfSubViews];
            
            [_icon layoutToRightOf:_pickedViewRef margin:hor];
        }
        else
        {
            [_icon alignParentLeftWithMargin:hor];
        }
        
        [_remarkTip sizeWith:CGSizeMake(rect.size.width, [_msg groupMsgTipHeight])];
        [_remarkTip alignTop:_icon];
        [_remarkTip layoutToRightOf:_icon margin:hor];
        [_remarkTip scaleToParentRightWithMargin:hor];
        
        CGSize contentBackSize = [_msg contentBackSizeInWidth:rect.size.width];
        [_contentBack sizeWith:contentBackSize];
        [_contentBack layoutToRightOf:_icon margin:hor];
        [_contentBack layoutBelow:_remarkTip];
        [_contentBack alignParentBottomWithMarginAratar:ver];
        
        
        UIEdgeInsets inset = [_msg contentBackInset];
        contentBackSize.width -= inset.left + inset.right;
        contentBackSize.height -= inset.top + inset.bottom;
        
        if (_elemContentRef)
        {
            [_elemContentRef sizeWith:contentBackSize];
            [_elemContentRef alignParentLeftWithMargin:inset.left];
            [_elemContentRef alignParentTopWithMargin:inset.top];
            [_elemContentRef relayoutFrameOfSubViews];
        }
        
        if (_sendingTipRef)
        {
            _sendingTipRef.hidden = YES;
            NSInteger width = [_msg sendingTipWidth];
            [_sendingTipRef sizeWith:CGSizeMake(width, rect.size.height)];
            [_sendingTipRef layoutToRightOf:_contentBack margin:hor];
            [_sendingTipRef relayoutFrameOfSubViews];
        }
        
    }
}

- (void)configKVO
{
    [_msgKVO unobserveAll];
    
    if ([_msg isMineMsg])
    {
        __weak TIMElemBaseTableViewCell *ws = self;
        if (!_msgKVO)
        {
            _msgKVO = [FBKVOController controllerWithObserver:self];
        }
        [_msgKVO observe:_msg keyPath:@"status" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            [ws configSendingTips];
        }];
    }
    else
    {
        _msgKVO = nil;
    }
    
    
}

- (void)configWith:(IMAMsg *)msg
{
    _msg = msg;
    
    [self configKVO];
    
    IMAUser *user = nil;
    if ([_msg isMineMsg])
    {
        user = [IMAPlatform sharedInstance].host;
//        [IMAPlatform sharedInstance].host.profile.faceURL]
        [_icon sd_setImageWithURL:[NSURL URLWithString:[UserModel getCurrentUser].avatar] forState:UIControlStateNormal placeholderImage:kDefaultUserIcon];
    }
    else
    {
        user = [_msg getSender];
#pragma mark- 客服头像
        [_icon sd_setImageWithURL:[NSURL URLWithString:AgentModel.getCurrentAgent.avatar] forState:UIControlStateNormal placeholderImage:kDefaultUserIcon];
    }
    
    if (_remarkTip)
    {
        _remarkTip.hidden = !([_msg isGroupMsg] && ![_msg isMineMsg]);
        _remarkTip.font = [_msg tipFont];
        _remarkTip.textColor = [_msg tipTextColor];
        _remarkTip.text = [user showTitle];
    }
    
    [self configContent];
    
    if (_pickedViewRef)
    {
        [_pickedViewRef setSelected:_msg.isPicked];
    }
    if (_elemContentRef)
    {
        [self configElemContent];
    }
    
    if (_sendingTipRef)
    {
        [self configSendingTips];
    }
    
}

- (void)configContent
{
    
}

- (void)configElemContent
{
    
}
- (void)configSendingTips
{
    _sendingTipRef.hidden = ![_msg isMineMsg];
}



- (void)showMenu
{
    NSArray *showMenus = [self showMenuItems];
    if (showMenus.count)
    {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:showMenus];
        [menu update];
        [menu setTargetRect:_contentBack.frame inView:self.contentView];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)showMenuItems
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([_msg.msg isSelf])
    {
//        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItem:)];
//        [array addObject:deleteItem];
//
//        UIMenuItem *revokeItem = [[UIMenuItem alloc] initWithTitle:@"撤销" action:@selector(revokeItem:)];
//        [array addObject:revokeItem];
    }

    if (_msg.status == EIMAMsg_SendFail)
    {
        UIMenuItem *resendItem = [[UIMenuItem alloc] initWithTitle:@"重发" action:@selector(resendItem:)];
        [array addObject:resendItem];
    }
    
    return array;
    
}

- (void)revokeItem:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_RevokeNotification object:_msg];
}

- (void)deleteItem:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_DeleteNotification object:_msg];
}

- (void)resendItem:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_ResendNotification object:_msg];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL can = ((action == @selector(deleteItem:)) || (action == @selector(resendItem:)) || (action == @selector(revokeItem:)));
    return can;
}

@end
