#  TestCase

## 首次进入页面第一次加载数据

* 当 `contentSize.height` 超出可见范围外时要将 `tableView` 滚动到最底部(无动画).
* 当 `contentSize.height` 小于等于可见范围内时不发生滚动
* 此时 `func scrollViewDidScroll(_ scrollView: UIScrollView)` 方法不触发任何事件，需直接返回

## 点击输入框

* 调整输入框到合适位置并滚动消息到最新一条

## 在显示键盘时滚动屏幕

* 收起键盘，保持流畅滚动

## 下拉加载历史消息

* 原有的消息中第一条消息应该保持在原来的位置保持不变
* 在加载历史消息完成后更新 UI 时延迟执行(保持流畅度)。对应处理方法 `reloadDataWhenLoadingPage`
* 在加载历史消息完成后即将更新 UI 时再次拖动屏幕则要立即更新 UI (这里也可以做些延迟处理)。对应处理方法 `reloadDataImmidiate`



