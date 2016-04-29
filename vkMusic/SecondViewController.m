//
//  SecondViewController.m
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"

#define NUMBER_OF_ITEMS_IN_ARRAY 200

@interface SecondViewController ()
{
    NSMutableArray *_vkmusic;
    NSString *_fileName;
    NSMutableData *_receivedData;
    long long _expectedBytes;
    
    NSString *_songTitle;
    
    NSURLConnection *_connection;
}
@end

@implementation SecondViewController
@synthesize _musicTable;
@synthesize _searchBar;
@synthesize _downloadLabel;
@synthesize _progress;
@synthesize _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _musicTable.delegate = self;
    _musicTable.dataSource = self;
    
    _searchBar.delegate = self;
    
    _progress.hidden = YES;
    _downloadLabel.hidden = YES;
    
    self._delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _vkmusic = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_ITEMS_IN_ARRAY];
    // Do any additional setup after loading the view.
    /*VKRequest *req = [VKRequest requestWithMethod:@"audio.search" andParameters:@{VK_API_Q: [NSString stringWithFormat:@"Lil wayne"]} andHttpMethod:@"GET" classOfModel:[VKAudios class]];
    [req executeWithResultBlock:^(VKResponse *response) {
        int x = 0;
        for (VKAudio *a in response.parsedModel) {
            [_vkmusic addObject:a];
            NSLog(@"%@", a.title);
            x++;
            if (x >= NUMBER_OF_ITEMS_IN_ARRAY) break;
        }
        [_musicTable reloadData];
    } errorBlock:nil];*/
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return [NSString stringWithFormat:@"Search Results"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_vkmusic count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    
    VKAudio *song = [_vkmusic objectAtIndex:indexPath.row];
    [cell._title setText:[NSString stringWithFormat:@"%@ - %@",song.artist, song.title]];
    NSString *url = [self parseMp3:song];
    cell._url = url;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        //(your code opening a new view)
        VKAudio *song = [_vkmusic objectAtIndex:indexPath.row];
        NSString *url = [self parseMp3:song];
        
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        _songTitle = [song.title stringByAppendingString:@".mp3"];
        _fileName = [NSString stringWithFormat:@"%@/music/%@", documentsDirectory,[song.title stringByAppendingString:@".mp3"]];
        
        [self downloadFromURL:url name:[song.title stringByAppendingString:@".mp3"]];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_vkmusic removeAllObjects];
    NSLog(@"Search clicked!");
    VKRequest *req = [VKRequest requestWithMethod:@"audio.search" andParameters:@{VK_API_Q: [NSString stringWithFormat:@"%@",searchBar.text], VK_API_SORT: @2, VK_API_COUNT: @NUMBER_OF_ITEMS_IN_ARRAY} andHttpMethod:@"GET" classOfModel:[VKAudios class]];
    [req executeWithResultBlock:^(VKResponse *response) {
        int x = 0;
        for (VKAudio *a in response.parsedModel) {
            [_vkmusic addObject:a];
            NSLog(@"%d: %@", x, a.title);
            x++;
            if (x >= NUMBER_OF_ITEMS_IN_ARRAY) break;
        }
        [_musicTable reloadData];
    } errorBlock:nil];
    
    [_searchBar resignFirstResponder];
}

-(NSString *)parseMp3:(VKAudio const*)song{
    NSString *fullPath = [NSString stringWithFormat:@"%@", song.url];
    
    NSRange rangeOfMp3 = [fullPath rangeOfString:@".mp3"];
    NSUInteger length = rangeOfMp3.length + rangeOfMp3.location;
    NSString *str = [fullPath substringToIndex:length];
    
    NSLog(@"%@",fullPath);
    if (str) return str;
    return nil;
}

-(void)downloadFromURL:(NSString *)urlToDownload name:(NSString *)fileName{
    NSLog(@"Downloading Started");
    NSURL  *url = [NSURL URLWithString:urlToDownload];
    //NSData *urlData = [NSData dataWithContentsOfURL:url];
    _connection = nil;
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    _receivedData = nil;
    _receivedData = [[NSMutableData alloc] initWithLength:0];
    _connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self     startImmediately:YES];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Received response from connection");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _progress.hidden = NO;
    _downloadLabel.hidden = NO;
    [_receivedData setLength:0];
    _expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received data from connection");
    [_receivedData appendData:data];
    float progressive = (float)[_receivedData length] / (float)_expectedBytes;
    [_progress setProgress:progressive];
    
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Download Failed");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[currentURL stringByAppendingString:@".mp3"]];
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[_receivedData length]);
    _connection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_receivedData writeToFile:_fileName atomically:YES];
    [self._delegate fileDidDownload2:_songTitle];
    _progress.hidden = YES;
    _downloadLabel.hidden = YES;
}

- (IBAction)_backButton:(id)sender {
    [self performSegueWithIdentifier:@"_backButton" sender:self];
}
@end
