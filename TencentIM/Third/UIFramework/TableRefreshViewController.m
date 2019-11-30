//
//  TableRefreshViewController.m
//  CommonLibrary
//
//  Created by Alexi on 15-2-5.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import "TableRefreshViewController.h"
#import "HBRefreshHeader.h"
#import "RefreshView.h"
#import "ImageTitleButton.h"

@implementation RequestPageParamItem

- (instancetype)init
{
    if (self = [super init])
    {
        _pageIndex = 0;
        _pageSize = 20;
        _canLoadMore = YES;
    }
    return self;
}


@end

@implementation TableRefreshViewController

- (void)initialize
{
    [super initialize];
    _clearsSelectionOnViewWillAppear = YES;
    _pageItem = [[RequestPageParamItem alloc] init];
}

- (void)addHeaderView
{
    self.headerView = [[HeadRefreshView alloc] init];
}

- (void)pinHeaderAndRefesh
{
    [self pinHeaderView];
    [self refresh];
}

- (void)addFooterView
{
    self.footerView = [[FootRefreshView alloc] init];
}

- (void)addRefreshScrollView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kSystem_Height, kScreen_Width, kScreen_Height-kSystem_Height-iphonexOffvalue-50) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kClearColor;
    _tableView.scrollsToTop = YES;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    
    HBRefreshHeader *mj_header = [HBRefreshHeader headerWithRefreshingBlock:^{
        [self pinHeaderAndRefesh];
    }];
    mj_header.bgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F3"];
    self.tableView.mj_header = mj_header;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.refreshScrollView = _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    if (_tableView)
    {
        NSIndexPath *selected = [_tableView indexPathForSelectedRow];
        if (selected)
        {
            [_tableView deselectRowAtIndexPath:selected animated:animated];
        }
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc]init];
}

- (BOOL)hasData
{
    BOOL has = _datas.count != 0;
    _tableView.separatorStyle = has ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    return has;
}

- (void)addNoDataView
{
    //    ImageTitleButton *btn = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    //    [btn setImage:[UIImage imageNamed:@"icon_warm"] forState:UIControlStateNormal];
    //    [btn setTitleColor:kGray3 forState:UIControlStateNormal];
    //    btn.titleLabel.font = kFontH1;
    //    btn.enabled = NO;
    //    //    text.textAlignment = NSTextAlignmentCenter;
    //    [self.view addSubview:btn];
    //    _noDataView = btn;
    //    _noDataView.hidden = YES;
}

- (BOOL)needFollowScrollView
{
    return NO;
}

- (void)reloadData
{
    //    BOOL has = [self hasData];
    //    _noDataView.hidden = has;
    //    if (!has)
    //    {
    //        [self showNoDataView];
    //    }
    [_tableView reloadData];
    [self allLoadingCompleted];
    
    //    if ([self needFollowScrollView])
    //    {
    //        if (_tableView.contentSize.height > 2 * _tableView.bounds.size.height)
    //        {
    //            [self followScrollView:_tableView];
    //        }
    //        else
    //        {
    //            [self followScrollView:nil];
    //        }
    //    }
}

- (void)showNoDataView
{
    
}

- (void)allLoadingCompleted
{
    [super allLoadingCompleted];
    
    BOOL has = [self hasData];
    _noDataView.hidden = has;
    if (!has)
    {
        [self showNoDataView];
    }
}


@end
