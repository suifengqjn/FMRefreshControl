# FMRefreshControl
### how to add
 	
-	Installation with CocoaPods：pod 'FMRefreshControl'
- Manual import：
	- Drag All files in the Classes folder to project
	- Import the main file：#import "FMRefreshControl.h"

### how to use 

```
//初始化一个control
UIRefreshControl *control = [[UIRefreshControl alloc] init];
//给control 添加一个刷新方法
[control addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
//把control 添加到 tableView
[self.tableView addSubview:control];
```


