//
//  TencentManger.m
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/24.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import "TencentManger.h"
#import "HaloQuickWedding-Swift.h"
#import "LeaveMessageViewController.h"
#import "TencentIMMessage.h"

#define kIMModelKey @"kUDFTCurrentIm"
#define kAgentModelKey @"kUDFTCurrentAgent"
#define kVisitorKey @"kUDFTCurrentVisitor"

#pragma mark- IM 信息

@implementation IMModel

+ (void)updateCurrentIm:(NSDictionary *)imDic{
    NSUserDefaults *udft = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *currentUserDic = [NSMutableDictionary dictionaryWithDictionary:[udft objectForKey:kIMModelKey]];
    if (imDic) {
        [currentUserDic setValuesForKeysWithDictionary:imDic];
        [udft setObject:[NSDictionary dictionaryWithDictionary:currentUserDic] forKey:kIMModelKey];
    }else{
        [udft removeObjectForKey:kIMModelKey];
    }
    [udft synchronize];
}

+ (IMModel *)getCurrentIm{
    NSUserDefaults *udft = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [udft objectForKey:kIMModelKey];
    IMModel *im = [IMModel yy_modelWithJSON:userDic];
    return im;
}

+(NSString*)getVisitor_id{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:kVisitorKey];
    return value;
}

+ (void)saveVisitor_id:(NSString *)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:kVisitorKey];
    [defaults synchronize];
}

//用户身份随机码
+(NSString *)getRandomCode{
    return [NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice].identifierForVendor UUIDString],[IMModel getTimeString]];
}

+(NSString *)getTimeString{
    //时间戳 精确到秒
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *time = [NSString stringWithFormat:@"%.0f", a];//转为字符型
    return time;
}

@end



#pragma mark- Agent 客服信息

@implementation AgentModel

+ (void)updateCurrentAgent:(NSDictionary *)agentDic{
    NSUserDefaults *udft = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *currentUserDic = [NSMutableDictionary dictionaryWithDictionary:[udft objectForKey:kAgentModelKey]];
    
    if (agentDic) {
        [currentUserDic setValuesForKeysWithDictionary:agentDic];
        [udft setObject:[NSDictionary dictionaryWithDictionary:currentUserDic] forKey:kAgentModelKey];
    }else{
        [udft removeObjectForKey:kAgentModelKey];
    }
    [udft synchronize];
}

+ (AgentModel *)getCurrentAgent{
    NSUserDefaults *udft = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [udft objectForKey:kAgentModelKey];
    AgentModel *agent = [AgentModel yy_modelWithJSON:userDic];
    return agent;
}

@end



#pragma mark- TencentManger 信息

@interface TencentManger()

@property (nonatomic, strong) IMALoginParam *loginParam;
typedef void (^getAgentInfoBlock)(NSString *group_id, NSString *agent_id, BOOL isSuccess);

@end

@implementation TencentManger

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tencentIMRecordListArr = [NSMutableArray array];
        self.isShowLoading = NO;
    }
    return self;
}

+ (instancetype)sharedManger {
    static TencentManger *sharedManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManger = [[self alloc] init];
    });
    return sharedManger;
}

//加载动画
-(void)configLoadingView{
    
    self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    [kKeyWindow addSubview:self.loadingView];
    
    UIView *blackView = [[UIView alloc]initWithFrame:CGRectMake(kScreen_Width/2-106/2, kScreen_Height/2-106/2, 106, 106)];
    blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    blackView.layer.cornerRadius = 5;
    [self.loadingView addSubview:blackView];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(blackView.width/2, 40);
    spinner.color = [UIColor whiteColor];
    [spinner startAnimating];
    [blackView addSubview:spinner];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, blackView.width, 13)];
    label.textColor = [UIColor whiteColor];
    label.text = @"客服连线中...";
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    [blackView addSubview:label];
    
}

//腾讯IM
-(void)initTencentSDK{
    #if kSupportNetReachablity
            [[NetworkUtility sharedNetworkUtility] startCheckWifi];
    #endif
    
    [[IMAPlatform sharedInstance] configOnAppLaunch];
    _loginParam = [[IMALoginParam alloc] init];
    [IMAPlatform configWith:_loginParam.config];
}

