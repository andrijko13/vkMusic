//
//  MyMusicController.m
//  vkMusic
//
//  Created by Andriy Suden on 2/22/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

// TODO: Set color based on what the Delegate has set for shuffle and repeat

#import "MyMusicController.h"
#import "SampleQueueId.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"

@interface MyMusicController ()
{
    NSInteger _current;
    NSInteger _max;
    
    BOOL _repeatSong;
    BOOL _shuffleSong;
    UIColor *_defaultButtonColor;
    NSString *_currentSong;
    
    UIButton *_repeatBut;
    UIButton *_shuffleBut;
}
@end

@implementation MyMusicController
@synthesize _myTable;
@synthesize _myMusic;
@synthesize _repeatButton;
@synthesize _shuffleButton;
@synthesize _delegate;

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{
    
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId{
    
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId{
    
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode{
    
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)viewDidLoad {
    
    self._delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; // We make our delegate property the AppDelegate instance
    
    _myTable.delegate = self;           // Set up the delegate's for the tableView
    _myTable.dataSource = self;
    
    
    _defaultButtonColor = _shuffleButton.currentTitleColor; // set it to white color
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    
    if ([self._delegate getShuffle]){
        _shuffleSong = TRUE;
        [_shuffleButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    
    if ([self._delegate getRepeat]){
        _repeatSong = TRUE;
        [_repeatButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    
    [self._delegate sayHi];             // Test method to see if delegate works
    
    [super viewDidLoad];
    
    _myMusic = [self._delegate getMusicArray]; // Get the music array so we can update our table
    _searchMusic = [NSMutableArray arrayWithCapacity:_myMusic.count];
    [_myTable reloadData];
    
    // Do any additional setup after loading the view
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
    _myMusic = [self._delegate getMusicArray];
    NSLog(@"");
    return [_myMusic count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    _myMusic = [self._delegate getMusicArray];
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [_myMusic objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _myMusic = [self._delegate getMusicArray];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        //(your code opening a new view)
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirPath = [paths objectAtIndex:0];
        
        NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",cell.textLabel.text]];
        
        NSURL* url = [NSURL fileURLWithPath:musDirPath];
        
        [self._delegate playFromFile:url title:[cell.textLabel.text stringByDeletingPathExtension] current:indexPath.row controller:self];
        
        [_myTable reloadData];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    _myMusic = [self._delegate getMusicArray];
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirPath = [paths objectAtIndex:0];
        
        NSString *musDirPath = [documentsDirPath stringByAppendingString:[NSString stringWithFormat: @"/music/%@",cell.textLabel.text]];
        
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:musDirPath error:&error];
        if (success) {
            NSLog(@"Deleted song %@", musDirPath);
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
        [self._delegate checkCurrent:indexPath.row];

        [_myMusic removeObjectAtIndex:indexPath.row]; // might need to do this in delegate
        [_myTable reloadData];
    }
    
}

#pragma mark - Search Bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""]) {
        [self._delegate allMusic];
    }
    else{
        [self._delegate musicWithSubstring:searchBar.text];
        [self._myTable reloadData];
    }
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if (!searchBar.showsCancelButton) [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
        [self._delegate allMusic];
    }
    else{
        [self._delegate musicWithSubstring:searchBar.text];
        [self._myTable reloadData];
    }
    if (!searchBar.showsCancelButton) [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar setText:@""];
    [self._delegate allMusic];
    [self._myTable reloadData];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)_backButton:(id)sender {
    [self performSegueWithIdentifier:@"_backButton" sender:self];
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

- (IBAction)repeatClicked:(id)sender {
    _repeatSong = !_repeatSong;
    [self._delegate setRepeat:_repeatSong];
    if (_repeatSong) [_repeatButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    else [_repeatButton setTitleColor:_defaultButtonColor forState:UIControlStateNormal];
}

- (IBAction)shuffleButton:(id)sender {
    _shuffleSong = !_shuffleSong;
    [self._delegate setShuffle:_shuffleSong];
    if (_shuffleSong) [_shuffleButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    else [_shuffleButton setTitleColor:_defaultButtonColor forState:UIControlStateNormal];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#pragma mark TODO
    [self resignFirstResponder];
}
@end
