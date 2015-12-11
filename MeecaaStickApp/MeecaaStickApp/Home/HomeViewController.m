//
//  HomeViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/18.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeNavigationController.h"
#import "HttpTool.h"
#import "MessageViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "UseBeanCheckViewController.h"
#import "UseStickCheckViewController.h"
@interface HomeViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSUserDefaults *userDefaults;
}
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

//@property (nonatomic,assign)NSInteger myStyle;
/**
 *	体温棒测温的界面，三个可以滑动的页面
 */
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic,strong)UIScrollView *scrollView;

/**
 *	温豆测温的界面，是一个UIView
 */
@property (nonatomic,strong) UseBeanCheckViewController *beanView;
/**
 *	体温棒测温界面
 */
@property (nonatomic,strong) UseStickCheckViewController *stickView;
/**
 *	没有选择任何设备的页面
 */
@property(nonatomic,strong)UIView *noDeviceView;
/**
 *	设备列表的tableView
 */
@property(nonatomic,strong)UITableView *deviceListTV;
/**
 *	导航条上用于显示按钮的view
 */
@property (weak, nonatomic) IBOutlet UIView *NavItemView;

@property (weak, nonatomic) IBOutlet UIButton *selectDeviceBtn;//导航条上添加一个选择设备的button
@property (weak, nonatomic) IBOutlet UIImageView *pullImageView;//选择设备按钮旁边下拉箭头

- (IBAction)onClickOnceCheck;
@end
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    //设置Nav
    [self setupNav];
    
    if ([[HttpTool shared] isConnectInternet]) {
        //监测版本升级
        [self checkLastVersion];
    }
    
    //设置头像
    [self setupIcon];

    
    /**
     *	12 / 3 开始在首页添加scrollView
     *
     *	@return
     */
    self.NavItemView.backgroundColor = NAVIGATIONBAR_BACKGROUND_COLOR;
    userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger myStyle = [userDefaults integerForKey:@"myInteger"];
    NSLog(@"%ld",(long)myStyle);
    
    if (myStyle == 1) {
        [self setUpStickScrollView];
    }else if (myStyle == 2){
        [self SetUpBeanView];
    }else if (myStyle == 0){
        [self setUpNoDeviceView];
    }
    
    /**
     设备列表
     */
    
    self.deviceListTV = [[UITableView alloc] initWithFrame:CGRectMake(self.view.center.x - 100, -240, 200, 240) style:UITableViewStylePlain];
    self.deviceListTV.scrollEnabled = NO;
    self.deviceListTV.delegate = self;
    self.deviceListTV.dataSource = self;
    [self.view addSubview:self.deviceListTV];
}
- (IBAction)selectDevice {
    [self.view bringSubviewToFront:self.deviceListTV];
    self.pullImageView.center = CGPointMake(self.pullImageView.center.x, self.pullImageView.center.y);
    if (self.deviceListTV.frame.origin.y == 64) {
        //收起
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.deviceListTV.frame = CGRectMake(self.view.center.x - 100, -240, 200, 240);
            self.pullImageView.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            
        }];
    }else if (self.deviceListTV.frame.origin.y == -240){
        //展开
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.deviceListTV.frame = CGRectMake(self.view.center.x - 100, 64, 200, 240);
            self.pullImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)setUpStickScrollView{
    NSLog(@"设备设置为棒子");
    int myInteger = 1;
    userDefaults = [NSUserDefaults standardUserDefaults];
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setInteger:myInteger forKey:@"myInteger"];
    
    [userDefaults synchronize];
    self.NavItemView.backgroundColor = [UIColor clearColor];

//    [self.scrollView removeFromSuperview];
    [self.stickView.view removeFromSuperview];
    [self.noDeviceView removeFromSuperview];
    [self.beanView.view removeFromSuperview];
    
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    self.stickView = [board instantiateViewControllerWithIdentifier:@"UseStickCheckViewController"];
    self.stickView.view.frame =  CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 49);
    self.stickView.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.stickView.view];
    
    /*
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 149)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height - 149);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator= NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    //往滚动视图上添加一组图片
    for (int i = 0; i < 3; i++) {
        UIImage *_image = [UIImage imageNamed:@"set_about_icon"];
        UIImageView *_imageView = [[UIImageView alloc] initWithImage:_image];
        _imageView.frame = CGRectMake(self.view.frame.size.width * i + 30, 30, 45, 45);
        [_scrollView addSubview:_imageView];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * i + 100, 30, 200, 50)];
        timeLabel.backgroundColor  = [UIColor redColor];
        timeLabel.text = @"这是体温棒测温时间的label";
        [_scrollView addSubview:timeLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.view.frame.size.width * i + 30, 230, 250, 45);
        button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(clickToOnceCheck) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            [button setTitle:@"点击开始快速测体温" forState:UIControlStateNormal];
        }else if (i == 1){
            [button setTitle:@"点击开始温度检测" forState:UIControlStateNormal];
        }else if (i == 2){
            [button setTitle:@"点击开始基础体温" forState:UIControlStateNormal];
        }
        [_scrollView addSubview:button];
    }
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.center.x - 50, 64, 100, 36)];
    _pageControl.numberOfPages = 3;
    //为分页数点设置颜色(设置没有选中的分页数点的颜色)
    _pageControl.pageIndicatorTintColor = NAVIGATIONBAR_BACKGROUND_COLOR;
    //为选中的分页数点设置颜色
    _pageControl.currentPageIndicatorTintColor = [UIColor cyanColor];
    _pageControl.currentPage = 0;
    [_pageControl addTarget:self action:@selector(clickToChangePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.scrollView];
    */
    [self.selectDeviceBtn setTitle:@"米开体温棒" forState:UIControlStateNormal];
}

