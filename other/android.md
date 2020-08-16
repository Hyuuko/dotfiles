Redmi K30 Pro

## Google Play

在应用商店里更新 Google Play，才会在桌面上显示 Play 商店的图标

由于有些软件有地区限制，所以需要更换国家/地区：

1. 在 https://ccardgenerator.com/generat-visa-card-numbers.php 生成假的卡号，Card number 即卡号，CVV 即验证码，Exp 即过期日期
2. 打开 clash，直连美国节点（不要中转路线）
3. 打开 Google Play，侧边菜单->帐号->添加信用卡或借记卡，可以看到上方有“切换到美国的 Play 商店”
4. 填入卡号，`MM/YY`填入过期日期，填入验证码，再填入邮编（在 https://www.youbianku.com/%E7%BE%8E%E5%9B%BD 查询美国邮编，比如省份 CA - California，城市 Sacramento，即加利福尼亚州，萨克拉门托，邮编是 95843）
5. 然后确认，会提示让你重新输入正确的 Visa 卡号，不用理会，关闭 Google Play，重新打开，就可以看到地址是美国了

## 使用 Magisk 进行 root

[topjohnwu/Magisk - GitHub](https://github.com/topjohnwu/Magisk)

关于 Magisk 的一些介绍：

- [神奇的 Magisk](https://mogeko.me/2017/010/)
- [Magisk Manager 详解 - 少数派](https://sspai.com/post/53809)
- [每个 Android 玩家都不可错过的神器（一）：Magisk 初识与安装 - 少数派](https://sspai.com/post/53043)

1. [解锁小米手机](https://www.miui.com/unlock/download.html)
   1. 按照流程操作，解锁手机的 Bootloader（BL）
2. 安装 Magisk Manager 并下载 Magisk 包
   1. 在酷安里安装 Magisk Manager，打开
   2. 然后点击 Magisk 右边的安装按钮，选择仅下载安装包。安装包就会下载到`/storage/emulated/0/Download/Magisk-v20.4(20400).zip`里
3. 刷入第三方 Recovery
   1. 将手机用数据线连上电脑，手机可以不关机，不过需要进入开发者模式，然后打开 USB 调试
   2. 在电脑上下载[小米 TWRP 一键刷机工具](http://www.romleyuan.com/lec/read?id=201)，然后打开`recovery-twrp一键刷入工具.bat`。跟着提示来，然后手机会进入到 TWRP
   3. 显示输入密码解密 Data 分区，输入开机密码即可，然后进入了 TWRP 的主页。然后点击高级->防止覆盖 TWRP，拖动滑块确认。在主页点击安装，再找到那个`Magisk-v20.4(20400).zip`，拖动滑块确认。完成后就可以点击重启系统了
4. 检查 SafeyNet 状态
   1. 用 clash 代理 Magisk Manager
   2. 在设置里开启「Magisk 核心功能模式」和「Magisk Hide」；然后在侧边菜单里的 Magisk Hide 里勾选 Google Play；在下载里找到 MagiskHide Props Config 这个模块，安装，完成后在模块界面启用该模块，然后重启
   3. 打开 Magisk Manager，点击检查 SafeyNet
      1. 如果 ctsProfile 这一项没有通过。那么需要点击左上角，在菜单里点击下载，
      2. 如果是 basic integrity 这一项没有通过，试着开启「Magisk 核心功能模式」或者卸载所有模块，如果还是没有通过，那么可能需要换一个系统或者第三方 ROM 了

如何让 app 获取 root 权限呢？当 app 申请 root 权限时，点击同意就行了！

## 使用 DriveDroid 将手机做成 USB 启动盘

优点：可以随时弄多个镜像，随时切换；不需要额外的 U 盘。

1. 打开 DriveDroid
2. 点击 ACQUIRE ROOT ACCESS，点击允许
3. 然后 Config IMAGE DIRECTORY，新建一个 drivedroid 文件夹，然后确定
4. USB System 选择 Standrad Android
5. 然后 USB MASS Storage 选 Android shows up in OS
6. Boot 选 Booted success...，
7. 取消勾选 send device information
8. 然后加号，创建光盘。
9. 点击光盘即可以只读/读写/CD-ROM 这三种方式挂载，再次点击，选 EJECT 就可以把它拔下来。

接下来让手机当作 USB 启动盘

1. 在 DriveDroid 上创建一个 6GB 的 image，以读写的方式挂载，用数据线将手机和电脑连接，连接选项选择充电就行。这时，电脑上会显示一个 6GB 的 U 盘。打开 rufus，将 win10 的镜像刻录进这个 U 盘。然后重启
2. 按 F12，手机连接选项选择充电即可，如果电脑上没显示 USB 的启动项，可以重新插拔一下数据线或者在 DriveDroid 上 EJECT 这个镜像，再重新挂载（只读模式就行）。此时应该就能显示出来了
