### Qt开发中的Bug随记

1. ##### **信号和槽传输复杂数据类型时报错**

甚至于在成员函数中，把复杂类型的变量放在槽函数中，并未执行连接操作都会报错。

![image-20230817091911504](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230817091911504.png)

报错的信息如下

![image-20230817092025197](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230817092025197.png)

展开的信息如下

![image-20230817092115799](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230817092115799.png)

我使用了不同的数据类型进行了多次测试，结果如下

| 数据类型       | 测试结果 |
| -------------- | -------- |
| QMap<int,bool> | N        |
| QMap<int,int>  | N        |
| uint*          | Y        |
| QByteArray     | Y        |
| QList<int>     | Y        |
| QVariant       | N        |

目前先记录到此，后续我会进行更加广泛的测试以及寻根其中原因，并找到解决办法。

**2、在使用QML和Qwidget混合编程时报出来如下错误：**

==QWidget: Cannot create a QWidget without QApplication==

在正常情况下，创建QML程序时用的是QGuiApplication,创建QWidget工程时用的是QApplication。此时我们使用的是默认的QGuiApplication,但是程序中也使用了QMessageBox等Qwidget控件。所以报出了如上文出现的错误。此时我们只需要将QGuiApplication替换成QApplication即可。

查找资料 QGuiApplication和QApplication的异同点。

