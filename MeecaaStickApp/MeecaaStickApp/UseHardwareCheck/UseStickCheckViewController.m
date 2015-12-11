//
//  UseStickCheckViewController.m
//  MeecaaStickApp
//
//  Created by mciMac on 15/12/9.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "UseStickCheckViewController.h"
#import "LargerCircularProgressView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
/**
 *  控制音量所需库文件
 */
#import <MediaPlayer/MPVolumeView.h>
#import "TestDecoder.h"
#import "Function.h"

@interface UseStickCheckViewController ()<UIScrollViewDelegate> {
    UILabel *temperatureLabelOne;
    UILabel *temperatureLabelTwo;
    UILabel *temperatureLabelThree;
    
    UILabel *timeLabelOne;
    UILabel *timeLabelTwo;
    UILabel *timeLabelThree;
    
    LargerCircularProgressView *progressView;
    
    UIImageView *circularImageViewOne;
    UIImageView *circularImageViewTwo;
    UIImageView *circularImageViewThree;
    
    UIImageView *startViewOne;
    UIImageView *startViewTwo;
    UIImageView *startViewThree;
    
    /**
     *	12 / 10 周四
     */
    //录音器
    AVAudioRecorder *recorder;
    //播放器
    AVAudioPlayer *player;
    //录音参数设置
    NSDictionary *recorderSettingsDict;
    
    //定时器
    NSTimer *timer;
    //图片组
    NSMutableArray *volumImages;
    double lowPassResults;
    
    //录音名字
    NSString *playName;
    //录音计数器
    int recordCount;
    //测温类型
    int checkType;
    
    NSTimer *timer2;
    //音频播放器
    AVAudioPlayer *avAudioPlayer;
    //播放计数器
    int playCount;
    
    NSTimer *timer3; //    定时采样
    
    // float  timercount;
    //测温时间计数器
    int timercount;
    //温度保存记录临时字符串
    NSString *strStoreTemp;
    
    //初始化的温度值，用于给新算法记录温度
    double temperature[20];
    
    NSTimer *animTimer;
    
    double shakeX;
    
    int bcheck_count;
    BOOL bcheck_flag;
    float dT1;
    
    BOOL press;
    int flag;
}

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) MMDrawerController * drawerController;


@property (nonatomic,assign) int quickTimeCount;//计数次数

@property (nonatomic,assign) int normalErrorCount;//常规测温错误次数
@end

@implementation UseStickCheckViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setUpView];
    
    
    /**
     *	12 / 10
     */
    //计数次数
    progressView = [[LargerCircularProgressView alloc] initWithFrame:CGRectMake(8, 8, 184, 184)];
