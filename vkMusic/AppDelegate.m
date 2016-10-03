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
    BOOL interruptStarted;
    
    unsigned long friend_id;
    
}

@end

@implementation AppDelegate
@synthesize _myMusic;
@synthesize _timer;
@synthesize _audioPlayer;
@synthesize _radioPlaying;
@synthesize _token;

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
    // [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
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
    
    _isQueueing = NO;
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = TRUE;
    commandCenter.previousTrackCommand.enabled = TRUE;
    [[commandCenter playCommand] addTarget:self action:@selector(playClicked)];
    [[commandCenter pauseCommand] addTarget:self action:@selector(pauseClicked)];
    [[commandCenter nextTrackCommand] addTarget:self action:@selector(handleNext)];
    [[commandCenter previousTrackCommand] addTarget:self action:@selector(handlePrev)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    _myMusic = [NSMutableArray arrayWithCapacity:50];
    
    [self lookThroughFiles];
    
    _audioPlayer = [[STKAudioPlayer alloc] init];
    [self setupTimer];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAudioObject:) name:@"sendVKAudio" object:nil];
    
    return YES;
}
     
-(void)interruption:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    switch (interuptionType) {
        case (AVAudioSessionInterruptionTypeBegan):
            if (!(_audioPlayer.state == STKAudioPlayerStatePaused)){
                [_audioPlayer  pause];
                interruptStarted = YES;
                
            }
            NSLog(@"Interruption started");
            break;
        case (AVAudioSessionInterruptionTypeEnded):
            if ((_audioPlayer.state == STKAudioPlayerStatePaused) && interruptStarted){
                [_audioPlayer resume];
                interruptStarted = NO;
            }
            NSLog(@"Interruption ended");
            break;
    }
}


-(void)fileDidDownload:(NSString *)file{
    BOOL inserted = false;
    int counter = 0;
    for (NSString *file_name in _myMusic) {
        if ([file compare:file_name] < 0){
            [_myMusic insertObject:file atIndex:counter];
            inserted = true;
            break;
        }
        counter++;
    }
    
    if (!inserted) [_myMusic addObject:file];
}

-(void)fileDidDownload2:(NSString *)file{
    BOOL inserted = false;
    int counter = 0;
    for (NSString *file_name in _myMusic) {
        if ([file compare:file_name] < 0){
            [_myMusic insertObject:file atIndex:counter];
            inserted = true;
            break;
        }
        counter++;
    }
    
    if (!inserted) [_myMusic addObject:file];
    
    //[_myMusic addObject:file];
}

-(BOOL)getRepeat{
    return _repeatSong;
}

-(BOOL)getShuffle{
    return _shuffleSong;
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
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = TRUE;
    commandCenter.previousTrackCommand.enabled = TRUE;
    
    NSLog(@"File :%@", [url absoluteString]);
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    _current = current;
    _currentSong = title;
}

-(void)playFromHTTP:(NSURL *)url title:(NSString *)title controller:(MyMusicController *)audioPlayerView{
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = FALSE;
    commandCenter.previousTrackCommand.enabled = FALSE;
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void)playFromHTTP:(NSURL *)url title:(NSString *)title cell:(TableViewCell *)cell{
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = FALSE;
    commandCenter.previousTrackCommand.enabled = FALSE;
    
    
    STKDataSource *dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    
    _currentSong = title;
}

-(void)playFromHTTP:(NSURL *)url title:(NSString *)title owner_id:(NSString *)owner_id song_id:(NSString *)song_id{
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = TRUE;
    commandCenter.previousTrackCommand.enabled = FALSE;
    
    
    STKDataSource *dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    
    _currentSong = title;
    _radioowner = owner_id;
    _radioid = song_id;
}

