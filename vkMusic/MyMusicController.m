//
//  MyMusicController.m
//  vkMusic
//
//  Created by Andriy Suden on 2/22/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "MyMusicController.h"
#import "SampleQueueId.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MyMusicController ()
{
    NSInteger _current;
    NSInteger _max;
    BOOL _songOver;
    BOOL _songStopped;
    BOOL _nextTrackClicked;
    BOOL _shouldTick;
}
@end

@implementation MyMusicController
@synthesize _myTable;
@synthesize _myMusic;
@synthesize _timer;

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)handlePauseButton{
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

-(void)handlePlayButton{
    if (_audioPlayer.state == STKAudioPlayerStatePaused) {
        [_audioPlayer resume];
        _songStopped = YES;
    }
    if (_audioPlayer.state == STKAudioPlayerStatePlaying){
        [_audioPlayer pause];
        _songStopped = NO;
    }
}

-(void)handleNextTrackButton{
    [self playNextSong];
}

-(void)handlePreviousTrackButton{
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

- (void)viewDidLoad {
    
    NSError *error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    _audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    _audioPlayer.meteringEnabled = YES;
    _audioPlayer.volume = 1;
    _max = 0;
    _songOver = NO;
    _songStopped = NO;
    _nextTrackClicked = NO;
    _shouldTick = YES;
    
    _isEditing = NO;
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = TRUE;
    commandCenter.pauseCommand.enabled = TRUE;
    commandCenter.nextTrackCommand.enabled = TRUE;
    commandCenter.previousTrackCommand.enabled = TRUE;
    [[commandCenter playCommand] addTarget:self action:@selector(handlePauseButton)];
    [[commandCenter pauseCommand] addTarget:self action:@selector(handlePlayButton)];
    [[commandCenter nextTrackCommand] addTarget:self action:@selector(handleNextTrackButton)];
    [[commandCenter previousTrackCommand] addTarget:self action:@selector(handlePreviousTrackButton)];
    
    _myMusic = [NSMutableArray arrayWithCapacity:50];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    
    _audioPlayer = [[STKAudioPlayer alloc] init];
    [self setupTimer];
    
    [super viewDidLoad];
    
    [self lookThroughFiles];
    
    [_myTable reloadData];
    
    // Do any additional setup after loading the view
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // End receiving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return [NSString stringWithFormat:@"Your Downloaded Music"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_myMusic count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [_myMusic objectAtIndex:indexPath.row];
    return cell;
}

/*-(void)playSong:(NSString *)songUrl{
    NSLog(@"Trying to play %@", songUrl);
    [_audioPlayer play:songUrl];
}*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        //(your code opening a new view)
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirPath = [paths objectAtIndex:0];
        
        NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",cell.textLabel.text]];
        
        NSURL* url = [NSURL fileURLWithPath:musDirPath];
        
        _current = indexPath.row;
        NSLog(@"Current: %d",_current);
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        
        [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
        
        [_myTable reloadData];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirPath = [paths objectAtIndex:0];
        
        NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",cell.textLabel.text]];
        
    }
}

-(void)tick{
    if (!_audioPlayer) return;
    
    NSLog(@"tick");
    
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
        _songOver = YES;
    }
    else{
        if (_songOver && !_songStopped) {
            [self playNextSong];
        }
    }
}

-(void)playNextSong{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    _current++;
    if (_current == _myMusic.count) _current = 0;
    NSLog(@"Current in playNext: %ld",_current);
    
    NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",[_myMusic objectAtIndex:_current]]];
    NSURL* url = [NSURL fileURLWithPath:musDirPath];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)_backButton:(id)sender {
    [self performSegueWithIdentifier:@"backMain" sender:self];
}

- (IBAction)editClicked:(id)sender {
    if (!_isEditing){
        [_myTable setEditing:YES animated:YES];
        _isEditing = YES;
    }
    else {
        [_myTable setEditing:NO animated:YES];
        _isEditing = NO;
    }
    
}
@end