- (void)setUpNoDeviceView{
    self.NavItemView.backgroundColor = [UIColor clearColor];

    self.noDeviceView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.noDeviceView.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 200)/2, 64 + 50, 200, 200)];
    [imageView setImage:[UIImage imageNamed:@"yuanquan"]];
    [self.noDeviceView addSubview:imageView];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = CGRectMake((self.view.bounds.size.width - 120)/2, CGRectGetMaxY(imageView.frame) + 50, 120, 120);
    
    [btn setBackgroundImage:[UIImage imageNamed:@"anniu"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(onClickSelect) forControlEvents:UIControlEventTouchUpInside];
    
    [self.noDeviceView addSubview:btn];
    
    [self.view addSubview:self.noDeviceView];
    [self.selectDeviceBtn setTitle:@"米开设备" forState:UIControlStateNormal];

}

- (void)onClickSelect {
    [SVProgressHUD showInfoWithStatus:@"请选择设备!"];
}

- (void)SetUpBeanView{
    NSLog(@"222");
    
    int myInteger = 2;
    //将数据全部存储到NSUserDefaults中
    userDefaults = [NSUserDefaults standardUserDefaults];
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setInteger:myInteger forKey:@"myInteger"];
    
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    NSLog(@"设备设置为温豆");
    
    self.NavItemView.backgroundColor = [UIColor clearColor];

    [self.scrollView removeFromSuperview];
    [self.pageControl removeFromSuperview];
    [self.noDeviceView removeFromSuperview];
    
    [self.beanView.view removeFromSuperview];
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    self.beanView = [board instantiateViewControllerWithIdentifier:@"UseBeanCheckViewController"];
    self.beanView.view.frame =  CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 49);
    self.beanView.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.beanView.view];
    
    [self.selectDeviceBtn setTitle:@"米开温豆" forState:UIControlStateNormal];

}

////实现clickToChangePage方法
//- (void)clickToChangePage:(UIPageControl *)sender{
//    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * sender.currentPage, 0) animated:YES];//带有动画效果
//}
//
////当scrollView上的视图已经减速完成时触发该方法(该方法不一定触发) *****
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    //得到分页数的下标
//    _pageControl.currentPage = scrollView.contentOffset.x / self.view.frame.size.width;
//    
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

/**
 *  监测版本升级
 */
- (void)checkLastVersion
{
    //获取版本信息数据
    NSMutableDictionary *versionDict = [[HttpTool shared] getLastVersion];
    
    NSNumber *status = [versionDict objectForKey:@"status"];
    
    if ([status isEqualToNumber:@0]) { //状态码为0表示不更新
        return;
    } else {
        
    }
    
}

/**
 *  设置头像
 */
- (void)setupIcon {
    self.iconImageView.layer.borderColor = NAVIGATIONBAR_BACKGROUND_COLOR.CGColor;
    self.iconImageView.layer.borderWidth = 5.0f;
    NSMutableDictionary *memberInfoDict = [[DatabaseTool shared] getDefaultMember];
    if (memberInfoDict != nil) {
        if ([memberInfoDict[@"avatar"] isEqualToString:@""] || memberInfoDict == nil) {
            [self.iconImageView setImage:[UIImage imageNamed:@"home_member_icon"]];
        } else {
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:memberInfoDict[@"avatar"]] placeholderImage:[UIImage imageNamed:@"home_member_icon"]];
        }
    }
}

/**
 *  设置Nav
 */
- (void)setupNav {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
    
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}


#pragma mark -- 顶部下拉列表的tabelView的代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 此处可以写成自定义的cell,定义label 和 imageView
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.selected = NO;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"               米开体温棒";
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"medical_go_icon"]];
        imageView.frame = CGRectMake(10, 10, 60, 60);
        //放在cell的内容视图上显示
        [cell.contentView addSubview:imageView];
    }else if (indexPath.section == 0 && indexPath.row == 1){
        cell.textLabel.text = @"               米开温豆";
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"medical_go_icon"]];
        imageView.frame = CGRectMake(10, 10, 60, 60);
        //放在cell的内容视图上显示
        [cell.contentView addSubview:imageView];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self setUpStickScrollView];
        [self selectDevice];
    }else if (indexPath.section == 0 && indexPath.row == 1){
        [self SetUpBeanView];
        [self selectDevice];
    }
}

/** 这是原来的页面里的方法
 *  点击一次测温按钮
 */
- (IBAction)onClickOnceCheck {
    if ([self isHeadsetPluggedIn]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UseHardwareCheckNavigationController"];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请将体温棒连接手机！"];
    }
}
/**
 *	这是新的页面里的方法
 */
- (void)clickToOnceCheck{
    if ([self isHeadsetPluggedIn]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UseHardwareCheckNavigationController"];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请将体温棒连接手机！"];
    }
}

/**
 *	点击跳转温豆的测温页面
 */
- (void)clickToBeanView{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    UIViewController *vc = [board instantiateViewControllerWithIdentifier:@"UseBeanCheckViewController"];
//    [self presentViewController:vc animated:NO completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
//轻拍响应的方法
- (void)tapGestureRecognizer:(UITapGestureRecognizer *)sender{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
    UIViewController *vc = [board instantiateViewControllerWithIdentifier:@"UserNavigationController"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

/**
 *  判断耳机是否插入
 */
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}
@end