//    [circularImageViewOne addSubview:progressView];
//    [circularImageViewTwo addSubview:progressView];
//    [circularImageViewTwo addSubview:progressView];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressChanged) userInfo:nil repeats:NO];
    
    self.quickTimeCount = 0;
    
    /*保持屏幕常亮*/
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    
    //录音设置
    recorderSettingsDict =[[NSDictionary alloc] initWithObjectsAndKeys:
                           //                                         [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                           /*设置录音格式*/
                           [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,                           //                                         [NSNumber numberWithInt:1000.0],AVSampleRateKey,
                           /*设置录音采样率*/
                           [NSNumber numberWithInt:44100.0],AVSampleRateKey,
                           //                                         [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                           /*通道的数目,1单声道,2立体声*/
                           [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                           //                                         [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                           /*每个采样点位数,分为8、16、24、32*/
                           [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                           /*是否使用浮点数采样*/
                           [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                           /*音频质量*/
                           [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,
                           nil];
    
    //不停止音乐播放
    NSString *string = [[NSBundle mainBundle] pathForResource:@"once_100ms_on_100ms_off" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:string];
    NSError *error = nil;
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    avAudioPlayer.volume = 1;//设置音量最大
    avAudioPlayer.numberOfLoops = 1;//设置循环次数
    [avAudioPlayer prepareToPlay];//准备播放
    
    bcheck_count = 0;
    bcheck_flag = false;
    
    if ([[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 4S"]) { //如果是4S并且系统版本小于8.0调整音量为85%
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
            [self setPhoneVolume:0.85f];
        } else {
            [self setPhoneVolume:1.0f];
        }
    } else {
        [self setPhoneVolume:1.0f];
    }
    
    
    /**
     *	12 / 11
     *
     *	@return
     */
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if(!available) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopCheck];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [SVProgressHUD showInfoWithStatus:@"请在“设置-隐私-麦克风”选项中允许体温棒访问您的麦克风"];
                });
                return;
            }
        }];
    }
}
- (void)progressChanged{
    progressView.progress += 0.001;
    if (progressView.progress > 1.0f){
        progressView.progress = 0.0f;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //监听调节音量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    /*监听拔出耳机*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self stopCheck];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}



- (void)setUpView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 37, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 149)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height - 149);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator= NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    
    //往滚动视图上添加一组图片
    UIImage *_image = [UIImage imageNamed:@"yuanquan"];
    circularImageViewOne = [[UIImageView alloc] initWithImage:_image];
    circularImageViewTwo = [[UIImageView alloc] initWithImage:_image];
    circularImageViewThree = [[UIImageView alloc] initWithImage:_image];
    circularImageViewOne.frame = CGRectMake((self.view.frame.size.width - 200) / 2, 30, 200, 200);
    circularImageViewTwo.frame = CGRectMake(kScreen_Width + (self.view.frame.size.width - 200) / 2, 30, 200, 200);
    circularImageViewThree.frame = CGRectMake(kScreen_Width * 2 + (self.view.frame.size.width - 200) / 2, 30, 200, 200);
    [self.scrollView addSubview:circularImageViewOne];
    [self.scrollView addSubview:circularImageViewTwo];
    [self.scrollView addSubview:circularImageViewThree];
    
    //添加时间label
    timeLabelOne = [[UILabel alloc] initWithFrame:CGRectMake(240, 0, 120, 30)];
    timeLabelTwo = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width + 240, 0, 120, 30)];
    timeLabelThree = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width * 2 + 240, 0, 120, 30)];
    timeLabelOne.textColor = timeLabelTwo.textColor = timeLabelThree.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
    timeLabelOne.text = timeLabelTwo.text = timeLabelThree.text = @"00.00";
    timeLabelOne.font = timeLabelTwo.font = timeLabelThree.font = [UIFont systemFontOfSize:30];
    [_scrollView addSubview:timeLabelThree];
    [_scrollView addSubview:timeLabelTwo];
    [_scrollView addSubview:timeLabelOne];
    
    //添加温度label
    temperatureLabelOne = [[UILabel alloc] initWithFrame:CGRectMake((200 - 130) / 2, 70, 130, 40)];
    temperatureLabelTwo = [[UILabel alloc] initWithFrame:CGRectMake((200 - 130) / 2, 70, 130, 40)];
    temperatureLabelThree = [[UILabel alloc] initWithFrame:CGRectMake((200 - 130) / 2, 70, 130, 40)];
    temperatureLabelOne.text = temperatureLabelThree.text = temperatureLabelTwo.text = @"--.-℃";
    temperatureLabelOne.textAlignment = temperatureLabelThree.textAlignment = temperatureLabelTwo.textAlignment = NSTextAlignmentCenter;
    temperatureLabelOne.font = temperatureLabelTwo.font =temperatureLabelThree.font = [UIFont systemFontOfSize:36];
    temperatureLabelOne.textColor = temperatureLabelTwo.textColor =temperatureLabelThree.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
    [circularImageViewOne addSubview:temperatureLabelOne];
    [circularImageViewTwo addSubview:temperatureLabelTwo];
    [circularImageViewThree addSubview:temperatureLabelThree];
    
    //添加测温类型label
    
    //添加开始按钮
    UIImage *start = [UIImage imageNamed:@"anniu"];
    startViewOne = [[UIImageView alloc] initWithImage:start];
    startViewTwo = [[UIImageView alloc] initWithImage:start];
    startViewThree = [[UIImageView alloc] initWithImage:start];
    startViewOne.frame = CGRectMake((kScreen_Width - 120) / 2, 260, 120, 120);
    startViewTwo.frame = CGRectMake(kScreen_Width + (kScreen_Width - 120) / 2, 260, 120, 120);
    startViewThree.frame = CGRectMake(kScreen_Width * 2 + (kScreen_Width - 120) / 2, 260, 120, 120);
    startViewOne.userInteractionEnabled = startViewTwo.userInteractionEnabled = startViewThree.userInteractionEnabled = YES;
    [startViewOne addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToOnceCheck)]];
    [startViewTwo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToNormalCheck)]];
    [startViewThree addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToQuickCheck)]];
    [_scrollView addSubview:startViewOne];
    [_scrollView addSubview:startViewTwo];
    [_scrollView addSubview:startViewThree];
    
    for (int i = 0; i < 3; i++) {
//        circularImageView = [[UIImageView alloc] initWithImage:_image];
//        circularImageView.frame = CGRectMake(self.scrollView.frame.size.width * i + (self.view.frame.size.width - 200) / 2, 30, 200, 200);
//        [_scrollView addSubview:circularImageView];
        
//        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i + 240, 0, 120, 30)];
//        timeLabel.tag = 100 + i;
//        timeLabel.textColor  = NAVIGATIONBAR_BACKGROUND_COLOR;
//        timeLabel.text = @"00.00";
//        timeLabel.font = [UIFont systemFontOfSize:30];
//        [_scrollView addSubview:timeLabel];
        
//        temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake((circularImageView.frame.size.width - 100) / 2, 70, 100, 40)];
////        temperatureLabel.center = _imageView.center;
//        temperatureLabel.tag  = 1000 + i;
//        temperatureLabel.text = @"--.-℃";
//        temperatureLabel.textAlignment = NSTextAlignmentCenter;
//        temperatureLabel.font = [UIFont systemFontOfSize:30];
//        temperatureLabel.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
//        
//        [circularImageView addSubview:temperatureLabel];
        
        
//        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake((circularImageView.frame.size.width - 80) / 2, 110, 80, 40)];
//        typeLabel.tag  = 10000 + i;
//        typeLabel.textAlignment = NSTextAlignmentCenter;
//        typeLabel.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
//        if (typeLabel.tag == 10000) {
//            typeLabel.text = @"常规测温";
//        }else if (typeLabel.tag == 10001){
//            typeLabel.text = @"快速测温";
//        }
//        [circularImageView addSubview:typeLabel];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(self.view.frame.size.width * i + 30, 230, 250, 45);
//        button.backgroundColor = [UIColor redColor];
//        [button addTarget:self action:@selector(clickToOnceCheck) forControlEvents:UIControlEventTouchUpInside];
//        if (i == 0) {
//            [button setTitle:@"点击开始快速测体温" forState:UIControlStateNormal];
//        }else if (i == 1){
//            [button setTitle:@"点击开始温度检测" forState:UIControlStateNormal];
//        }else if (i == 2){
//            [button setTitle:@"点击开始基础体温" forState:UIControlStateNormal];
//        }
        
//        UIImage *start = [UIImage imageNamed:@"anniu"];
//        UIImageView *startView = [[UIImageView alloc] initWithImage:start];
//        startView.frame = CGRectMake(self.scrollView.frame.size.width * i + (self.view.frame.size.width - 120) / 2, 260, 120, 120);
//        startView.userInteractionEnabled = YES;
//        startView.tag = i;
//        [startView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToOnceCheck)]];
//        [_scrollView addSubview:startView];
        
    }
    [self.pageControl addTarget:self action:@selector(clickToChangePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.scrollView];
}
//实现clickToChangePage方法
- (void)clickToChangePage:(UIPageControl *)sender{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * sender.currentPage, 0) animated:YES];//带有动画效果
}

