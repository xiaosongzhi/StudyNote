## QML编程 bug随记

1、报错显示

qml: undefined
qrc:/qmlfile/Train/TrainFootAnimation.qml:21: Error: Cannot assign [undefined] to int



上下文环境：

我在QML中访问cpp中的变量时报出的该问题;

截取部分代码：

```c++
private:
    int m_angle;
    Q_PROPERTY(int angle READ angle WRITE setAngle NOTIFY angleChanged)
```

我想访问cpp中的m_angle变量，我在QML中访问的代码如下

```js
property var currentAngle : TrainManager.m_angle
```

所以就报出上面的错误。

分析原因，我们使用Q_PROPERTY宏将变量暴露给QML之后，在QML端获取到的变量名称就为angle了，而不是cpp中的原变量名称m_angle。其名称已经放在Q_PROPERTY中的。真是对QML还不熟悉，导致出现各种错误，故在此进行记录。