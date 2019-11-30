//
//  TencentManger.h
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/24.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMAUser;

#define kSource_id @"XymqyJ"
#define kGroup_id @"1"
#define kAgent_id @""
#define kTLSAppid  [[YTKNetconfig getCRMService] containsString:@"feiyu"] ? @"1400168746" : @"1400289428"
#define kSdkAppId  [[YTKNetconfig getCRMService] containsString:@"feiyu"] ? @"1400168746" : @"1400289428"
    
/**
 IM 信息
 **/
@interface IMModel : NSObject

@property (nonatomic, copy) NSString *identifier;  //IM登录标识
@property (nonatomic, copy) NSString *userSig;     //IM登录签名

//IM本地信息
+ (void)updateCurrentIm:(NSDictionary *)imDic;
+ (IMModel *)getCurrentIm;

//访客ID
+(NSString*)getVisitor_id;
+ (void)saveVisitor_id:(NSString *)value;

//随机身份识别码
+(NSString *)getRandomCode;
+(NSString *)getTimeString;

@end

/**
 Agent 客服信息
 **/
@interface AgentModel : NSObject

@property (nonatomic, copy) NSString *phone;                  //客服电话
@property (nonatomic, copy) NSString *status;                 //客服状态，判断是否留言
@property (nonatomic, copy) NSString *agent_id;               //客服ID
@property (nonatomic, copy) NSString *agent_name;             //客服名称
@property (nonatomic, copy) NSString *agent_im_id;            //客服的IM标识
@property (nonatomic, copy) NSString *avatar;                 //客服头像
@property (nonatomic, copy) NSString *conversation_id;        //当前会话id
@property (nonatomic, copy) NSArray *history_conversation_id; //历史会话id

+ (void)updateCurrentAgent:(NSDictionary *)agentDic;
+ (AgentModel *)getCurrentAgent;

@end

/**
 TencentManger 信息
 **/
@interface TencentManger : NSObject

//聊天记录
typedef void (^completionBlock)(NSArray *imamsgList, BOOL success);
//卡片发送
typedef void (^cardSendBlock)(void);
typedef void (^cardCloseBlock)(void);
//聊天记录未读数
typedef void (^getUnReadBlock)(BOOL);

+ (instancetype)sharedManger;

//日期自动自动消息
@property (nonatomic, strong) NSString *automaticText;
//是否显示卡片信息
@property (nonatomic, assign) BOOL isShowCard;
@property (nonatomic, strong) NSDictionary *card;
@property (nonatomic, strong) NSString *cardType;
//存放所有聊天记录 主要用来添加加载数据
@property (nonatomic, strong) NSMutableArray *tencentIMRecordListArr;
@property (nonatomic, assign) NSInteger historyLoadIndex; //加载历史记录标记
@property (nonatomic, assign) BOOL isChat_now;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) BOOL isShowLoading;
@property (nonatomic, strong) NSMutableArray *loadingArr;

//初始化SDK并登录
-(void)initTencentSDK;

//登录聊天
- (void)loginTencentIM;
//退出聊天
-(void)loginOutTencentIm;

//从列表中开启聊天会话
- (void)pushToChatViewControllerWith:(IMAUser*)user;

//发起会话
-(void)beginChatWithType:(NSString*)type; //传入参数获取 group_id -- agent_id
-(void)beginChatWithGroup_id:(NSString*)group_id agent_id:(NSString*)agent_id isShow:(BOOL)isShow;

//添加卡片提示框
-(UIView *)createCardViewWithCardSendBlock:(cardSendBlock)cardSendBlock cardCloseBlock:(cardCloseBlock)cardCloseBlock;
//聊天记录中卡片信息点击事件
-(void)cardClickWithType:(NSString *)type detail_id:(NSString *)detail_id;

//获取聊天记录
-(void)getCurrentChatRecord:(NSString *)conversation_id completion:(completionBlock)completion;

//获取历史聊天l记录
-(void)getHistoryChatRecordWithCompletion:(completionBlock)completion;

//获取未读消息数
-(void)getUnReadMessageWithUnRead:(getUnReadBlock)getUnReadBlock;

@end


