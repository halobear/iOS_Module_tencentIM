//
//  ChatViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/23.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "ChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MyChatToolBarView.h"
#import "MyUIDefine.h"
#import "MyMoreView.h"

@interface ChatViewController ()

@property (nonatomic, strong) MyChatToolBarView *toolBar;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, assign) BOOL isLocalShow;

@end

@implementation ChatViewController

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [_receiverKVO unobserveAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addCard{
    //发送自定义消息
    NSString * xml = [NSString dictionaryToJSONString:TencentManger.sharedManger.card];
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
    [custom_elem setData:data];
    [custom_elem setDesc:TencentManger.sharedManger.cardType];
    [custom_elem setExt:@"json"];
    TIMMessage * msg = [[TIMMessage alloc] init];
    [msg addElem:custom_elem];
    IMAMsg *imAMsg = [IMAMsg msgWith:msg];
    [self sendMsg:imAMsg];
}

- (instancetype)initWith:(IMAUser *)user
{
    if (self = [super init])
    {
        _sendInputStatus = SendInputStatus_notSend;
        _receiver = user;
//        _isSendMsg = NO;
        
        [self createNavBarNavTitle:user.remark back:^{
            [self.navigationController popViewControllerAnimated:true];
        }];
        self.navBottomImageView.hidden = NO;
        [self initRight_ImageBtn:@"Nav_phone" block:^{
            [HaloTool.sharedTool callPhone:AgentModel.getCurrentAgent.phone];
        }];
        
    }
    return self;
}

- (void)addHeaderView{}

#pragma mark- 数据刷新
- (void)onRefresh
{
    __weak ChatViewController *ws = self;
    
    [[TencentManger sharedManger] getHistoryChatRecordWithCompletion:^(NSArray *imamsgList, BOOL success) {
        if (success) {
            [self->_conversation.msgList insertObjectsFromArray:imamsgList atIndex:0];
            [ws onLoadRecentMessage:imamsgList complete:YES scrollToBottom:YES];
        }
        [ws.tableView.mj_header endRefreshing];
        [ws refreshCompleted];
        [ws layoutHeaderRefreshView];
    }];
    
    //    [_conversation asyncLoadRecentMessage:10 completion:^(NSArray *imamsgList, BOOL succ) {
    //        if (succ)
    //        {
    //            [ws onLoadRecentMessage:imamsgList complete:YES scrollToBottom:YES];
    //        }
    //        [ws.tableView.mj_header endRefreshing];
    //        [ws refreshCompleted];
    //        [ws layoutHeaderRefreshView];
    //    }];
}

- (void)addFooterView
{
    // 作空实现
}

- (void)addOwnViews
{
    [super addOwnViews];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F3"];
    _tableView.sectionFooterHeight = 0.f;
    self.view.backgroundColor = _tableView.backgroundColor;
    
    [self addChatToolBar];
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPressGr.minimumPressDuration = 1.0;
    [_tableView addGestureRecognizer:longPressGr];
}

-(void)onLongPress:(UILongPressGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.tableView];
        
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        UITableViewCell<TIMElemAbleCell> *cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL showMenu = [cell canShowMenu];
        
        if (showMenu)
        {
            if ([cell canShowMenuOnTouchOf:gesture])
            {
                [cell showMenu];
            }
        }
    }
}


- (void)addChatToolBar
{
    CGFloat kToolbarY = CGRectGetMaxY(self.view.bounds) - CHAT_BAR_MIN_H - 2*CHAT_BAR_VECTICAL_PADDING-iphonexOffvalue;
    
    _toolbar = [[MyChatToolBarView alloc] initWithFrame:CGRectMake(0, kToolbarY, CGRectGetWidth(self.view.bounds), CHAT_BAR_MIN_H+2*CHAT_BAR_VECTICAL_PADDING) chatType:[_conversation type]];
    _toolbar.delegate = self;
    _toolBar.backgroundColor = UIColor.redColor;
    [self.view addSubview:_toolbar];
    [(MyMoreView *)_toolbar.moreView setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    TencentManger.sharedManger.isChat_now = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configWithUser:_receiver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateInputStatus:) name:kUserInputStatus object:nil];
    
    UITapGestureRecognizer* tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard)];
    [self.tableView addGestureRecognizer:tapAction];
        
}

