# QML学习笔记

### 1、基础控件

#### 1.1 combobox的使用

### 2、CPP与QML交互

#### 2.1 将C++类注册到QML端，成为QML端可直接调用的对象

一般情况下，我们一般将C++以单利的形式注册到QML中，这样所有QML文件都可以直接访问到C++ 对象。在实际工程中，我们会将注册QML中的C++对象定义为中间件，类似于delegate,一般情况下不会将太多C++类注册到QML中。

注册方法很简单，代码如下

```C++
	QQmlApplicationEngine engine;

    MyObject myObject;
//							模块名称    版本号：主，次  注册到QML中的名称，实际对象指针
    qmlRegisterSingletonInstance("CppObject",1,0,"MyObject",&myObject);
```



#### 2.2 在QML中直接调用C++对象的函数

想实现在QML中直接调用C++类中的函数，主要有两种方法可以实现

（1）c++类中的公有参函数都可被QML直接调用

（2）使用Q_INVOKABLE修饰的公有函数

举例如下：在Cpp中定义函数

```c++
class MyObject : public QObject
{
    Q_OBJECT
public:
    explicit MyObject(QObject *parent = nullptr);
    Q_INVOKABLE void setTimerSwitch(bool);//可被QML直接调用
public slots:
    void cppSlot(int,QString);//可被QML直接调用
private:
    int m_iValue;
    QString m_sString;
};
```

在QML中直接调用

```js
Item {
    id : qmlDuan
    //自定义信号
    signal qmlSignal(int i,string str)
    Button{
        width:100
        height:50

        onClicked: {
            MyObject.setTimerSwitch(true); //直接调用被Q_INVOKABLE修饰函数
            MyObject.cppSlot(111,"hello") //直接调用槽函数
            qmlSignal(200,"muhailiang")
        }
    }
 }
```



#### 2.3 使用信号和槽的方式来实现Cpp和QML通信

##### 2.3.1在QML端发送信号，C++端接收

**在QML端连接信号和槽**   两种方法

首先，在QML中自定义信号，在Cpp中定义好参函数

```c++
//QML 中定义信号
Item {
    id : qmlDuan
    //自定义信号
    signal qmlSignal(int i,string str)
}
//在Cpp中定义好槽函数
public slots:
    void cppSlot(int,QString);
    void slotTimer();
```

其次，在QML中使用Connections或者connect进行连接，以下两种方式都可用。

```c++
    //信号与槽连接方式
    //方式1.
    Connections{
        target: qmlDuan //发送信号者
        function onQmlSignal(i,s) //要触发的信号
        //括号内为要调用的函数
        {
            MyObject.cppSlot(i,s);
        }
    }

    //方式2
    Component.onCompleted: {
        qmlSignal.connect(MyObject.cppSlot)
    }
```

最后，触发该信号

```c++
Button{
        width:100
        height:50
        onClicked: {
            qmlSignal(200,"muhailiang")
        }
    }
```

**在cpp端连接信号与槽 ** 一种方法

```c++
int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    MyObject myObject;
    qmlRegisterSingletonInstance("CppObject",1,0,"MyObject",&myObject);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    //engine 加载完成之后，也就是load之后
    auto list = engine.rootObjects();
    qDebug()<<list.first()->objectName();
    //通过此方法来获取想要qml的object
    auto object = list.first()->findChild<QObject*>("qmlDuan");
    //连接信号与槽
    QObject::connect(object,SIGNAL(qmlSignal(int,QString)),&myObject,SLOT(cppSlot(int,QString)));

    return app.exec();
}
```

##### 2.3.2在Cpp端发送信号，QML端接收

首先，在C++端定义好信号,在QML端定义好槽函数（就是普通函数）

```c++
//c++端定好信号
signals:
    void cppSignal(int,QString);
//QML端定义好槽函数
 function qmlSlot(i,s)
 {
        console.log("qmlSlot",i,s);
 }
```

其次，连接信号与槽(在QML端连接)

```C++
 //信号与槽连接方式Cpp端=》QML
    //方式一
    Connections{
        target: MyObject
        function onCppSignal(i,s)
        {
            qmlSlot(i,s)
        }
    }
    //方式2
    Component.onCompleted: {
        MyObject.cppSignal.connect(qmlSlot)
    }
```

在Cpp端连接信号与槽  ***此处需要特别注意*** 

```c++
QObject::connect(&myObject,SIGNAL(cppSignal(QVariant,QVariant)),object,SLOT(qmlSlot(QVariant,QVariant)));
```

在此处连接信号与槽时，需要将信号与槽中的参数类型都定义成QVariant,否则不生效。这是因为在QML函数中，参数类型对应cpp端都是QVariant类型。

```c++
  function qmlSlot(i,s) //参数类型，对应cpp端都是QVariant类型
  {
        console.log("qmlSlot",i,s);
  }
```

最后，在cpp中触发信号,我此处使用定时器进行发送

```c++
void MyObject::slotTimer()
{
    emit cppSignal(10,"hello world");
}
```

参考文件如下 在QMLStudy工程中的CppAndQml中。



