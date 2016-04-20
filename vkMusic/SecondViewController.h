//
//  SecondViewController.h
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdkFramework/VKSdkFramework.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
}
@property (weak, nonatomic) IBOutlet UITableView *_musicTable;
@property (weak, nonatomic) IBOutlet UISearchBar *_searchBar;
@property (weak, nonatomic) IBOutlet UILabel *_downloadLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *_progress;
- (IBAction)_backButton:(id)sender;


@end