//当scrollView上的视图已经减速完成时触发该方法(该方法不一定触发) *****
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //得到分页数的下标
    self.pageControl.currentPage = scrollView.contentOffset.x / self.view.frame.size.width;
}


#pragma mark -0-0 下面是体温棒测温的方法
- (void)clickToOnceCheck{
    //常规测温错误次数
    self.normalErrorCount = 0;
    
    if ([self isHeadsetPluggedIn]) {
        if (flag == 1) {
            return;
        }
        [self onClickCheck];
        [circularImageViewOne addSubview:progressView];
        [NSTimer scheduledTimerWithTimeInterval:0.1818181818 target:self selector:@selector(progressChanged) userInfo:nil repeats:YES];
        
        flag = 1;
        
    } else {
        [SVProgressHUD showErrorWithStatus:@"请将体温棒连接手机！"];
    }
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

/**
 *  设置音量
 */
- (void)setPhoneVolume:(float)volume{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider *volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // retrieve system volume
    //    float systemVolume = volumeViewSlider.value;
    
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:volume animated:NO];
    
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}


/**
 *	开始录音
 */
- (void)onClickCheck{
    /*删除原有的raw文件*/
    [self deleteTempFiles];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    timercount = 0;
    strStoreTemp=@"";
    
    /*每隔一秒执行一次*/
    timer3 = [NSTimer scheduledTimerWithTimeInterval: 1
                                              target: self
                                            selector: @selector(handleTimer:)
                                            userInfo: nil
                                             repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer3 forMode:NSRunLoopCommonModes];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    playName = [NSString stringWithFormat:@"%@/play_%lli.raw", docDir,date];//创建录音文件
    [self play];
}


