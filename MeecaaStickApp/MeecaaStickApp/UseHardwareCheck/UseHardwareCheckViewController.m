//
//  UseHardwareCheckViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/26.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "UseHardwareCheckViewController.h"
/**
 *  音频所需库文件
 */
#import <AVFoundation/AVFoundation.h>
/**
 *  重力加速器所需库
 */
#import <CoreMotion/CoreMotion.h>
/**
 *  控制音量所需库文件
 */
#import <MediaPlayer/MPVolumeView.h>
#import "TestDecoder.h"
#import "Function.h"
#import "MainTabBarController.h"

@interface UseHardwareCheckViewController ()
{
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
    
}

@property (weak, nonatomic) IBOutlet UIView *messageView;
/*计时区域的Label*/
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
/*显示温度的Label*/
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
/*冒出气泡的View*/
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
/*最后一次测温记录*/
@property (retain, nonatomic) NSString *lastTemperature;
/*核心运动的管理器*/
@property (strong,nonatomic) CMMotionManager *motionManager;
/*冒出气泡数组*/
@property (retain, nonatomic) NSMutableArray *bubbles;
@property (nonatomic,assign) int quickTimeCount;
/**
 *  SoulJa 2015-11-11
 *  常规测温错误次数
 */
@property (nonatomic,assign) int normalErrorCount;
/**
 *  预测按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *forecastBtn;
/**
 *  预测温度值
 */
@property (nonatomic,assign) double forecastTemperature;
@end

@implementation UseHardwareCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置Nav
    [self setupNav];
    
    //计数次数
    self.quickTimeCount = 0;
    
    /*保持屏幕常亮*/
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //常规测温错误次数
    self.normalErrorCount = 0;
    
    //初始化温度显示Label的text
    self.temperatureLabel.text = @"";
    
    //按钮隐藏
    [self.forecastBtn setHidden:YES];

    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if(!available) {
                [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
                    [SVProgressHUD showErrorWithStatus:@"请在“设置-隐私-麦克风”选项中允许体温棒访问您的麦克风!"];
                }];
                return;
            }
        }];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
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
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    avAudioPlayer.volume = 1;//设置音量最大
    avAudioPlayer.numberOfLoops = 1;//设置循环次数
    [avAudioPlayer prepareToPlay];//准备播放
    
    /*开始检测*/
    [self onClickCheck:nil];
    
    //启动气泡时间
    [self startAnimation];
    
    self.motionManager = [[CMMotionManager alloc] init];//一般在viewDidLoad中进行
    self.motionManager.accelerometerUpdateInterval = .1;//加速仪更新频率，以秒为单位
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*加速计开始启动*/
    [self startAccelerometer];
    
    //监听调节音量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    /*监听拔出耳机*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //停止加速仪更新（很重要！）
    [self.motionManager stopAccelerometerUpdates];
    [self stopCheck];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}


/**
 *  启动中立加速计
 */
-(void)startAccelerometer
{
    //以push的方式更新并在block中接收加速度
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if (error) {
                                                     NSLog(@"motion error:%@",error);
                                                 }
                                             }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    shakeX = acceleration.x;
    
}


/**
 *  开始启动
 */
- (void)startAnimation
{
    self.bubbles = [NSMutableArray array];
    animTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(createBubble:) userInfo:nil repeats:YES];
}

/**
 *  创建气泡
 */
