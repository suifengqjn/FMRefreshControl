# FMRefreshControl
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/ibireme/YYKit/master/LICENSE) [![CocoaPods](http://img.shields.io/cocoapods/p/YYKit.svg?style=flat)](http://cocoapods.org/?q=YYKit) [![Build Status](https://travis-ci.org/ibireme/YYKit.svg?branch=master)](https://travis-ci.org/ibireme/YYKit)

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


