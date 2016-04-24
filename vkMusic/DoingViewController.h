//
//  DoingViewController.h
//  vkMusic
//
//  Created by Andriy Suden on 2/22/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdkFramework/VKSdkFramework.h>

@class DoingViewController;

@protocol vkMusicDownloadDelegate<NSObject>
-(void)fileDidDownload:(NSString *)file;
@end

@interface DoingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate, NSURLConnectionDownloadDelegate, NSURLConnectionDataDelegate>
{
    IBOutlet UITableView *_musicTable;
    
}
@property (readwrite, unsafe_unretained) id<vkMusicDownloadDelegate> _delegate;
@property IBOutlet UITableView *_musicTable;
@property (weak, nonatomic) IBOutlet UILabel *_downloadLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *_progress;
- (IBAction)backMainButton:(id)sender;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *_downloadLabel2;

@end