//
//  SecondViewController.h
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdkFramework/VKSdkFramework.h>

@class SecondViewController;

@protocol vkMusDownloadDelegate<NSObject>
-(void)fileDidDownload2:(NSString *)file;
@end

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
}
@property (weak, nonatomic) IBOutlet UITableView *_musicTable;
@property (weak, nonatomic) IBOutlet UISearchBar *_searchBar;
@property (weak, nonatomic) IBOutlet UILabel *_downloadLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *_progress;
@property (readwrite, unsafe_unretained) id<vkMusDownloadDelegate> _delegate;
- (IBAction)_backButton:(id)sender;


@end