//登录IMSDK
- (void)loginTencentIM{
    //直接登录
    
    NSLog(@"🍎 登录 =====%@==%@", IMModel.getCurrentIm.userSig, IMModel.getCurrentIm.identifier);

    _loginParam.userSig = IMModel.getCurrentIm.userSig;
    _loginParam.identifier = IMModel.getCurrentIm.identifier;
    _loginParam.tokenTime = [[NSDate date] timeIntervalSince1970];
    [[IMAPlatform sharedInstance] login:_loginParam succ:^{
        [[IMAPlatform sharedInstance] configOnLoginSucc:self->_loginParam];
        [self registNotification];
        
        //腾讯IM设置用户名及头像
        [[IMAPlatform sharedInstance].host asyncSetNickname:[UserModel getCurrentUser].username succ:^{
        } fail:nil];
        
        [[IMAPlatform sharedInstance].host asyncSetFacename:[UserModel getCurrentUser].avatar succ:^{
        } fail:nil];
        
        [[IMAPlatform sharedInstance].host asyncProfile];
        
    } fail:^(int code, NSString *msg) {
        NSLog(@"🍎 登录失败");
    }];
    
}

//必须在登录之后上传token.在登录之后注册通知，保证通知回调也在登录之后，在通知的回调中上传的token。（回调在IMAAppDelegate的didRegisterForRemoteNotificationsWithDeviceToken中）
- (void)registNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

//退出
-(void)loginOutTencentIm{
    [[IMAPlatform sharedInstance] logout:^{
        [IMModel updateCurrentIm:nil];
        [AgentModel updateCurrentAgent:nil];
    } fail:^(int code, NSString *err) {
    }];
}

//进入聊天页面
- (void)pushToChatViewControllerWithAgent:(AgentModel*)agent{
    IMAUser *user = [[IMAUser alloc]init];
    user.userId = agent.agent_im_id;
    user.icon = agent.avatar;
    user.remark = agent.agent_name;
    user.nickName = agent.agent_name;
    [self intoChatVC:user];
}
-(void)pushToChatViewControllerWith:(IMAUser *)user{
    [self intoChatVC:user];
}

-(void)intoChatVC:(IMAUser*)user{
    
    // 与陌生人聊天
    UITabBarController *tabbarVC = AppDelegate.sharedAppDelegate.tabbarVC;
    NavigationViewController *curNav = (NavigationViewController *)tabbarVC.viewControllers[tabbarVC.selectedIndex];

#if kTestChatAttachment
    // 无则重新创建
    ChatViewController *vc = [[CustomChatUIViewController alloc] initWith:user];
#else
    ChatViewController *vc = [[IMAChatViewController alloc] initWith:user];
#endif
    if ([user isC2CType])
    {
        TIMConversation *imconv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:user.userId];
        if ([imconv getUnReadMessageNum] > 0)
        {
            [vc modifySendInputStatus:SendInputStatus_Send];
        }
    }
    vc.hidesBottomBarWhenPushed = YES;
    [curNav pushViewController:vc withBackTitle:@"返回" animated:YES];
    
    _isChat_now = YES;

}

//客服不在线 提示是否留言
-(void)remarkLeaveMessageWithGroup_id:(NSString *)group_id agent_id:(NSString*)agent_id{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message: @"当前客服不在线，是否留言？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去留言" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LeaveMessageViewController *guestBookViewController = [[LeaveMessageViewController alloc] init];
        HBTabBarViewController *tabbarVC = AppDelegate.sharedAppDelegate.tabbarVC;
        [tabbarVC.viewControllers[tabbarVC.selectedIndex] pushViewController:guestBookViewController animated:YES];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.signOut", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:sureAction];
    [alertView addAction:cancel];
    [kKeyWindow.rootViewController presentViewController:alertView animated:YES completion:nil];
}

//添加卡片提示框
-(UIView *)createCardViewWithCardSendBlock:(cardSendBlock)cardSendBlock cardCloseBlock:(cardCloseBlock)cardCloseBlock{
    TencentCardMessageView *mCardMessageView = [[TencentCardMessageView alloc]initWithFrame:CGRectMake(0, kSystem_Height, kScreen_Width, 137)];
    [mCardMessageView configData];
    mCardMessageView.hidden = !TencentManger.sharedManger.isShowCard;
    mCardMessageView.cardSendBlock = ^{
        cardSendBlock();
    };
    mCardMessageView.cardCloseBlock = ^{
        cardCloseBlock();
    };
    return mCardMessageView;
}

//聊天记录中卡片信息点击事件
-(void)cardClickWithType:(NSString *)type detail_id:(NSString *)detail_id{
    if ([type isEqualToString:@"hotel_card"]) {
        //酒店详情
        WeddingHotelDetailVC *hotelDetail = [[WeddingHotelDetailVC alloc]init];
        hotelDetail.hotel_id = detail_id;
        hotelDetail.hidesBottomBarWhenPushed = YES;
        [[AppDelegate.sharedAppDelegate navigationViewController] pushViewController:hotelDetail animated:YES];
    }else{
        //案例详情
        CaseDetailVC *planDetail = [[CaseDetailVC alloc]init];
        planDetail.case_id = detail_id;
        planDetail.hidesBottomBarWhenPushed = YES;
        [[AppDelegate.sharedAppDelegate navigationViewController] pushViewController:planDetail animated:YES];
    }
}

