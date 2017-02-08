//
//  YoutubeViewController.h
//  vkMusic
//
//  Created by Andriy Suden on 1/23/17.
//  Copyright © 2017 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol vkMusicDownloadDelegate<NSObject>
-(unsigned long)getFriend;
-(void)fileDidDownload:(NSString *)file;
@end


@interface YoutubeViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDownloadDelegate, NSURLConnectionDataDelegate, UISearchBarDelegate>
@property (readwrite, unsafe_unretained) id <vkMusicDownloadDelegate> _delegate;
@property (weak, nonatomic) IBOutlet UILabel *_downloadLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *_progress;
@property (weak, nonatomic) IBOutlet UISearchBar *_searchBar;
- (IBAction)_backButton:(id)sender;
@end