/**
 *  开始播放
 */
- (void)play{
    /*播放计数*/
    playCount = 0;
    
    /*每0.1秒执行一次*/
    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSRunLoopCommonModes];
    /*播放音乐*/
    [avAudioPlayer play];
}

-(void)playTimer:(NSTimer*)timer_{
    /*播放计数*/
    playCount++;
    /*计数两次之后停止播放音乐开始录音*/
    if (playCount>=2) {   //这个是播放时间的 先不要改动
        playCount = 0;
        /**
         * 2015-09-24 SoulJa
         *  不停止音频播放
         */
        //[avAudioPlayer stop];
        [timer2 invalidate];//移除定时器timer2
        timer2 = nil;
        [self downAction];
    }
}
/**
 *  按下录音按键
 */
- (void)downAction{
    //按下录音
    if ([self canRecord]) {
        
        NSError *error = nil;
        //必须真机上测试,模拟器上可能会崩溃
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:playName] settings:recorderSettingsDict error:&error];
        
        if (recorder) {
            /*录音计数器*/
            recordCount = 0;
            /*是否启用音频测量*/
            recorder.meteringEnabled = YES;
            
            /*准备录音*/
            [recorder prepareToRecord];
            /*开始录音*/
            [recorder record];
            //启动定时器
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
        } else
        {
            NSLog(@"Error:[4.4s])");
            
        }
    }
}


//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}

/**
 *  处理录音时间
 */
-(void)levelTimer:(NSTimer*)timer_
{
    //call to refresh meter values刷新平均和峰值功率,此计数是以对数刻度计量的,-160表示完全安静，0表示最大输入值
    [recorder updateMeters];
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
    //    NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
    /*录音计数大于2时*/
    if (recordCount>=2) {   //修改了此处加大了录音部分
        recordCount = 0;
        [self upAction];
    }
    recordCount++;
}


- (void)upAction{
    //松开 结束录音
    
    //录音停止
    [recorder stop];
    recorder = nil;
    //结束定时器
    [timer invalidate];
    timer = nil;
    
    [self onClickCut];
}

- (void)onClickCut{
    [self onClickRead];
}

- (void)onClickRead{
    NSMutableDictionary *resultDict = [[TestDecoder sharedTestDecoder] TestDecoderWithPath:playName];
    
    int resultINT = [[resultDict objectForKey:@"returnINT"] intValue];
    int itemp = [[resultDict objectForKey:@"temperature"] intValue];
    float ftemp = (float)(itemp /100.00f);
    
    if (resultINT == 0) { //解码成功
        if (self.normalErrorCount > 0) {
            self.normalErrorCount = 0;
        } else {
            if (itemp == 9999 || itemp == - 9999) {
                [self stopCheck];
                [self presentViewController:self.drawerController animated:NO completion:^{
                    [SVProgressHUD showErrorWithStatus:@"超出测温范围!"];
                }];
                return;
            } else if (itemp == 7777) {
                [self stopCheck];
//                [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
//                    [SVProgressHUD showErrorWithStatus:@"请联系客服!"];
//                }];
                [self presentViewController:self.drawerController animated:YES completion:^{
                    [SVProgressHUD showErrorWithStatus:@"请联系客服!"];
                }];
                return;
            } else if (itemp == -8888) {
                [self stopCheck];
                [self presentViewController:self.drawerController animated:NO completion:^{
                    [SVProgressHUD showErrorWithStatus:@"请重新测温!"];
                }];
                return;
            } else if (itemp == -6666) {
                [self stopCheck];
                [self presentViewController:self.drawerController animated:NO completion:^{
                    [SVProgressHUD showErrorWithStatus:@"请重新测温!"];
                }];
                return;
            } else {
                if (flag == 1) {
                    temperatureLabelOne.text = [NSString stringWithFormat:@"%.1f℃", ftemp];
                }else if (flag == 2){
                    temperatureLabelTwo.text = [NSString stringWithFormat:@"%.1f℃", ftemp];
                }else if (flag == 3){
                    temperatureLabelThree.text = [NSString stringWithFormat:@"%.1f℃", ftemp];
                }
//                temperatureLabel.text = [NSString stringWithFormat:@"%.1f℃", ftemp];
//                //快速测温预测部分start
//                if (!self.forecastTemperature && self.quickTimeCount <=20) {
//                    temperature[self.quickTimeCount] = ftemp;
//                    self.quickTimeCount++;
//                    double resultTemp = judge(temperature);
//                    NSLog(@"quickTimeCount:%d-resultTemp:%f",self.quickTimeCount - 1,resultTemp);
//                    if (resultTemp == -1) { //返回结果如果为-1表示继续传入温度值
//                        return;
//                    } else if (resultTemp == -2 ) { //返回结果-2或者timercount大于20表示溢出
//                        return;
//                    } else if (resultTemp > 0 ) { //返回结果大于0时表示监测出来温度
//                        //设置预测温度
//                        self.forecastTemperature = resultTemp;
//                        [self.forecastBtn setHidden:NO];
//                        return;
//                    }
//                }
                //快速测温预测部分end
                return;
            }
        }
    } else { //解码错误
        self.normalErrorCount++;
        if (self.normalErrorCount < 3) {
            return;
        } else {
            [self stopCheck];
            [self presentViewController:self.drawerController animated:NO completion:^{
                [SVProgressHUD showErrorWithStatus:@"请重新连接耳机孔，再次测温。"];
            }];
        }
    }
}

