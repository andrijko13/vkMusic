//
//  AppDelegate.h
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdkFramework/VKSdkFramework.h>
#import <AVFoundation/AVFoundation.h>
#import "STKAudioPlayer.h"
#import "MyMusicController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, VKMusicPlayer>
{
    BOOL _isAudioPlayerActive;
    STKAudioPlayer *_audioPlayer;
    NSTimer *_timer;
    
    NSInteger _current;
    NSInteger _max;
    
    BOOL _songOver;
    BOOL _songStopped;
    BOOL _nextTrackClicked;
    BOOL _shouldTick;
    BOOL _repeatSong;
    BOOL _shuffleSong;
    UIColor *_defaultButtonColor;
    NSString *_currentSong;
    
}

@property (strong, nonatomic) UIWindow *window;
@property NSMutableArray *_myMusic;
@property (strong) NSTimer *_timer;

-(void)pauseClicked;
-(void)playClicked;
-(void)handleNext;
-(void)handlePrev;


@end

