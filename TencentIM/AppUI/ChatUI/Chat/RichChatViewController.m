//
//  RichChatViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/31.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "RichChatViewController.h"

@implementation RichChatViewController

- (void)dealloc
{
    IMAMsg *draft = [_inputView getMsgDraft];
    if (draft)
    {
        [_conversation setDraft:draft.msgDraft];
    }
    else
    {
        [_conversation setDraft:nil];
//        [self adapterConversation];
    }
    
    //这里必须先清空会话列表
    [[[IMAPlatform sharedInstance].conversationMgr conversationList] removeAllObjects];

    [[IMAPlatform sharedInstance].conversationMgr asyncConversationList];
    
    //退出时上报一次已读，以前是没收到一条消息都上报，会导致server接收到大量的已读上报消息
    [_conversation setReadAllMsg];
}

//在退出聊天界面时，判断当前会话是否应该被创建(如果是从联系人列表进入，且没有发送过消息，且会话列表中不存在这个会话，则认为不应该创建这个新会话)
//- (void)adapterConversation
//{
//    if ([AppDelegate sharedAppDelegate].isContactListEnterChatViewController)
//    {
//        if (!_isSendMsg)
//        {
//            if (![[IMAPlatform sharedInstance].conversationMgr queryConversationWith:_receiver])
//            {
//                [[IMAPlatform sharedInstance].conversationMgr removeConversationWithConv:_conversation];
//            }
//        }
//    }
//}

- (void)addInputPanel
{
    _inputView = [[RichChatInputPanel alloc] initRichChatInputPanel];
    _inputView.chatDelegate = self;
    [self.view addSubview:_inputView];
    __weak typeof(self) weakSekf = self;
    _inputView.didShowKeyBoard = ^(BOOL isShow) {
        weakSekf.isShow = isShow;
    };
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f===%d", scrollView.contentOffset.y,_isShow);
    CGFloat value = scrollView.contentOffset.y;
    if (!_isShow) {
        if (value >= 0) {
            [_mCardView setY:kSystem_Height];
        }else
        {
            [_mCardView setY:-value+kSystem_Height];
        }
    }else{
        
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, TencentManger.sharedManger.isShowCard ? 137 : 0.01)];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  TencentManger.sharedManger.isShowCard ? 137 : 0.01;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IMAMsg *draftMsg = [IMAMsg msgWithDraft:[_conversation getDraft]];
    [_inputView setMsgDraft:draftMsg];
    
    
#pragma mark- 卡片信息
    //    if (TencentManger.sharedManger.isShowCard == NO) {
    //        return nil;
    //    }
    _mCardView = [TencentManger.sharedManger createCardViewWithCardSendBlock:^{
        //发送自定义消息
        [self addCard];
    } cardCloseBlock:^{
        TencentManger.sharedManger.isShowCard = NO;
        self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 15)];
        [self.tableView reloadData];
    }];
    [self.view addSubview:_mCardView];
  
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if (TencentManger.sharedManger.isShowCard) {
//        [self addCard];
//    }
}

//-(void)addCard{
//    //发送自定义消息
//    NSString * xml = [NSString dictionaryToJSONString:TencentManger.sharedManger.card];
//    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
//    TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
//    [custom_elem setData:data];
//    [custom_elem setDesc:TencentManger.sharedManger.cardType];
//    [custom_elem setExt:@"json"];
//    TIMMessage * msg = [[TIMMessage alloc] init];
//    [msg addElem:custom_elem];
//    IMAMsg *imAMsg = [IMAMsg msgWith:msg];
//    [self sendMsg:imAMsg];
//}
//

@end