- (void)configWithUser:(IMAUser *)user
{
    [_receiverKVO unobserveAll];
    
    _receiver = user;
    __weak ChatViewController *ws = self;
    
    _receiverKVO = [FBKVOController controllerWithObserver:self];
    
    [_receiverKVO observe:_receiver keyPaths:@[@"remark", @"nickName"] options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [ws setChatTitle];
    }];
    
    if (_conversation)
    {
        [_conversation releaseConversation];
        _messageList = nil;
        [self reloadData];
    }
    
    _conversation = [[IMAPlatform sharedInstance].conversationMgr chatWith:user];
    
#pragma mark- 获取会话记录
//        self->_messageList = self->_conversation.msgList;
//        [self->_conversation asyncLoadRecentMessage:3 completion:^(NSArray *imamsgList, BOOL succ) {
//            [ws onLoadRecentMessage:imamsgList complete:succ scrollToBottom:YES];
//        }];
    [TencentManger.sharedManger getCurrentChatRecord:AgentModel.getCurrentAgent.conversation_id completion:^(NSArray *imamsgList, BOOL success) {
        [self->_conversation.msgList removeAllObjects];
        [self->_conversation.msgList addObjectsFromArray:imamsgList];
        self->_messageList = self->_conversation.msgList;
        [ws onLoadRecentMessage:imamsgList complete:YES scrollToBottom:YES];
#pragma mark- 自动发送消息
        if (TencentManger.sharedManger.automaticText.length != 0) {
            [self sendText:TencentManger.sharedManger.automaticText];
        }
    }];
    
    _conversation.receiveMsg = ^(NSArray *imamsgList, BOOL succ) {
        [ws modifySendInputStatus:SendInputStatus_Send];
        [ws onReceiveNewMsg:imamsgList succ:succ];
        [ws updateMessageList];
    };
    
    [self addChatSettingItem];
    
    [self setChatTitle];
    
    // 同步群资料
    if ([user isGroupType])
    {
        [((IMAGroup *)user) asyncUpdateGroupInfo:nil fail:nil];
    }
    
}

- (void)setChatTitle
{
    NSString *title = [_receiver showTitle];
    if (title.length > 10)
    {
        title = [NSString stringWithFormat:@"%@...", [title substringToIndex:10]];
    }
    self.title = title;
}

- (void)onReceiveNewMsg:(NSArray *)imamsgList succ:(BOOL)succ
{
    [_tableView beginUpdates];
    
    NSInteger count = [imamsgList count];
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger idx = _messageList.count + i - count;
        NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexArray addObject:index];
    }
    
    [_tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateOnSendMessage:imamsgList succ:YES];
    });
}

//当消息量过大时，需要清理部分消息，避免内存持续增长
- (void)updateMessageList
{
    if (_messageList.count > 1000)
    {
        DebugLog(@"_messageList.count > 1000");
        int rangLength = 100;
        NSRange range = NSMakeRange(_messageList.count-rangLength, rangLength);
        [_messageList subArrayWithRange:range];
        [_tableView reloadData];
    }
}

- (void)onLoadRecentMessage:(NSArray *)imamsgList complete:(BOOL)succ scrollToBottom:(BOOL)scroll
{
    if (succ)
    {
        if (imamsgList.count > 0)
        {
            [_tableView beginUpdates];
            
            NSMutableArray *ar = [NSMutableArray array];
            for (NSInteger i = 0; i < imamsgList.count; i++)
            {
                [ar addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            
            [_tableView insertRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationTop];
            
            [_tableView endUpdates];
            
            if (scroll)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    NSIndexPath *last = [NSIndexPath indexPathForRow:imamsgList.count-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    
                    #pragma mark- 自动发送消息
                    if (TencentManger.sharedManger.automaticText.length != 0 && self.isLocalShow) {
                        [self sendText:TencentManger.sharedManger.automaticText];
                        self.isLocalShow = NO;
                    }
                    if (TencentManger.sharedManger.isShowCard && self.isLocalShow) {
                        [self addCard];
                        self.isLocalShow = NO;
                    }
                });
            }
        }
    }
}

- (void)layoutRefreshScrollView
{
    CGFloat kToolbarY = CGRectGetMaxY(self.view.bounds) - CHAT_BAR_MIN_H - 2*CHAT_BAR_VECTICAL_PADDING;
    // do nothing
    _tableView.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds), CGRectGetWidth(self.view.bounds), kToolbarY);
    _toolbar.frame = CGRectMake(0, kToolbarY, CGRectGetWidth(self.view.bounds), CHAT_BAR_MIN_H+2*CHAT_BAR_VECTICAL_PADDING);
}