-(void) checkCurrent:(NSInteger)current{  // current is the index of the current song in the music array. If there is a conflict, we play next song (i.e. after deletion)
    if (current == _current) {
        [self playNextSong];
    }
}
-(void) setRepeat:(BOOL)shouldRepeat{
    _repeatSong = shouldRepeat;
    if (_repeatSong) NSLog(@"Repeat On");
    else NSLog(@"Repeat Off");
}
-(void) setShuffle:(BOOL)shouldShuffle{
    _shuffleSong = shouldShuffle;
    if (_shuffleSong) NSLog(@"Shuffle On");
    else NSLog(@"Shuffle Off");
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
    
    [_myMusic removeAllObjects];
    
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

-(void)allMusic{
    [self lookThroughFiles];
    NSInteger songIndex = [_myMusic indexOfObject:_currentSong];
    if (songIndex) {
        _current = songIndex;
    }
    else _current = 0;
}

-(NSMutableArray *)musicWithSubstring:(NSString *)substr{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    substr = [substr lowercaseString];
    
    [_myMusic removeAllObjects];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[documentsDirPath stringByAppendingString:@"/music/"] error:&error];
    if (files == nil) {
        // error...
        NSLog(@"ERROR!");
    }
    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *str = [file lowercaseString];
            if ([str containsString:substr]) [_myMusic addObject:file];
            _max++;
        }
    }
    
    NSInteger songIndex = [_myMusic indexOfObject:_currentSong];
    if (songIndex) {
        _current = songIndex;
    }
    else _current = 0;
    
    return _myMusic;
}

-(void)pauseClicked{
    NSLog(@"Pause");
    [_audioPlayer pause];
}

-(void)playClicked{
    NSLog(@"Play");
    if (_audioPlayer.state == STKAudioPlayerStateStopped) {
        _current = arc4random() % [_myMusic count];
        [self playNextSong];
    }
    else [_audioPlayer resume];
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{
    NSLog(@"state changed");
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
    
    if (self._radioPlaying) {
        
        NSString *target_audio = [NSString stringWithFormat:@"%@_%@",_radioowner, _radioid];
        
        VKRequest *req = [VKRequest requestWithMethod:@"audio.getRecommendations" andParameters:@{@"target_audio" : target_audio} andHttpMethod:@"GET" classOfModel:[VKAudios class]];
        
        NSMutableArray *songs = [NSMutableArray array];
        
        [req executeWithResultBlock:^(VKResponse *response) {
            int x = 0;
            for (VKAudio *a in response.parsedModel) {
                [songs addObject:a];
                NSLog(@"%d: %@", x, a.title);
                x++;
                if (x >= 15) break;
            }
        
            if ([songs count] == 0) {
                return;
            }
            
            unsigned long count = [songs count];
            int d = arc4random() % count;
            
            VKAudio *song = [songs objectAtIndex:d];
            [self playFromHTTP:[NSURL URLWithString:song.url] title:song.title owner_id:song.owner_id song_id:song.id];
        } errorBlock:nil];
        return;
    }
    
    if (_myMusic.count == 0) {
        return;
    }
    
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

#pragma mark Music Array Getter

-(NSMutableArray *)getMusicArray{
    return _myMusic;
}

#pragma mark Friend Protocol Methods

-(void)setFriend:(unsigned long)uid{
    friend_id = uid;
}

-(unsigned long)getFriend{
    return friend_id;
}

#pragma mark Queue Methods

-(void)setQueue:(BOOL)shouldQueue{
    if (shouldQueue){
        _isQueueing = TRUE;
    } else {
        _isQueueing = NO;
        [_audioPlayer clearQueue];
    }
}

-(BOOL)isQueueing{
    return (_isQueueing) ? TRUE : FALSE;
}

-(void)queueSong:(NSString *)title{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    
    NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",[title stringByAppendingPathComponent:@".mp3"]]];
    NSURL* url = [NSURL fileURLWithPath:musDirPath];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:1]];

}

-(void)setRadio:(BOOL)shouldPlay{
    self._radioPlaying = shouldPlay;
}

-(BOOL)getRadio{
    return self._radioPlaying;
}

-(void)setToken:(NSString *)token {
    self._token = token;
}

-(NSString *)getToken {
    return self._token;
}

@end
