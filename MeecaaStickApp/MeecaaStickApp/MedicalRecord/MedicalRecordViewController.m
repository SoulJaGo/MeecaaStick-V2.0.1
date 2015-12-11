//
//  MedicalRecordViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/19.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "MedicalRecordViewController.h"
#import "MedicalRecordCell.h"
#import "UIFolderTableView.h"
#import "MedicalRecordDetailViewController.h"
#import "AddMedicalRecordViewController.h"
#import "UpdateMedicalRecordTableViewController.h"
#import "CXPhotoBrowser.h"
#import "MJRefresh.h"


@interface MedicalRecordViewController () <UITableViewDataSource,UITableViewDelegate,UIFolderTableViewDelegate,UIAlertViewDelegate,CXPhotoBrowserDataSource,CXPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIFolderTableView *tableView;
@property (nonatomic,strong) NSMutableArray *diaryList;
/**
 *  测温历史记录
 */
@property (retain, nonatomic) NSMutableArray *historyList;
/**
 *点击的温度记录的信息
 */
@property (nonatomic,strong) NSMutableDictionary *dayDetailInfo;

@property (nonatomic,strong) NSDictionary *detailInfoDic;

/**
 *  图片展示层
 */
@property (nonatomic, strong) CXPhotoBrowser *browser;
@property (nonatomic, strong) NSMutableArray *photoDataSource;
@property (nonatomic,strong) NSMutableArray *picsArray;

@property (nonatomic,strong) UIFolderTableView *folderTableView;
/**
 *  本地页码数据
 */
@property (nonatomic,assign) int page;
@end
@implementation MedicalRecordViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.diaryList = [NSMutableArray array];
    
    //监测网络状态
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }
    //设置Nav
    [self setupNav];
    self.view.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    
    [self switchTableView];  
    
    [self.segment addTarget:self action:@selector(switchTableView) forControlEvents:UIControlEventValueChanged];
    
    //异步加载数据
    if ([[DatabaseTool shared] getDefaultMember]) { //登陆状态
        if (![[DatabaseTool shared] getDefaultMemberLastDiary]) { //没有数据的时候
            //请求网络读取数据
            if ([[HttpTool shared] isConnectInternet]) {
                [[HttpTool shared] getDefaultMemberDiaryInfoByPage:1];
            }
        } else { //数据库有数据的时候
            self.diaryList = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:1];
        }
    }
    
    //上拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreOldData)];
    footer.stateLabel.textColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1.0];
    self.tableView.footer = footer;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDiarySuccessNotification) name:@"RemoveDiarySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initDiaryDataSuccessNotification) name:@"InitDiaryDataSuccessNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initDiaryDataEndSuccessNotification) name:@"InitDiaryDataEndSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDiarySuccessNotification) name:@"AddNewDiarySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewDiarySuccessNotification) name:@"UpdateNewDiarySuccessNotification" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoveDiarySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InitDiaryDataSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InitDiaryDataEndSuccessNotification" object:nil];
}

/**
 *  加载旧的数据
 */
- (void)loadMoreOldData {
    self.page++;
    [self.tableView performClose:nil];
    if ([[HttpTool shared] isConnectInternet]) {
        NSMutableArray *array = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:self.page];
        if (array == nil || array.count == 0) { //本地没有更多的数据了
            [[HttpTool shared] getDefaultMemberDiaryInfoByPage:self.page];
        } else { //本地有更多的数据
            [self.diaryList addObjectsFromArray:array];
            [self.tableView reloadData];
            [self.tableView.footer endRefreshing];
        }
    } else {
        NSMutableArray *array = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:self.page];
        if (array != nil) {
            [self.diaryList addObjectsFromArray:array];
            [self.tableView reloadData];
            [self.tableView.footer endRefreshing];
        } else {
            [self.tableView.footer endRefreshing];
        }
        
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
        
    }
    
}

- (void)initDiaryDataSuccessNotification {
    NSMutableArray *array = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:self.page];
    if (array != nil || array.count != 0) { //没有数据
        [self.diaryList addObjectsFromArray:array];
        [self.tableView reloadData];
    }
    [self.tableView.footer endRefreshing];
}

- (void)initDiaryDataEndSuccessNotification {
    [self.tableView.footer endRefreshing];
}

- (void)removeDiarySuccessNotification {
    self.diaryList = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:1];
    self.page = 1;
    [self.tableView performClose:nil];
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"记录删除成功!"];
}

