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

#### 2.4 在QML和C++之间传递自定义数据结构

在实际开发应用，我们需要从QML中获取表单数据给到C++后台，有时也需要将后台的数据显示到QML前端。此时传递的数据并非简单的一个int或者string类型，而是要传递一个自定义的复杂的结构体。此时就需要我们将自定义的结构体转换成QVariantMap进行传递。

使用方法：

（1）自定义一个结构体

```c++
 struct WeatherInfo
    {
      float tmp;
      int day_code;
      QString day_text;
      int ninght_code;
      QString night_text;
    };
```

(2)在cpp文件中定义操作结构体的函数，并用Q_INVOKABLE进行修饰

```c++
//声明函数
public:
Q_INVOKABLE QVariantMap getCurrentWeatherInfo();
Q_INVOKABLE void setWeatherInfo(QVariantMap);
private:
WeatherInfo m_weatherInfo;

//实现函数
QVariantMap MyObject::getCurrentWeatherInfo()
{
    m_weatherInfo.tmp = 21;
    m_weatherInfo.day_code = 1;
    m_weatherInfo.day_text = "小雨";
    m_weatherInfo.ninght_code = 2;
    m_weatherInfo.night_text = "晴朗";
    QVariantMap map;
    map.insert("tmp",m_weatherInfo.tmp);
    map.insert("day_code",m_weatherInfo.day_code);
    map.insert("day_text",m_weatherInfo.day_text);
    map.insert("ninght_code",m_weatherInfo.ninght_code);
    map.insert("night_text",m_weatherInfo.night_text);
    return map;
}

void MyObject::setWeatherInfo(QVariantMap map)
{
    qDebug()<<__FUNCTION__;
    qDebug()<<map.value("tmp").toInt()<<map.value("day_text").toString();
}
```

(3) 在QML中使用该结构体

```js
 Button{
        width:100
        height:50

        onClicked: {
//            MyObject.setTimerSwitch(true);
//            MyObject.cppSlot(111,"hello")
//            qmlSignal(200,"muhailiang")
			//获取结构体数据
            var currrentWeather = MyObject.getCurrentWeatherInfo();
            console.log(currrentWeather.tmp,currrentWeather.day_text);
            currrentWeather.tmp = 30;
            currrentWeather.day_text = "大雪";
            //设置结构体数据
            MyObject.setWeatherInfo(currrentWeather);
        }
    }
```



完整代码

myobject.h

```c++
#ifndef MYOBJECT_H
#define MYOBJECT_H

#include <QObject>
#include <QTimer>
#include <QVariant>
class MyObject : public QObject
{
    Q_OBJECT
public:
    struct WeatherInfo
    {
      float tmp;
      int day_code;
      QString day_text;
      int ninght_code;
      QString night_text;
    };
public:
    explicit MyObject(QObject *parent = nullptr);

    int iValue() const;
    void setIValue(int newIValue);

    const QString &sString() const;
    void setSString(const QString &newSString);

    Q_INVOKABLE void setTimerSwitch(bool);

    Q_INVOKABLE QVariantMap getCurrentWeatherInfo();

    Q_INVOKABLE void setWeatherInfo(QVariantMap);

signals:
    void cppSignal(QVariant,QVariant);
    void iValueChanged();

    void sStringChanged();

public slots:
    void cppSlot(int,QString);
    void slotTimer();
private:
    int m_iValue;
    QString m_sString;
    Q_PROPERTY(int iValue READ iValue WRITE setIValue NOTIFY iValueChanged)
    Q_PROPERTY(QString sString READ sString WRITE setSString NOTIFY sStringChanged)

    QTimer *m_timer;

    WeatherInfo m_weatherInfo;
};

#endif // MYOBJECT_H

```



myobject.cpp