- (void)addChatSettingItem
{
    DebugLog(@"子类实现");
}

- (void)onClickChatSetting
{
    DebugLog(@"在子类中实现");
}

// 加载历史信息
- (void)loadHistotyMessages
{
    
}

// 添加收到的信息
- (void)appendReceiveMessage
{
    
}

///==========================
#pragma mark - MyChatToolBarViewDelegate

- (void)updateOnSendMessage:(NSArray *)msglist succ:(BOOL)succ
{
    if (msglist.count)
    {
        NSInteger index = [_messageList indexOfObject:msglist.lastObject];
        if (index != 0) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)sendMsg:(IMAMsg *)msg
{
    if (msg)
    {
//        _isSendMsg = YES;
        [_tableView beginUpdates];
        
        __weak ChatViewController *ws = self;
        DebugLog(@"will sendmessage");

      NSArray *newaddMsgs = [_conversation sendMessage:msg completion:^(NSArray *imamsglist, BOOL succ, int code) {
          
            DebugLog(@"sendmessage end");
            [ws updateOnSendMessage:imamsglist succ:succ];
          
            if (!succ)
            {
                if (code == kSaftyWordsCode)
                {
                    IMAMsg *msg = [IMAMsg msgWithCustom:EIMAMSG_SaftyTip param:@"安全文本打击"];
                    [self->_messageList addObject:msg];
                    
                    [self showMsgs:@[msg]];
                }
            }
        }];
        
        [self showMsgs:newaddMsgs];
    }
}

- (void)showMsgs:(NSArray *)msgs
{
    NSMutableArray *array = [NSMutableArray array];
    for (IMAMsg *msg in msgs)
    {
        NSInteger idx = [_messageList indexOfObject:msg];
        NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:0];
        [array addObject:index];
    }
    
    [_tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *index = [NSIndexPath indexPathForRow:self->_messageList.count - 1 inSection:0];
        [self->_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}

- (void)modifySendInputStatus:(SendInputStatus)status
{
    _sendInputStatus = status;
}

- (void)onUpdateInputStatus:(NSNotification *)notify
{
    CustomElemCmd *elem = (CustomElemCmd *)notify.object;
    if ([elem.actionParam isEqualToString:@"EIMAMSG_InputStatus_Ing"])
    {
        DebugLog(@"EIMAMSG_InputStatus_Ing");
        self.navTitlelabel.text = @"对方正在输入...";
        
        if (!_inputStatusTimer)
        {
            _inputStatusTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onRestoreTitle:) userInfo:nil repeats:YES];
        }
    }
    else if ([elem.actionParam isEqualToString:@"EIMAMSG_InputStatus_End"])
    {
        DebugLog(@"EIMAMSG_InputStatus_End");
        [self onRestoreTitle:nil];
    }
}

- (void)onRestoreTitle:(NSTimer *)timer
{
    if (_inputStatusTimer)
    {
        [_inputStatusTimer invalidate];
        _inputStatusTimer = nil;
    }
    
    [self setChatTitle];
}

- (void)sendInputStatus
{
    DebugLog(@"chatviewcontroller sendInputStatus");
    if (_sendInputStatus == SendInputStatus_Send && ![_receiver isGroupType])
    {
        IMAMsg *msg = [IMAMsg msgWithCustom:EIMAMSG_InputStatus param:@"EIMAMSG_InputStatus_Ing"];
        [_conversation sendOnlineMessage:msg.msg succ:nil fail:^(int code, NSString *msg) {
        
            DebugLog(@"send online msg fail,code = %d,fail = %@", code, msg);
        }];
    }
}

- (void)sendStopInputStatus
{
    if (_sendInputStatus == SendInputStatus_Send && ![_receiver isGroupType])
    {
        IMAMsg *msg = [IMAMsg msgWithCustom:EIMAMSG_InputStatus param:@"EIMAMSG_InputStatus_End"];
        [_conversation sendOnlineMessage:msg.msg succ:nil fail:^(int code, NSString *msg) {
            
            DebugLog(@"send stop online msg fail,code = %d,fail = %@", code, msg);
        }];
    }
}

- (void)sendText:(NSString *)text
{
    if (text && text.length > 0)
    {
        IMAMsg *msg = [IMAMsg msgWithText:text];
        [self sendMsg:msg];
    }
}
- (void)didChangeToolBarHight:(CGFloat)toHeight
{
    __weak ChatViewController* weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = weakself.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = weakself.view.frame.size.height - toHeight;
        weakself.tableView.frame = rect;
        [weakself.toolBar updateEmoj];
    }];
    
    if (_tableView.contentSize.height > _tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
        [_tableView setContentOffset:offset animated:YES];
    }
}
- (void)sendAudioRecord:(AudioRecord *)audio
{
    IMAMsg *msg = [IMAMsg msgWithSound:audio.audioData duration:audio.duration];
    [self sendMsg:msg];
}