- (void)createBubble:(NSTimer*)timer_
{
    /*处理气泡*/
    [self handleBubble];
    
    int createRandom = arc4random()%10;
    if (createRandom==0&&self.bubbles.count<=20) { //随机数等于0并且气泡数量小于20
        UIImage *image = [UIImage imageNamed:@"check_bubble"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        int viewWidth = self.view.frame.size.width;
        int viewHeight = self.view.frame.size.height;
        
        int posX = arc4random()%viewWidth;
        
        float scale = [self getBubbleScale];
        [imageView setFrame:CGRectMake(posX, viewHeight, image.size.width*scale, image.size.height*scale)];
        imageView.alpha = [self getBubbleAlpha];
        
        [self.bubbleView addSubview:imageView];
        
        NSDictionary *bubbleObj = @{@"png":imageView,@"speed":[NSNumber numberWithDouble:[self getUpTimer]*4.5]};
        [self.bubbles addObject:bubbleObj];
    }
}

/**
 *  气泡上升所需要的时间
 */
- (float)getUpTimer
{
    int random = arc4random() % 5;
    if (random==0) {
        return 0.5;
    }
    else if (random==1){
        return 0.7;
    }
    else if (random==2){
        return 0.9;
    }
    else if (random==3){
        return 1.2;
    }
    else if (random==4){
        return 1.3;
    }
    else if (random==5){
        return 2;
    }
    else if (random==6){
        return 2.1;
    }
    else if (random==7){
        return 2.3;
    }
    else if (random==8){
        return 2.5;
    }
    else if (random==9){
        return 2.8;
    }
    return 3;
}

- (float)getBubbleAlpha
{
    float random = (float)(arc4random() % 10)/10.0;
    float value = random + 0.3;
    if (value>=1.0) {
        value = 1.0;
    }
    return value;
}

- (float)getBubbleScale
{
    float random = (float)(arc4random() % 10)/10.0;
    float value = random + 0.5;
    if (value>=1.0) {
        value = 1.0;
    }
    return value;
}

/**
 *  处理气泡
 */
- (void)handleBubble
{
    for (int i=0; i<self.bubbles.count; i++) {
        NSDictionary *bubbleObj = [self.bubbles objectAtIndex:i];
        UIImageView *bubblePng = (UIImageView *)[bubbleObj objectForKey:@"png"];
        float speed = [[bubbleObj objectForKey:@"speed"] floatValue];
        CGRect bubbleFrame = bubblePng.frame;
        [bubblePng setFrame:CGRectMake(bubbleFrame.origin.x-shakeX*5, bubbleFrame.origin.y-speed, bubbleFrame.size.width, bubbleFrame.size.height)];
    }
    for (int i=(int)self.bubbles.count-1; i>=0; i--) {
        NSDictionary *bubbleObj = [self.bubbles objectAtIndex:i];
        UIImageView *bubblePng = (UIImageView *)[bubbleObj objectForKey:@"png"];
        CGRect bubbleFrame = bubblePng.frame;
        if (bubbleFrame.origin.y<=-bubblePng.frame.size.height) { //当气泡超出屏幕的时候
            [bubblePng removeFromSuperview];
            [self.bubbles removeObjectAtIndex:i];
        }
    }
}



/**
 *  开始检测
 */
- (IBAction)onClickCheck:(id)sender {
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
        [self downAction:nil];
    }
}

/**
 *  按下录音按键
 */
- (IBAction)downAction:(id)sender {
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
        [self upAction:nil];
    }
    recordCount++;
}

- (IBAction)upAction:(id)sender {
    //松开 结束录音
    
    //录音停止
    [recorder stop];
    recorder = nil;
    //结束定时器
    [timer invalidate];
    timer = nil;
    
    [self onClickCut:nil];
}

/**
 *  获取录音数据
 */
- (IBAction)onClickCut:(id)sender {
    [self onClickRead:nil];
}

/**
 *  读取数据
 */
- (void)onClickRead:(id)sender {
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
                [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
                    [SVProgressHUD showErrorWithStatus:@"超出测温范围!"];
                }];
                return;
            } else if (itemp == 7777) {
                [self stopCheck];
                [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
                    [SVProgressHUD showErrorWithStatus:@"请联系客服!"];
                }];
                return;
            } else {
                self.temperatureLabel.text = [NSString stringWithFormat:@"%.1f℃", ftemp];
                //快速测温预测部分start
                if (!self.forecastTemperature && self.quickTimeCount <=20) {
                    temperature[self.quickTimeCount] = ftemp;
                    self.quickTimeCount++;
                    double resultTemp = judge(temperature);
                    NSLog(@"quickTimeCount:%d-resultTemp:%f",self.quickTimeCount - 1,resultTemp);
                    if (resultTemp == -1) { //返回结果如果为-1表示继续传入温度值
                        return;
                    } else if (resultTemp == -2 ) { //返回结果-2或者timercount大于20表示溢出
                        return;
                    } else if (resultTemp > 0 ) { //返回结果大于0时表示监测出来温度
                        //设置预测温度
                        self.forecastTemperature = resultTemp;
                        [self.forecastBtn setHidden:NO];
                        return;
                    }
                }
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
            [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:^{
                [SVProgressHUD showErrorWithStatus:@"请重新连接耳机孔，再次测温。"];
            }];
        }
    }
    
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
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",[self getTimeStr:sec], [self getTimeStr:min]];
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
 *  设置音量
 */
- (void)setPhoneVolume:(float)volume
{
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  设置Nav
 */
- (void)setupNav {
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"login_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo"]];
}

- (void)goBack
{
    [self stopCheck];
    [self presentViewController:[[MainTabBarController alloc] init] animated:NO completion:nil];
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
