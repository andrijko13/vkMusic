//
//  FirstViewController.h
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdkFramework/VKSdkFramework.h>
#import "FriendController.h"

@protocol MainMenuDelegate<NSObject>
-(void)setQueue:(BOOL)shouldQueue;
-(void)setRadio:(BOOL)shouldPlay;
-(void)setToken:(NSString *)token;
@end

@interface FirstViewController : UIViewController <VKSdkDelegate>
@property (weak, nonatomic) IBOutlet UIButton *_vkButton;
- (IBAction)vkClicked:(id)sender;
- (IBAction)_musButton:(id)sender;
- (IBAction)_searchButton:(id)sender;
- (IBAction)_radioButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *_loginButton;
@property (readwrite, unsafe_unretained) id <FriendDelegate, MainMenuDelegate> _delegate;

@end