- (void)addNewDiarySuccessNotification {
    self.diaryList = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:1];
    self.page = 1;
    [self.tableView performClose:nil];
    [self.tableView reloadData];
}

- (void)updateNewDiarySuccessNotification {
    self.diaryList = [[DatabaseTool shared] getDefaultMemberDiaryFromPage:1];
    self.page = 1;
    [self.tableView performClose:nil];
    [self.tableView reloadData];
}

/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo"]];
}

- (void)switchTableView {
    if (self.segment.selectedSegmentIndex == 0) {
        [self.tableView reloadData];
    } else {        
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.historyList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *detailInfo = [self.historyList objectAtIndex:section];
    NSArray *infoList = [detailInfo objectForKey:@"detail"];
    return infoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSDictionary *detailInfo = [self.historyList objectAtIndex:section];
    NSArray *infoList = [detailInfo objectForKey:@"detail"];
    NSDictionary *dayDetailInfo = [infoList objectAtIndex:(row)];
    static NSString *MedicalRecordCellID = @"MedicalRecordCell";
    MedicalRecordCell *cell = (MedicalRecordCell *)[tableView dequeueReusableCellWithIdentifier:MedicalRecordCellID];
    if (cell == nil) {
        cell = [[MedicalRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MedicalRecordCellID];
    }
    cell.timeLabel.text = [dayDetailInfo objectForKey:@"time"];
    cell.symptonLabel.text = [dayDetailInfo objectForKey:@"symbton"];
    cell.temperatureLabel.text = [[dayDetailInfo objectForKey:@"value"] stringByAppendingString:@"℃"];
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    self.detailInfoDic = [self.historyList objectAtIndex:section];
    NSArray *infoList = [self.detailInfoDic objectForKey:@"detail"];
    NSDictionary *dayDetailInfo = [infoList objectAtIndex:(row)];
    self.dayDetailInfo = [NSMutableDictionary dictionaryWithDictionary:dayDetailInfo];
    MedicalRecordDetailViewController *medicalRecordDetailVc = [[MedicalRecordDetailViewController alloc] init];
    medicalRecordDetailVc.medicalRecordVc = self;
    //图片
    if (![[[dayDetailInfo objectForKey:@"pics"] objectAtIndex:0] isEqualToString:@""]) {
        medicalRecordDetailVc.picsArray = [dayDetailInfo objectForKey:@"pics"];
        self.picsArray = [NSMutableArray arrayWithArray:[dayDetailInfo objectForKey:@"pics"]];
    } else {
        medicalRecordDetailVc.picsArray = nil;
    }
    
       
    //描述
    medicalRecordDetailVc.desc = [dayDetailInfo objectForKey:@"desc"];
        
    UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
    self.folderTableView = folderTableView;
    [self.folderTableView openFolderAtIndexPath:indexPath WithContentView:medicalRecordDetailVc.view openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {

    } closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
        
    } completionBlock:^{
        
    }];
}

/**
 *  点击删除按钮
 */
- (void)onClickDeleteBtn {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您确认要删除么?" message:@"您确认要删除么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    } else {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        NSString *diaryId = [NSString stringWithFormat:@"%@",[self.dayDetailInfo objectForKey:@"tid"]];
        [[HttpTool shared] removeDiary:diaryId];
    }
}

/**
 *  点击修改按钮
 */
- (void)onClickUpdateBtn {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    UpdateMedicalRecordTableViewController *vc = [board instantiateViewControllerWithIdentifier:@"UpdateMedicalRecordTableViewController"];
    [vc setHidesBottomBarWhenPushed:YES];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *string = [self.dayDetailInfo objectForKey:@"date"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[string intValue] + 28800];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    vc.receivedTimeStr = confromTimespStr;
    vc.receivedTempStr = [self.dayDetailInfo objectForKey:@"value"];
    vc.receivedSymptomStr = [self.dayDetailInfo objectForKey:@"symbton"];
    vc.receivedDescriptStr = [self.dayDetailInfo objectForKey:@"desc"];
    
    vc.detailMedicalRecordInfo = self.dayDetailInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *detailInfo = [self.historyList objectAtIndex:section];
    NSString *dayInfo = [detailInfo objectForKey:@"day"];
    return dayInfo;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 103;
}

- (NSArray *)getSymptons:(NSNumber *)value{
    if (value==0) {
        return nil;
    }
    return [[GlobalTool shared] getFlagInIntergerPosition:value];
}

