//
//  MyMusicController.h
//  vkMusic
//
//  Created by Andriy Suden on 2/22/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundManager.h"
#import "STKAudioPlayer.h"

@class MyMusicController;

@protocol VKMusicPlayer<NSObject>
-(void) playFromHTTP:(MyMusicController*)audioPlayerView;
-(void) playFromFile:(NSURL *)url title:(NSString *)title current:(NSInteger)current controller:(MyMusicController*)audioPlayerView;
-(void) checkCurrent:(NSInteger)current;  // current is the index of the current song in the music array. If there is a conflict, we play next song (i.e. after deletion)
-(void) setRepeat:(BOOL)shouldRepeat;
-(void) setShuffle:(BOOL)shouldShuffle;
-(BOOL) getRepeat;
-(BOOL) getShuffle;
-(void) sayHi;
-(NSMutableArray *) getMusicArray;
@end

@interface MyMusicController : UIViewController <UITableViewDelegate, UITableViewDataSource, STKAudioPlayerDelegate>
{
    NSMutableArray *_myMusic;
    BOOL _isEditing;
}

@property (weak, nonatomic) IBOutlet UITableView *_myTable;
@property NSMutableArray *_myMusic;
@property (weak, nonatomic) IBOutlet UIButton *_repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *_shuffleButton;

@property (readwrite, unsafe_unretained) id<VKMusicPlayer> _delegate;

- (IBAction)_backButton:(id)sender;
- (IBAction)shuffleButton:(id)sender;
- (IBAction)editClicked:(id)sender;
- (IBAction)repeatClicked:(id)sender;

@end
