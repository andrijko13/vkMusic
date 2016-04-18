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

@interface MyMusicController : UIViewController <UITableViewDelegate, UITableViewDataSource, STKAudioPlayerDelegate>
{
    NSMutableArray *_myMusic;
    STKAudioPlayer *_audioPlayer;
    NSTimer *_timer;
    BOOL _isEditing;
}

@property (weak, nonatomic) IBOutlet UITableView *_myTable;
@property NSMutableArray *_myMusic;
@property (strong) NSTimer *_timer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *_repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *_shuffleButton;

- (IBAction)_backButton:(id)sender;
- (IBAction)shuffleButton:(id)sender;
- (IBAction)editClicked:(id)sender;
- (IBAction)repeatClicked:(id)sender;

@end