- (NSMutableArray *)historyList
{
    //先判断数据库中是否存在测温记录
    NSMutableArray *list = self.diaryList;
    NSMutableArray *showList = [NSMutableArray array];
    for (int i=0; i<list.count; i++) {
        NSDictionary *dayHistory = [list objectAtIndex:i];
        NSNumber *date = [dayHistory objectForKey:@"date"];
        NSNumber *tid = [dayHistory objectForKey:@"id"];
        NSNumber *member_id = [dayHistory objectForKey:@"member_id"];
        NSArray *pics = [dayHistory objectForKey:@"pics"];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:[date longLongValue]];
        NSDateFormatter *dateFormater = [NSDateFormatter new];
        dateFormater.dateFormat = @"yyyy.M.d";
        NSString *dayStr = [dateFormater stringFromDate:dateValue];
        
        NSDateFormatter *timeFormater = [[NSDateFormatter alloc] init];
        timeFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [timeFormater setDateFormat:@"h:mm a"];
        NSString *timeStr = [timeFormater stringFromDate:dateValue];
        
        int photo_count = [[dayHistory objectForKey:@"photo_count"] intValue];
        
        NSMutableArray *dayDiary;
        for (int j=0; j<showList.count; j++) {
            NSDictionary *_dayDiary = [showList objectAtIndex:j];
            NSString *_dayStr = [_dayDiary objectForKey:@"day"];
            if ([_dayStr isEqualToString:dayStr]) {
                dayDiary = [_dayDiary objectForKey:@"detail"];
                break;
            }
        }
        if (dayDiary==nil) {
            dayDiary = [NSMutableArray array];
            NSMutableDictionary *showDict = [NSMutableDictionary dictionary];
            [showDict setObject:dayStr forKey:@"day"];
            [showDict setObject:dayDiary forKey:@"detail"];
            [showList addObject:showDict];
        }
        
        NSMutableDictionary *timeDiary = [NSMutableDictionary dictionary];
        NSString *temperature = [dayHistory objectForKey:@"temperature"];
        [timeDiary setObject:temperature forKey:@"value"];
        
        NSString *description = [dayHistory objectForKey:@"description"];
        
        NSString *symptonStr = @"";
        NSArray *symptons = [self getSymptons:[dayHistory objectForKey:@"symptoms"]];
        if (symptons==nil||symptons.count==0) {
            symptonStr = @"";
        }
        else{
            for (int i=0; i<symptons.count; i++) {
                NSNumber *tag = [symptons objectAtIndex:i];
                NSString *name = [[GlobalTool shared] getSymptonNameByTag:tag];
                symptonStr = [symptonStr stringByAppendingString:[NSString stringWithFormat:@"%@",name]];
                symptonStr = [symptonStr stringByAppendingString:@" "];
            }
        }
        [timeDiary setObject:symptonStr forKey:@"symbton"];
        [timeDiary setObject:timeStr forKey:@"time"];
        [timeDiary setObject:date forKey:@"date"];
        [timeDiary setObject:[NSNumber numberWithInt:photo_count] forKey:@"photo_count"];
        [timeDiary setObject:tid forKey:@"tid"];
        [timeDiary setObject:description forKey:@"desc"];
        [timeDiary setObject:member_id forKey:@"member_id"];
        [timeDiary setObject:pics forKey:@"pics"];
        [dayDiary addObject:timeDiary];
    }
    
    _historyList = showList;
    return _historyList;
}

/**
 *  点击添加按钮
 */
- (IBAction)onClickAddDiary {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    AddMedicalRecordViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddMedicalRecordViewController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  点击图片
 */
- (void)tapImageView:(UITapGestureRecognizer *)recognizer {
    UIImageView *imageView = (UIImageView *)[recognizer view];
    self.browser = [[CXPhotoBrowser alloc] initWithDataSource:self delegate:self];
    self.photoDataSource = [NSMutableArray array];
    
    for (int i = 0; i < self.picsArray.count; i++) {
        CXPhoto *photo = [[CXPhoto alloc] initWithURL:[NSURL URLWithString:self.picsArray[i]]];
        [self.photoDataSource addObject:photo];
    }
    [self.browser setInitialPageIndex:imageView.tag];
    [self presentViewController:self.browser animated:NO completion:^{
        [self.folderTableView performClose:nil];
    }];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(CXPhotoBrowser *)photoBrowser
{
    return [self.photoDataSource count];
}

- (id <CXPhotoProtocol>)photoBrowser:(CXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photoDataSource.count)
        return [self.photoDataSource objectAtIndex:index];
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView performClose:nil];
}
@end