//发起会话
-(void)beginChatWithType:(NSString*)type{

//    IMAUser *user = [[IMAUser alloc]init];
//    user.userId = @"10";
//    user.icon = @"";
//    user.remark = @"6666";
//    user.nickName = @"8888";
//    [self intoChatVC:user];
    
    if (_isChat_now == YES || self.isShowLoading) {
        return;
    }
    
    self.isShowLoading = YES;
    [self configLoadingView];

    [self getAgentInfoWithType:type getAgentInfoBlock:^(NSString *group_id, NSString *agent_id, BOOL isSuccess) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self beginChatWithGroup_id:group_id agent_id:agent_id isShow:NO];
            });
        }
    }];
    
}

-(void)beginChatWithGroup_id:(NSString*)group_id agent_id:(NSString*)agent_id isShow:(BOOL)isShow{
    
    TencentBeginChatApi *chatApi = [[TencentBeginChatApi alloc] initWithGroup_id:group_id agent_id:agent_id];
    [chatApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"🍎 开始会话 =====%@", request.responseJSONObject);

        NSDictionary *agentDic = [request.responseJSONObject objectForKey:@"data"];
        [AgentModel updateCurrentAgent:agentDic];
        
        if (AgentModel.getCurrentAgent.history_conversation_id.count != 0) {
            self.historyLoadIndex = 0;
        }
        
        self.isShowLoading = NO;
        [self.loadingView removeFromSuperview];
        
        if (AgentModel.getCurrentAgent.status.boolValue) {
            //成功后进入聊天界面
            [self pushToChatViewControllerWithAgent:AgentModel.getCurrentAgent];
        }else{
            //留言提示
            [self remarkLeaveMessageWithGroup_id:group_id agent_id:agent_id];
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [self.loadingView removeFromSuperview];
        NSLog(@"🍎 开始会话 =====%@", request.responseJSONObject);
    }];
    
}

//获取客服信息
-(void)getAgentInfoWithType:(NSString*)type getAgentInfoBlock:(getAgentInfoBlock)getAgentInfoBlock{
    TencentGetGroupIDApi *getInfoApi = [[TencentGetGroupIDApi alloc]init];
    [getInfoApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"🍎 获取客服信息 =====%@", request.responseJSONObject);
        NSString *group_id = [NSString stringWithFormat:@"%@",[[request.responseJSONObject objectForKey:@"data"] objectForKey:@"group_id"]];
        NSString *agent_id = [NSString stringWithFormat:@"%@",[[request.responseJSONObject objectForKey:@"data"] objectForKey:@"agent_id"]];
        getAgentInfoBlock(group_id,agent_id,YES);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"🍎 获取客服信息 =====%@", request.responseJSONObject);
        getAgentInfoBlock(@"",@"",NO);
        [self.loadingView removeFromSuperview];
    }];
}