//===========================

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.navigationBar.translucent = NO;
        _imagePicker.navigationBar.tintColor = kTextColor_Black;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (void)sendImage:(UIImage *)image orignal:(BOOL)orignal
{
    if (image)
    {
        IMAMsg *msg = [IMAMsg msgWithImage:image isOrignal:orignal];
        [self sendMsg:msg];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info[UIImagePickerControllerOriginalImage] fixOrientation];
        NSData *data = UIImagePNGRepresentation(image);
        
        if(data.length > 28 * 1024 * 1024)
        {
            [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
            return;
        }

        ImageThumbPickerViewController *vc = [[ImageThumbPickerViewController alloc] initWith:image];
        __weak ChatViewController *ws = self;
        vc.sendImageBlock = ^ (ImageThumbPickerViewController *svc, BOOL isOrignal) {
            [ws sendImage:svc.showImage orignal:isOrignal];
            ws.imagePicker = nil;
            
        };
        [picker pushViewController:vc animated:YES];
    }
    else if([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
        if (self.imagePicker.mediaTypes.count == 2)
        {
            //将文件转换为data
            NSURL *url = info[UIImagePickerControllerMediaURL];
            NSError *err = nil;
            NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&err];
            
            //将data保存到cache目录
            NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
            NSString *extName = [[url absoluteString] pathExtension];
            NSString *cachePath = [PathUtility getCachePath];
            NSString *saveToDir = [NSString stringWithFormat:@"%@/timchat/",cachePath];
            NSString *saveFileName = [NSString stringWithFormat:@"sendVideo_%d.%@",(int)curTime,extName];

            //判断目录是否存在
            BOOL isDir = FALSE;
            BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:saveToDir isDirectory:&isDir];
            if (!(isDir && isDirExist))
            {
                BOOL isCreateDir = [PathUtility createDirectoryAtCache:@"timchat"];
                if (!isCreateDir) {
                    return;
                }
            }

            //判断文件是否存在
            NSString *filePath = [NSString stringWithFormat:@"%@%@",saveToDir,saveFileName];
            if (![PathUtility isExistFileInDocument:saveFileName])
            {
                BOOL isCreate = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                if (!isCreate)
                {
                    return ;
                }
            }
            NSError *error = nil;
            [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
            if (error) {
                [HUDHelper alert:@"保存视频失败"];
                return;
            }
            if(data.length < 28 * 1024 * 1024)
            {
                //文件最大不超过28MB
                NSURL *saceUrl = [NSURL URLWithString:filePath];
                IMAMsg *msg = [IMAMsg msgWithFilePath:saceUrl];
                [self sendMsg:msg];
            }
            else
            {
                [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
            }
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

#pragma mark - moreView
-(void)hiddenKeyBoard
{
    [_toolbar endEditing:YES];
}

#pragma mark - MyMoreViewDelegate
- (void)moreViewPhotoAction
{
    // 隐藏键盘
    [self hiddenKeyBoard];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}
- (void)moreViewCameraAction
{
    [self hiddenKeyBoard];
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self.imagePicker setEditing:YES];
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied)
        {
            // 没有权限
            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" cancel:@"确定"];
            return;
        }
    }
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreViewFileAction
{
    // 隐藏键盘，只能选择图片或视频文件
    [self hiddenKeyBoard];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreVideVideoAction
{
    // 隐藏键盘
    [self hiddenKeyBoard];
    
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (videoStatus == 	AVAuthorizationStatusRestricted || videoStatus == AVAuthorizationStatusDenied)
        {
            // 没有权限
            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" cancel:@"确定"];
            return;
        }
        
        AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (audioStatus == 	AVAuthorizationStatusRestricted || audioStatus == AVAuthorizationStatusDenied)
        {
            // 没有权限
            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-麦克风\"中允许访问麦克风。" cancel:@"确定"];
            return;
        }
        __weak ChatViewController *ws = self;
        if (videoStatus == AVAuthorizationStatusNotDetermined)
        {
            //请求相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
                
                
                    if(granted)
                    {
                        AVAuthorizationStatus audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                        if (audio == AVAuthorizationStatusNotDetermined)
                        {
                            //请求麦克风权限
                            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (granted)
                                    {
                                        [ws addMicroVideoView];
                                    }
                                });
                            }];
                        }
                        else//这里一定是有麦克风权限了
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [ws addMicroVideoView];
                            });
                        }
                    }
                
             }];
        }
        else//这里一定是有相机权限了
        {
            if (audioStatus == AVAuthorizationStatusNotDetermined)
            {
                //请求麦克风权限
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted)
                        {
                            [ws addMicroVideoView];
                        }
                    });
                    
                }];
            }
            else//这里一定是有麦克风权限了
            {
                [ws addMicroVideoView];
            }

        }
    }
}

