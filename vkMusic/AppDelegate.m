//
//  AppDelegate.m
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "AppDelegate.h"
#import "SampleQueueId.h"

@interface AppDelegate ()
{
    STKAudioPlayer *audioPlayer;
}

@end

@implementation AppDelegate
@synthesize _myMusic;
@synthesize _timer;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    Float32 bufferLength = 0.1;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferLength), &bufferLength);
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    ////////////////////////////////////// Begin Player Setup ///////////////////////////////////////
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    _audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    _audioPlayer.meteringEnabled = YES;
    _audioPlayer.volume = 1;
    _max = 0;
    _songOver = NO;
    _songStopped = NO;
    _nextTrackClicked = NO;
    _shouldTick = YES;
    
    _repeatSong = NO;
    _shuffleSong = NO;
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = TRUE;
    commandCenter.previousTrackCommand.enabled = TRUE;
    [[commandCenter playCommand] addTarget:self action:@selector(playClicked)];
    [[commandCenter pauseCommand] addTarget:self action:@selector(pauseClicked)];
    [[commandCenter nextTrackCommand] addTarget:self action:@selector(handleNext)];
    [[commandCenter previousTrackCommand] addTarget:self action:@selector(handlePrev)];
    
    _myMusic = [NSMutableArray arrayWithCapacity:50];
    
    [self lookThroughFiles];
    
    _audioPlayer = [[STKAudioPlayer alloc] init];
    [self setupTimer];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAudioObject:) name:@"sendVKAudio" object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)playFromFile:(NSURL *)url title:(NSString *)title current:(NSInteger)current controller:(MyMusicController *)audioPlayerView{
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    _current = current;
    _currentSong = title;
}

-(void)playFromHTTP:(MyMusicController *)audioPlayerView{
    
}

-(void) checkCurrent:(NSInteger)current{  // current is the index of the current song in the music array. If there is a conflict, we play next song (i.e. after deletion)
    if (current == _current) {
        [self playNextSong];
    }
}
-(void) setRepeat:(BOOL)shouldRepeat{
    _repeatSong = shouldRepeat;
}
-(void) setShuffle:(BOOL)shouldShuffle{
    _shuffleSong = shouldShuffle;
}

-(void)tick{
    if (!_audioPlayer) return;
    
    switch (_audioPlayer.state) {
        case STKAudioPlayerStatePlaying:
            // do stuff while playing
            _songOver = YES;
            _songStopped = NO;
            break;
            
        case STKAudioPlayerStateBuffering:
            // do stuff while buffering
            _songStopped = YES;
            break;
            
        case STKAudioPlayerStatePaused:
            // do stuff while paused
            _songStopped = YES;
            break;
            
        case STKAudioPlayerStateStopped:
            // do stuff when stopped
            //_songOver = NO;
            break;
            
        default:
            break;
    }
    
    if (_audioPlayer.duration) {
        // there is a song playing
        NSMutableDictionary *albumInfo = [[NSMutableDictionary alloc] init];
        [albumInfo setObject:_currentSong forKey:MPMediaItemPropertyTitle];
        [albumInfo setObject:[NSString stringWithFormat:@"%f",_audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [albumInfo setObject:[NSString stringWithFormat:@"%f",_audioPlayer.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:albumInfo];
        _songOver = YES;
    }
    else{
        if (_songOver && !_songStopped) {
            if (_repeatSong) _current--;
            else if (_shuffleSong) _current = arc4random() % [_myMusic count];
            [self playNextSong];
        }
    }
}

-(void)setupTimer{
    _timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)lookThroughFiles{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    
    //NSLog(@"%@",[documentsDirPath stringByAppendingString:@"/music/"]);
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[documentsDirPath stringByAppendingString:@"/music/"] error:&error];
    if (files == nil) {
        // error...
        NSLog(@"ERROR!");
    }
    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [_myMusic addObject:file];
            _max++;
        }
    }
}

-(void)pauseClicked{
    if (_audioPlayer.state == STKAudioPlayerStatePlaying){
        [_audioPlayer pause];
        _songStopped = YES;
    }
    if (_audioPlayer.state == STKAudioPlayerStatePaused) {
        [_audioPlayer resume];
        _songStopped = NO;
    }
    if (_audioPlayer.state == STKAudioPlayerStateStopped) {
        _current = arc4random() % [_myMusic count];
        [self playNextSong];
    }
}
-(void)playClicked{
    if (_audioPlayer.state == STKAudioPlayerStatePaused) {
        [_audioPlayer resume];
        _songStopped = YES;
    }
    if (_audioPlayer.state == STKAudioPlayerStatePlaying){
        [_audioPlayer pause];
        _songStopped = NO;
    }
    if (_audioPlayer.state == STKAudioPlayerStateStopped) {
        _current = arc4random() % [_myMusic count];
        [self playNextSong];
    }
}
-(void)handleNext{
    if (!_repeatSong) {if (_shuffleSong) _current = arc4random() % [_myMusic count];}
    [self playNextSong];
}
-(void)handlePrev{
    // what we do here is set back _current 2 songs, and play the next one to give the effect of playing previous
    _current-=2;
    if (_audioPlayer.state == STKAudioPlayerStatePlaying){
        if (_audioPlayer.progress > 2.5) _current++; // if we are > 2.5 seconds into song, play current song again (rewind)
    }
    if (_current < 0) {
        _current += _myMusic.count;
    }
    [self playNextSong];
}

-(void)playNextSong{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    _current++;
    if (_current >= _myMusic.count) _current = 0;
    NSLog(@"Current in playNext: %ld",(long)_current);
    
    _currentSong = [[_myMusic objectAtIndex:_current] stringByDeletingPathExtension];
    
    NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",[_myMusic objectAtIndex:_current]]];
    NSURL* url = [NSURL fileURLWithPath:musDirPath];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void)sayHi{
    NSLog(@"HELLO HAHAHAH");
}

-(NSMutableArray *)getMusicArray{
    return _myMusic;
}

@end
