//
//  FriendController.h
//  vkMusic
//
//  Created by Andriy Suden on 6/4/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdkFramework/VKSdkFramework.h>

@protocol FriendDelegate <NSObject>

-(void)setFriend:(unsigned long)uid;

@end

@interface FriendController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>{
    
}
@property IBOutlet UITableView *_musicTable;
@property (readwrite, unsafe_unretained) id<FriendDelegate> _delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *_searchBar;

@end