/**
 *	跳转到主页面
 */
- (MMDrawerController *)drawerController{
    if (_drawerController == nil) {
        MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
        LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
        RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
        self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
        [self.drawerController setShowsShadow:NO];
        [self.drawerController setMaximumRightDrawerWidth:200];
        [self.drawerController setMaximumLeftDrawerWidth:200];
        
    }
    return _drawerController;
}
/**
 *  停止检测
 */
- (void)stopCheck {
    /*消除所有定时器*/
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    if (timer2) {
        [timer2 invalidate];
        timer2 = nil;
    }
    
    if (timer3) {
        [timer3 invalidate];
        timer3 = nil;
    }
    
    if ([avAudioPlayer isPlaying]) {
        [avAudioPlayer stop];
    }
}

/**
 *  处理定时器Timer3
 */
- (void) handleTimer: (NSTimer *) timer3
{
    timercount++;//时间计数自增
    
    /*开始播放*/
    [self play];
    
    int min = timercount%60;
    int sec = timercount/60;
    if (flag == 1) {
        timeLabelOne.text = [NSString stringWithFormat:@"%@:%@",[self getTimeStr:sec], [self getTimeStr:min]];
    }else if (flag == 2){
        timeLabelTwo.text = [NSString stringWithFormat:@"%@:%@",[self getTimeStr:sec], [self getTimeStr:min]];
    }else if (flag == 3){
        timeLabelThree.text = [NSString stringWithFormat:@"%@:%@",[self getTimeStr:sec], [self getTimeStr:min]];
    }
//    timeLabel.text = [NSString stringWithFormat:@"%@:%@",[self getTimeStr:sec], [self getTimeStr:min]];
}

- (NSString *)getTimeStr:(int)value
{
    if (value<10) {
        return [NSString stringWithFormat:@"0%i",value];
    }
    return [NSString stringWithFormat:@"%i",value];
}

/**
 *  删除录音文件
 */
- (void)deleteTempFiles{
    NSString *extension = @"raw";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];//获取到documents下所有文件及文件夹的数组
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([[filename pathExtension] isEqualToString:extension]) { //判断后缀是否为raw
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];//删除后缀为raw的文件
        }
    }
}

/**
 *  判断耳机是否被拔出
 */
-(void)routeChange:(NSNotification *)notification{
    NSString *temperatureType = @"";
    if (checkType == 1) {
        temperatureType = @"1";
    } else if(checkType == 2 ) {
        temperatureType = @"0";
    }
    
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self stopCheck];
            [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
                [SVProgressHUD showInfoWithStatus:@"体温棒已拔出，请重新测温。"];
            }];
            return;
        }
    }
    
}

/**
 *  2015-09-23 SoulJa
 *  监听音量调节
 */
- (void)volumeChanged:(NSNotification *)notification
{
    // service logic here.
    CGFloat volume = [notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    
    if (volume < 1.0) {
        [self stopCheck];
        [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
            [SVProgressHUD showErrorWithStatus:@"请将音量调到最大"];
        }];
    }
}
@end