//获取聊天记录
-(void)getCurrentChatRecord:(NSString *)conversation_id completion:(completionBlock)completion{
    self.tencentIMRecordListArr = [[NSMutableArray alloc]init];
    TencentGetChatRecordApi *getChatRecordApi = [[TencentGetChatRecordApi alloc] initWithConversation_id:[NSString stringWithFormat:@"%@",conversation_id]];
    [getChatRecordApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"🍎 聊天记录 conversation_id==%@=====%@", conversation_id, request.responseJSONObject);
        NSArray *list = [[request.responseJSONObject objectForKey:@"data"] objectForKey:@"list"];
        int count = (int)list.count;
//        for (int i = count-1; i >= 0; i--) {
        for (int i = 0; i < count; i++) {
            NSDictionary *listDic = list[i];
            TencentIMMessage *tenImMessage = [[TencentIMMessage alloc]init];
            //初始化角色 是否是自己
            NSString *send_role = listDic[@"send_role"];
            tenImMessage.isSelf = [send_role isEqualToString: @"visitor"];
            //初始化时间 时间秒
            NSString *created_at = listDic[@"created_at"];
            tenImMessage.time = [NSString getCurrentTimeChangeSecond:created_at];
            //遍历当前时间对象下的 message
            NSArray *messageArr = [listDic objectForKey:@"message"];
            for (NSDictionary *messageDic in messageArr) {
                NSDictionary *MsgContent = messageDic[@"MsgContent"];
                NSString *MsgType = messageDic[@"MsgType"];
                if ([MsgType isEqualToString:@"TIMTextElem"]) {
                    //消息对象类型：文本
                    TIMTextElem *textElem = [[TIMTextElem alloc]init];
                    textElem.text = MsgContent[@"Text"];
                    [tenImMessage addElem:textElem];
                }else if ([MsgType isEqualToString:@"TIMImageElem"]){
                    //消息对象类型：图片
                    TIMImageElem *imageElem = [[TIMImageElem alloc]init];
                    imageElem.format = [MsgContent[@"ImageFormat"] integerValue];
                    NSMutableArray *imageList = [NSMutableArray array];
                    NSArray *ImageInfoArray = MsgContent[@"ImageInfoArray"];
                    for (NSDictionary *imageDic in ImageInfoArray) {
                        TIMImage *image = [[TIMImage alloc]init];
                        image.type = TIM_IMAGE_TYPE_THUMB;
                        image.size = [((NSNumber *)imageDic[@"Size"]) intValue];
                        image.width = [((NSNumber *)imageDic[@"Width"]) intValue];
                        image.height = [((NSNumber *)imageDic[@"Height"]) intValue];
                        image.url = ((NSString *)imageDic[@"URL"]);
                        image.uuid = MsgContent[@"UUID"];
                        [imageList addObject:image];
                    }
                    imageElem.imageList = imageList;
                    [tenImMessage addElem:imageElem];
                }else if ([MsgType isEqualToString:@"TIMFaceElem"]){
                    //消息对象类型：表情
                    TIMFaceElem *faceElem = [[TIMFaceElem alloc]init];
                    faceElem.index =  [((NSNumber *)MsgContent[@"Index"]) intValue];
                    faceElem.data = [MsgContent[@"Data"] dataUsingEncoding:NSUTF8StringEncoding];
                    [tenImMessage addElem:faceElem];
                }else if ([MsgType isEqualToString:@"TIMSoundElem"]){
                    //消息对象类型：语音
                    NSLog(@"🍎 消息对象类型：语音=====%@", MsgContent);
                    TIMSoundElem *soundElem = [[TIMSoundElem alloc]init];
                    soundElem.uuid = [NSString stringWithFormat:@"%@",MsgContent[@"UUID"]];
                    soundElem.dataSize = [((NSNumber *)MsgContent[@"Size"]) intValue];
                    soundElem.second =  [((NSNumber *)MsgContent[@"Second"]) intValue];
                    [tenImMessage addElem:soundElem];
                }else if ([MsgType isEqualToString:@"TIMCustomElem"]){
                    //消息对象类型：自定义
                    NSLog(@"🍎 消息对象类型：自定义=====%@", MsgContent);
                    TIMCustomElem *customElem = [[TIMCustomElem alloc]init];
                    customElem.data = [MsgContent[@"Data"] dataUsingEncoding:NSUTF8StringEncoding];
                    customElem.desc = MsgContent[@"Desc"];
                    customElem.ext = MsgContent[@"Ext"];
                    customElem.sound = MsgContent[@"Sound"];
                    [tenImMessage addElem:customElem];
                }

            }
            
            if ([tenImMessage elemCount] != 0) {
//                IMAMsg *immMsg = [IMAMsg msgWith:tenImMessage];
//                [self.tencentIMRecordListArr addObject:immMsg];
                [self.tencentIMRecordListArr addObject:tenImMessage];
            }
                        
        }
        
        NSArray *msgArr = [[[IMAConversation alloc] init] onLoadRecentMessageSucc:self.tencentIMRecordListArr];
        completion(msgArr, YES);
       
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion([[NSArray alloc]init], NO);
        NSLog(@"🍎 聊天记录 =====%@", request.responseJSONObject);
    }];
    
}

//获取历史聊天记录
-(void)getHistoryChatRecordWithCompletion:(completionBlock)completion{
    if (_historyLoadIndex < AgentModel.getCurrentAgent.history_conversation_id.count) {
        NSString *conversation_id = AgentModel.getCurrentAgent.history_conversation_id[_historyLoadIndex];
        [self getCurrentChatRecord:conversation_id completion:^(NSArray *imamsgList, BOOL success) {
            self->_historyLoadIndex += 1;
            completion(imamsgList,success);
        }];
    }else{
        completion([[NSMutableArray alloc]init],NO);
    }
}

//获取未读消息数
-(void)getUnReadMessageWithUnRead:(getUnReadBlock)getUnReadBlock{
    TencentGetUnReadApi *getUnReadApi = [[TencentGetUnReadApi alloc]init];
    [getUnReadApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *unread = [[request.responseJSONObject objectForKey:@"data"] objectForKey:@"unread"];
        if (unread.integerValue > 0) {
            getUnReadBlock(YES);
        }else{
            getUnReadBlock(NO);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        getUnReadBlock(NO);
    }];
}

@end



