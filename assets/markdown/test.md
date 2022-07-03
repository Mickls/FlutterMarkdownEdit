## 背景介绍
PuTTY对Telnet、SSH、rlogin、纯TCP以及串行接口建立连接的软件。早期仅支持windows平台，最近逐渐开始支持其它平台
我们在使用ssh命令行来创建代理隧道时，通常会因为时不时的断开连接而头疼，而PuTTY则可以为我们提供一个稳定创建ssh代理隧道的方案
## 使用
首先打开PuTTY，我们在名为Session的Tab栏填写目标服务器的IP地址和端口号，如下图所示
![Replaced by Image Uploder](https://cdn.jsdelivr.net/gh/Mickls/PictureBed@master/img/image_1650965601372_0.png)
点击左侧`Connection-SSH-Tunnels`Tab栏加入我们想要代理的端口号，并选择自己想要的端口类型点击Add加入，如下图所示
![Replaced by Image Uploder](https://cdn.jsdelivr.net/gh/Mickls/PictureBed@master/img/image_1650966003501_0.png)
点击Add之后，会在上方的输入框中出现一个`D7070`的标识如下图所示
![Replaced by Image Uploder](https://cdn.jsdelivr.net/gh/Mickls/PictureBed@master/img/image_1650967483704_0.png){:height 548, :width 598}
现在，我们点击open即可输入账号密码连接了
## 使用私钥登录
服务器使用账号密码来登录连接是一个不太安全的行为，因此我们也时常将服务器设置为密钥登录。因此在使用PuTTY来创建代理隧道也会遇上这样的问题，如何使用我们本地的私钥来验证登录远程服务器
首先我们打开PuTTYgen，点击load按钮，格式选择All File，找到我们的私钥文件，点确定。PuTTYgen会自动识别读取我们的私钥如下图所示
![Replaced by Image Uploder](https://cdn.jsdelivr.net/gh/Mickls/PictureBed@master/img/image_1650967917786_0.png)
在下方`Parameters`选择我们私钥生成的格式，点击`Generate`，则会将私钥解析转换为PuTTY所能识别的ppk文件。点击`Save private key`则可以将其保存
再次回到PuTTY，我们找到`Connection-SSH-Auth`Tab栏，最下方有`Private key file for authentication`这里就是我们选择私钥的地方，只需要将这里选择刚刚生成的`.ppk`文件，即可在创建远程连接的过程中使用我们的私钥进行登录。如下图所示：
![Replaced by Image Uploder](https://cdn.jsdelivr.net/gh/Mickls/PictureBed@master/img/image_1650968210531_0.png)