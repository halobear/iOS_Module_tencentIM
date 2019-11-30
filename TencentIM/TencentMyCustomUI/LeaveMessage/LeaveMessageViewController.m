//
//  LeaveMessageViewController.m
//  HaloQuickWedding
//
//  Created by HaloBearliu on 2018/12/27.
//  Copyright © 2018年 liujidanjob@163.com. All rights reserved.
//

#import "LeaveMessageViewController.h"
#import "LeaveMessageTableViewCell.h"
#import "HaloQuickWedding-Swift.h"

@interface LeaveMessageViewController ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
}
@property (nonatomic ,strong)UILabel *messageLabel;
@property (nonatomic ,strong)UITextView *messageTextView;
@property (nonatomic ,strong)UILabel *textLabel;
@property (nonatomic ,strong)UILabel *messageLabel2;
@property (nonatomic ,strong)UIButton *submitBtn;

@property (nonatomic, strong) NSString *mName;
@property (nonatomic, strong) NSString *mContact;

@end

@implementation LeaveMessageViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackGroundColor_white;
    
    self.view.userInteractionEnabled = true;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    [self createUI];
}

- (void)createUI {
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, kSystem_Height, kScreen_Width, 198+15)];
    headerView.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 15)];
    titleLabel.text = @"请留言*";
    titleLabel.textColor = kTextColor_Black;
    titleLabel.font = kSystemFontSize(15);
    [headerView addSubview:titleLabel];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(20, titleLabel.bottom+15, kScreen_Width-40, 120)];
    bgView.backgroundColor = kBackGroundColor_gray;
    bgView.layer.cornerRadius = 3;
    [headerView addSubview:bgView];
    
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, bgView.width-20, bgView.height-20)];
    self.messageTextView.font = [UIFont systemFontOfSize:15];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.delegate = self;
    self.messageTextView.tintColor = kColorRed;
    [bgView addSubview:self.messageTextView];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.messageTextView.width,  [self calcLabelHeight:@"请留下你想要咨询的问题" font:[UIFont systemFontOfSize:15] width:CGRectGetWidth(self.messageTextView.frame)])];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [[UIColor alloc] initWithRed:188/255.0 green:188/255.0 blue:193/255.0 alpha:1.0];
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.textLabel.numberOfLines = 0;
    self.textLabel.text = @"请留下你想要咨询的问题";
    [self.messageTextView addSubview:self.textLabel];
    
    UILabel *titleLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(20, bgView.bottom+30, 100, 15)];
    titleLabel1.text = @"联系方式";
    titleLabel1.textColor = kTextColor_Black;
    titleLabel1.font = kSystemFontSize(15);
    [headerView addSubview:titleLabel1];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kSystem_Height, kScreen_Width, kScreen_Height-kSystem_Height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackGroundColor_white;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, iphonexOffvalue+55, 0);
    [self.view addSubview:_tableView];
    
    _tableView.tableHeaderView = headerView;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-iphonexOffvalue-55, kScreen_Width, iphonexOffvalue+55)];
    bottomView.backgroundColor = kBackGroundColor_white;
    [self.view addSubview:bottomView];
    
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.submitBtn.frame = CGRectMake(20, 8, kScreen_Width-40, 40);
    self.submitBtn.layer.cornerRadius = 3;
    self.submitBtn.backgroundColor = UIColor.whiteColor;
    [self.submitBtn addGradualColor:@[kColorRed,kColorPink] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.submitBtn setTitle:NSLocalizedString(@"title.leaving", nil) forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.submitBtn];
    
    __weak typeof(self) weakSelf = self;
    [self createNavBarNavTitle:@"请留言" back:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    self.navBottomImageView.hidden = NO;
    
}

- (void)tapAction {
    [self.messageTextView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.textLabel.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.textLabel.text = @"请留下您想要咨询的问题";
    }
}

- (void)submitAction: (UIButton *)sender {
    if ([_messageTextView.text replaceOccurrencesOfString].length == 0) {
        [HBAlertUtils hb_showMessage:@"请留下您想要咨询的问题" inView:self.view];
        return;
    }
    
    if ([_mName replaceOccurrencesOfString].length == 0) {
        [HBAlertUtils hb_showMessage:@"请留下您的姓名" inView:self.view];
        return;
    }
    
    if ([_mContact replaceOccurrencesOfString].length == 0) {
        [HBAlertUtils hb_showMessage:@"请留下您的联系方式" inView:self.view];
        return;
    }
    
    self.mBProgressHUD = [HaloTool.sharedTool showLoadView:self.view];
    LeaveMessageApi *messageApi = [[LeaveMessageApi alloc] initWithName:_mName phone:_mContact content:_messageTextView.text];
    [messageApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *info = [request.responseJSONObject objectForKey:@"info"];
        [HBAlertUtils hb_showMessage:info inView:self.view];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *info = [request.responseJSONObject objectForKey:@"info"];
        [HBAlertUtils hb_showMessage:info inView:self.view];
    }];
    
}

- (CGFloat)calcLabelHeight: (NSString *)text font: (UIFont *)font width: (CGFloat)width {
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGRect labelRect = [text boundingRectWithSize:CGSizeMake(width, CGRectGetHeight(self.messageTextView.frame)) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    return labelRect.size.height;
}

- (void)showAlertViewControllerWithTitle: (NSString *)title {
    [self.view endEditing:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:title preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"leaveMsgCell";
    LeaveMessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[LeaveMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textField.placeholder = indexPath.section == 0 ? @"请留下您的姓名" : @"请留下您的联系方式";
    __weak LeaveMessageViewController *strongSelf = self;
    cell.backInformation = ^(NSString *information) {
        if (indexPath.section == 0) {
            strongSelf.mName = information;
        }else {
            strongSelf.mContact = information;
        }
    };
    return cell;
}

#pragma mark - Push Notification
// 键盘通知
- (void)keyboardFrameChange: (NSNotification *)notification {
    NSDictionary * userInfo =  notification.userInfo;
    NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect newFrame = [value CGRectValue];
    if (newFrame.origin.y == [UIScreen mainScreen].bounds.size.height) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_tableView.frame = CGRectMake(0, kSystem_Height, kScreen_Width, kScreen_Height-kSystem_Height);
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self->_tableView.frame = CGRectMake(0, kSystem_Height, kScreen_Width, [UIScreen mainScreen].bounds.size.height-kSystem_Height-newFrame.size.height);
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    NSLog(@"留言板dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
