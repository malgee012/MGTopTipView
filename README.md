# MGTopTipView
落幕式用户提示


##效果图

![](/Users/acmeway/Desktop/MGTopTipView/iii.gif)

####一句代码完成，简单方便

```
        [MGTopTipView showTopTipContent:@"这是我的测试内容"
                                 toView:self.view.window];
```



####代理方法-落幕消失后执行

```

/**
 落幕消失后代理

 @param topTipView topTipView
 */
- (void)topTipViewDidAppear:(MGTopTipView *)topTipView;

```