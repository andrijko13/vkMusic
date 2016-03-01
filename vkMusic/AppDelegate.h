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

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL _isAudioPlayerActive;
    STKAudioPlayer *_audioPlayer;
}

@property (strong, nonatomic) UIWindow *window;


@end