```c++
#include "myobject.h"
#include <QDebug>
MyObject::MyObject(QObject *parent)
    : QObject{parent},
      m_timer(NULL)
{
    m_timer = new QTimer();
    m_timer->setInterval(1000);
    connect(m_timer,SIGNAL(timeout()),this,SLOT(slotTimer()));
}

void MyObject::cppSlot(int i, QString str)
{
    qDebug()<<__FUNCTION__<<i<<str;
}

void MyObject::slotTimer()
{
    emit cppSignal(10,"hello world");
}

const QString &MyObject::sString() const
{
    return m_sString;
}

void MyObject::setSString(const QString &newSString)
{
    if (m_sString == newSString)
        return;
    m_sString = newSString;
    emit sStringChanged();
}

void MyObject::setTimerSwitch(bool isOn)
{
    qDebug()<<"isOn"<<isOn;
    if(isOn)
        m_timer->start();
    else
        m_timer->stop();
}

QVariantMap MyObject::getCurrentWeatherInfo()
{
    m_weatherInfo.tmp = 21;
    m_weatherInfo.day_code = 1;
    m_weatherInfo.day_text = "小雨";
    m_weatherInfo.ninght_code = 2;
    m_weatherInfo.night_text = "晴朗";
    QVariantMap map;
    map.insert("tmp",m_weatherInfo.tmp);
    map.insert("day_code",m_weatherInfo.day_code);
    map.insert("day_text",m_weatherInfo.day_text);
    map.insert("ninght_code",m_weatherInfo.ninght_code);
    map.insert("night_text",m_weatherInfo.night_text);

    return map;
}

void MyObject::setWeatherInfo(QVariantMap map)
{
    qDebug()<<__FUNCTION__;
    qDebug()<<map.value("tmp").toInt()<<map.value("day_text").toString();
}

int MyObject::iValue() const
{
    return m_iValue;
}

void MyObject::setIValue(int newIValue)
{
    if (m_iValue == newIValue)
        return;
    m_iValue = newIValue;
    emit iValueChanged();
}

```

 qml文件

```c++
import QtQuick 2.15
import QtQuick.Controls 2.15
Rectangle{
    x : 100
    y:50

    property string title: ""
    property string unity: ""
    property ListModel dataModel
    ComboBox {
        id: control
        model:dataModel

        //该项只对于上部分显示起作用(标题栏)
        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.color: control.pressed ? "#17a81a" : "#21be2b"
            border.width: control.visualFocus ? 2 : 1
            radius: 2
        }
//        textRole : "text"
//        displayText: textRole + unity

        //控制当前显示内容与background相对应
        contentItem: Text {
            leftPadding: 20
            rightPadding: control.indicator.width + control.spacing

            text: control.displayText
            font: control.font
            color: control.pressed ? "red" : "blue"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight      //右侧省略
        }

        //此处的ItemDeleagate可以换成任何Item，只不过ItemDelegate带有高亮选项
        delegate: ItemDelegate { //针对model中每一项的具体绘制
            width: control.width
            Rectangle{
                anchors.fill: parent
                color: highlighted ? "lightred" : "grey"
            }
            contentItem: Text {
                text: modelData
                color: index %2? "red" : "#21be2b"  //根据下标显示颜色
                font: control.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            //高亮显示
            highlighted: control.highlightedIndex === index
        }


        /***
        indicator: Image{
            source: "qrc:/Image/indicator.png"
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
        }
        ***/

        //用于绘制下拉箭头
        /***
        indicator: Canvas {
            id: canvas
            x: control.width - width - control.rightPadding
            y: control.topPadding + (control.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: control
                function onPressedChanged() { canvas.requestPaint(); }
            }

            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = control.pressed ? "#17a81a" : "#21be2b";
                context.fill();
            }
        }
        ***/

        popup: Popup {
            y: control.height - 1   //用于控制下拉菜单的显示方向，向上或向下
            width: control.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView { //整个内部控件
                clip: true
                interactive: true //是否启用鼠标拖动效果，默认true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex

                ScrollBar.vertical: ScrollBar{ //生成一个垂直下拉条
//                    policy: ScrollBar.AlwaysOn
                }
                ScrollBar.horizontal: ScrollBar{} //生成一个水平滑动条

                footer: Rectangle{
                    height: 10
                    color:"blue"
                }
                header: Rectangle{
                    height: 10
                    color:"blue"
                }
            }

            background: Rectangle {
                border.color: "#21be2b"
                radius: 2
                color : "lightblue"
            }
        }
    }


    ComboBox{
        x : 300
        id:combobox
        width:200
        editable: true //框内可编辑

        model:10
        //输入控制器
        validator: IntValidator{
            top: 20
            bottom: 1
        }
        //当前有没有匹配我们设定的范围，在我们范围内返回true，否则为false
        onAcceptableInputChanged: {
            console.log(acceptableInput)
        }


        /**
        onAccepted: {
            if(find(editText) === -1)
            {
                model.append({text:editText})
            }
        }
        **/

        /**
        textRole: "text"   //textRole控制了下拉列表中要显示的内容
        valueRole: "value"  //text和value都是model中自定义的名字，可以随意定义
        displayText: textRole +" "+ valueRole //在标题栏显示的内容
        model:ListModel{
            id : model
            ListElement{text : "Banana";value : 100}
            ListElement{text : "Apple";value : 200}
            ListElement{text : "Orange";value : 300}
        }
        //    model:[
        //        {text : "Banana",value : 100},
        //        {text : "Apple",value : 200},
        //        {text : "Orange",value : 300}
        //    ]

        onCurrentTextChanged: {
            console.log("text:",currentText)
        }
        onCurrentValueChanged: {
            console.log("value:",currentValue)
        }
        **/

    }
}
```