- (void)addMicroVideoView
{
//    CGFloat selfWidth  = self.view.bounds.size.width;
//    CGFloat selfHeight = self.view.bounds.size.height;
//    MicroVideoView *microVideoView = [[MicroVideoView alloc] initWithFrame:CGRectMake(0, selfHeight/3, selfWidth, selfHeight * 2/3)];
//    microVideoView.delegate = self;
//    [self.view addSubview:microVideoView];
    
    TCVideoRecordViewController *videoRecordVC = [[TCVideoRecordViewController alloc] init];
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:videoRecordVC];
    videoRecordVC.delegate = self;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)recordVideoPath:(NSString *)path
{
    NSError *err = nil;
    NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSDataReadingMappedIfSafe error:&err];
    //文件最大不超过28MB
    if(data.length < 28 * 1024 * 1024)
    {
        IMAMsg *msg = [IMAMsg msgWithVideoPath:path];
        [self sendMsg:msg];
    }
    else
    {
        [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
    }
}
    
- (void)touchUpDone:(NSString *)savePath
{
        NSError *err = nil;
        NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:savePath] options:NSDataReadingMappedIfSafe error:&err];
        //文件最大不超过28MB
        if(data.length < 28 * 1024 * 1024)
        {
            IMAMsg *msg = [IMAMsg msgWithVideoPath:savePath];
            [self sendMsg:msg];
        }
        else
        {
            [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMAMsg *msg = [_messageList objectAtIndex:indexPath.row];
    if (msg.type == EIMAMSG_Custom) {
        TIMCustomElem *elem = (TIMCustomElem*)[msg.msg getElem:0];
        NSString *cardStr = [[NSString alloc] initWithData:elem.data encoding:NSUTF8StringEncoding];
        NSDictionary *card = [NSString parseJSONStringToNSDictionary:cardStr];
        if ([card[@"type"] isEqualToString:@"goods_card"] || [card[@"type"] isEqualToString:@"hotel_card"]) {
            return [msg heightInWidth:tableView.bounds.size.width inStyle:_conversation.type == TIM_GROUP]+30;
        }else  if ([card[@"type"] isEqualToString:@"close"]){
            return [msg heightInWidth:tableView.bounds.size.width inStyle:_conversation.type == TIM_GROUP]+15;
        }
    }
    return [msg heightInWidth:tableView.bounds.size.width inStyle:_conversation.type == TIM_GROUP]+15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSInteger testIndex = 0;
    
    DebugLog(@"-------------->_messageList.count = %ld", (long)_messageList .count);
    
    NSString *font = [NSString stringWithFormat:@"-------------->cellForRowAtIndexPath crash font(%ld)", (long)testIndex];
    DebugLog(@"%@", font);
    
    IMAMsg *msg = [_messageList objectAtIndex:indexPath.row];

    NSString *rail = [NSString stringWithFormat:@"-------------->cellForRowAtIndexPath crash font(%ld)", (long)testIndex];
    DebugLog(@"%@", rail);
    
    UITableViewCell<TIMElemAbleCell> *cell = [msg tableView:tableView style:[_receiver isC2CType] ? TIMElemCell_C2C : TIMElemCell_Group];
    [cell configWith:msg];
    return cell;
    
}


#pragma mark- BaseCell deleteCell
//- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell<TIMElemAbleCell> *cell = [tableView cellForRowAtIndexPath:indexPath];
//    BOOL showMenu = [cell canShowMenu];
//    if (showMenu)
//    {
//        [cell showMenu];
//    }
//    return showMenu;
//}
//
//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    UITableViewCell<TIMElemAbleCell> *cell = [tableView cellForRowAtIndexPath:indexPath];
//    BOOL can = [cell canPerformAction:action withSender:sender];
//    return can;
//}
//
//- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    // do nothing
//}
//

@end
