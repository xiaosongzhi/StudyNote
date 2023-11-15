## 1、 listView的学习

### 1.1使用数字填充Model

```js
ListView{
        width :180
        height:200
        model:3  //model控制了所有数据,可以是数字也可以是list

        delegate: Text{ //delegate 控制了每一项数据是如何绘制的
            text:index
        }
```

效果如下：**==注意在delegate中可以使用*index*访问model的下标==**

![image-20230827161023808](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230827161023808.png)

将Text改成Button效果如下：

![image-20230827161420536](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230827161420536.png)====

spacing: 设置各个项的间距

将spacing属性设置为10之后效果如下：

![image-20230827161740276](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230827161740276.png)

### 1.2 使用数组（列表）填充Model

model中的数据也可使用[]进行填充，==**在delegate中需要使用modelData来获取model中的数据**==

```js
ListView{
        width :180
        height:200
//        model:3  //model控制了所有数据,可以是数字也可以是list
        model:['Button',"Rectangle","MouseArea","CheckBox"]

        spacing: 10 //两个项之间的间距
        delegate: Button{ //delegate 控制了每一项数据是如何绘制的
            text:modelData

        }
    }
```

### 1.3 数据复杂对象ListModel填充数据

对于前两种使用数字和使用数组进行填充时，会有一个局限性，就是数据类型都一样，且每一项中数据元素单一，不能满足复杂的数据填充，所以Qt中提供了填充复杂元素的数据对象ListModel

使用如下：在delegate中可以直接访问ListElement中的名字。在此处我们使用到了ListElement，该数据类型类似于C++中的结构体，其可以使用所有的基本数据类型，但是不能使用复杂的结构类型，比如你可以使用string，double等，但是不能使用诸如Rectangle。官方文档描述如下：**The names used for roles must begin with a lower-case letter and should be common to all elements in a given model. Values must be simple constants;**

```js
ListView{
        width :180
        height:200
        model:listmodel
        spacing: 10 //两个项之间的间距
        delegate: Button{ //delegate 控制了每一项数据是如何绘制的
            text:name + number
        }
    }
    ListModel {
        id:listmodel
        ListElement {
            name: "Bill Smith"
            number: "555 3264"
        }
        ListElement {
            name: "John Brown"
            number: "555 8426"
        }
        ListElement {
            name: "Sam Wise"
            number: "555 0473"
        }
    }
```

**注意：**

此处有两点需要注意

==第一、ListElement中的变量都要小写开头==

==第二、ListElement中的变量都要使用简单的基本数据类型==



### 1.4  实现高亮选中

在实际应用中，我们往往会有这种高亮选中需求，如下动图显示的效果：

![listview高亮](E:\工作笔记\listview高亮.gif)

在该功能中我们需要重点关注以下几点：

**第一、使用到了highlight属性，其显示效果可以自定义，此出我们使用了Rectangle来实现**

**第二、由于这种高亮是给代理中的元素实现的效果，所以代理中的组件Rectangle需要设置为透明，否则高亮显示不出来**

**第三、高亮元素始终对应的是ListView中的CurrentIndex和CurrentItem，想要显示高亮效果需要将index的值赋给CurrentIndex。**

```js
ListView{
        id:list
        width :180
        height:200
        model:listmodel
        spacing: 10 //两个项之间的间距
        highlight: Rectangle{ //高亮显示效果
            color: "yellow"
            radius: 4
            width:100
            height:40
        }
        delegate: Rectangle{ //delegate 控制了每一项数据是如何绘制的
            color: "transparent"    //想要显示高亮，必须去掉此处的底色
            width: 100
            height:40
            Text {
                id: number
                text: name
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                list.currentIndex = index
                }
            }
        }
    }
    ListModel {
        id:listmodel
        ListElement {
            name: "Bill Smith"
            number: "555"
        }
        ListElement {
            name: "John Brown"
            number: "555"
        }
        ListElement {
            name: "Sam Wise"
            number: "555"
        }
    }
```

### 1.5 回弹动画效果

ListView中有一个属性控制了回弹动画的方向**flickableDirection**

This property determines which directions the view can be flicked.

Flickable.AutoFlickDirection (default) - allows flicking vertically if the contentHeight is not equal to the height of the Flickable. Allows flicking horizontally if the contentWidth is not equal to the width of the Flickable.
Flickable.AutoFlickIfNeeded - allows flicking vertically if the contentHeight is greater than the height of the Flickable. Allows flicking horizontally if the contentWidth is greater than to the width of the Flickable. (since QtQuick 2.7)
Flickable.HorizontalFlick - allows flicking horizontally.
Flickable.VerticalFlick - allows flicking vertically.
Flickable.HorizontalAndVerticalFlick - allows flicking in both directions.

演示效果

![listView回弹](E:\工作笔记\listView回弹.gif)

代码如下：

```js
flickableDirection: Flickable.HorizontalFlick //回弹动画效果
```

### 1.6 给ListView添加页眉和页脚

listView中有两个属性，header、footer分别设置页眉和页脚，使用如下：

```js
ListView{
        id:list
        width :180
        height:200
        model:listmodel
        spacing: 10 //两个项之间的间距

        flickableDirection: Flickable.HorizontalFlick //回弹动画效果
        //页眉
        header: Rectangle{
            width:parent.width
            height:10
            color: "red"
        }
        //页脚
        footer: Rectangle{
            width:parent.width
            height:10
            color: "green"
        }
      }
```



该页眉和页脚为listView的一部分，和listView是一个整体，使用效果如下：



![listview页眉页脚](E:\工作笔记\listview页眉页脚.gif)



### 1.7 分标题显示的listView---section

首先我们看下效果：

![image-20230829151837040](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230829151837040.png)



如上图中所示，ListView中总共包含三个模块，使用红色框圈出的部分。small、medium、big分别为各模块的标题，这就好比实现了一级子标题，耳机子标题的效果。此效果我们就是使用section属性来实现。

在ListView中增加如下代码：

```js
section.property: "size"
section.criteria: ViewSection.FullString
section.delegate:sectionHeading
```

控制该代理的显示效果

```js
Component {
        id: sectionHeading
        Rectangle {
            width: 300
            height: 20
            color: "lightsteelblue"

            required property string section

            Text {
                text: parent.section
                font.bold: true
                font.pixelSize: 20
            }
        }
    }
```

总结：以上效果的完整代码如下

```js
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello listview")

    //        model:3  //model控制了所有数据,可以是数字也可以是list
    //        model:['Button',"Rectangle","MouseArea","CheckBox"]


    Component {
        id: sectionHeading
        Rectangle {
            width: 300
            height: 20
            color: "lightsteelblue"

            required property string section

            Text {
                text: parent.section
                font.bold: true
                font.pixelSize: 20
            }
        }
    }

    ListView{
        id:list
        width :180
        height:200
        model:listmodel
        spacing: 10 //两个项之间的间距

        flickableDirection: Flickable.HorizontalFlick //回弹动画效果
        //页眉
//        header: Rectangle{
//            width:parent.width
//            height:10
//            color: "red"
//        }
//        //页脚
//        footer: Rectangle{
//            width:parent.width
//            height:10
//            color: "green"
//        }

        highlight: Rectangle{ //高亮显示效果
            color: "yellow"
            radius: 4
            width:100
            height:40
        }

        delegate: Rectangle{ //delegate 控制了每一项数据是如何绘制的
            color: "transparent"    //想要显示高亮，必须去掉此处的底色
            width: 100
            height:40
            Text {
                id: number
                text: name
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    list.currentIndex = index
                }
            }
        }

        section.property: "size"
        section.criteria: ViewSection.FullString
        section.delegate:sectionHeading
    }

    ListModel {
        id:listmodel
        ListElement {
            name: "Bill Smith"
            number: "555"
            size : "small"
        }
        ListElement {
            name: "John Brown"
            number: "555"
            size : "medium"
        }
        ListElement {
            name: "Sam Wise"
            number: "555"
            size : "big"
        }
    }

}

```

## 2、ComboBox的学习

### 2.1 可编辑属性 editable

combobox的可编辑属性一般都是伴随着onAccepted方法以及find方法综合使用，示例如下：

```js
import QtQuick 2.15
import QtQuick.Controls 2.15
ComboBox{
    id:combobox
    width:200
    editable: true //框内可编辑

    model:ListModel{
        id : model
        ListElement{text : "Banana"}
        ListElement{text : "Apple"}
        ListElement{text : "Orange"}
    }
    onAccepted: {
        if(find(editText) === -1)
        {
            model.append({text:editText})
        }
    }
}
```

如上图所示，代码中写了一个combobox控件，将editable设置为true，此时变为可编辑状态，onAccept接收外部输入的文字，使用find函数进行查找，如果不存在则在model中进行添加。

### 2.2  textRole和valueRole属性,displaytext属性

针对数据项为复杂内容时，我们需要进行显示控制，比如显示数据中的哪一项，这时我们就需要以上两种属性

首先提供一个model

写法1

```js
model:[
        {text : "Banana",value : 100},
        {text : "Apple",value : 200},
        {text : "Orange",value : 300}
    ]
```

写法2

```js
model:ListModel{
        id : model
        ListElement{text : "Banana";value : 100}
        ListElement{text : "Apple";value : 200}
        ListElement{text : "Orange";value : 300}
    }

```

对于以上的数据我们该怎样显示，是显示text呢还是value呢？我们该怎样取text或者value呢？方法如下

```js
ComboBox{
    id:combobox
    width:200
    editable: false //框内可编辑

    textRole: "text"   //textRole控制了下拉列表中要显示的内容
    valueRole: "value"  //text和value都是model中自定义的名字，可以随意定义
    displayText: textRole +" "+ valueRole //在标题栏显示的内容
    model:ListModel{
        id : model
        ListElement{text : "Banana";value : 100}
        ListElement{text : "Apple";value : 200}
        ListElement{text : "Orange";value : 300}
    }
    onCurrentTextChanged: {
        console.log("text:",currentText)
    }
    onCurrentValueChanged: {
        console.log("value:",currentValue)
    }
}
```

![image-20230831140514029](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230831140514029.png)

如上图所示，displaytext控制了上部分显示的文本，并不会影响弹出框的显示，textRole控制了弹出框中显示的内容。

### 2.3 控制输入属性validator

validator有三种类型分别为IntValidator, DoubleValidator, and RegExpValidator，分别代表整型、浮点以及正则表达式。

示例如下：

```js
ComboBox{
    id:combobox
    width:200
    editable: true //框内可编辑

    model:10
    //输入控制器
    validator: IntValidator{
        top: 1
        bottom: 20
    }
 }
```

如代码所示，我们控制其输入范围是1~20，但是在输入是我们发现并不是这么回事，如下动图

![comboboxI输入控制](E:\工作笔记\comboboxI输入控制.gif)

我们打印一下输入判断使用如下代码

```js
ComboBox{
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
}
```

其中，onAcceptableInputChanged为检验输入内容是否合法，当输入的内容合法时返回true。否则为false。所以在此时我们要想控制输入需要配合该函数，或者是使用正则表达式进行控制。

### 2.4 自定义combobox

想要自己定义combobox则我们首先要拆解一下combobox都有哪几部分，下方为一个combobox的简单示意图：

![Dingtalk_20230831210704](E:\工作笔记\Dingtalk_20230831210704.jpg)![Dingtalk_20230831210704](E:\工作笔记\Dingtalk_20230831210735.jpg)

如上图所示，左侧为一个控件示意图，右侧为一个实际控件截图。从左侧图中可以看出combobox是一个复合控件，主要包含标题栏、弹出框、下拉图标、横竖两个滑条。下面我们详细说下各个部分所对应的属性。



#### 2.4.1 “标题栏”

我们在没有弹出下拉框时显示的部分定义为标题栏，也就是红色框部分。我们看下代码：

```js
 ComboBox {
        id: control
        model: ["First", "Second", "Third","Fourth","Fifth"]

        //该项只对于上部分显示起作用(标题栏)
        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.color: control.pressed ? "#17a81a" : "#21be2b"
            border.width: control.visualFocus ? 2 : 1
            radius: 2
        }

        //控制当前显示内容与background相对应
        contentItem: Text {
            leftPadding: 0
            rightPadding: control.indicator.width + control.spacing

            text: control.displayText
            font: control.font
            color: control.pressed ? "red" : "blue"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight      //右侧省略
        }
 }
```

以上代码中，我们主要控制标题栏显示的主要有两个属性，**background**和**contentItem**，其中background决定了标题栏的背景显示效果，contentItem控制了标题栏中文字显示效果。各司其职，相互协作呈现出我们想要的效果。

#### 2.4.2 "数据项"

如上图所示，我们将绿框中的内容称之为数据项，数据项主要从model中获取数据，使用delegate来呈现。代码如下：

```js
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
```

delegate控制了每一项数据的具体绘制，包括数据项背景的绘制，文字内容的呈现效果。如上述代码中Rectangle实现了数据项高亮与非高亮的显示效果。而contentItem主要控制着每一项数据的呈现效果，比如通过Index的奇偶数来设置数据项文字的颜色。该代码块中还设置了高亮的判断，即highlighted: control.highlightedIndex === index



#### 2.4.3 下拉箭头

下拉箭头即标题栏中的下拉箭头，直接上代码吧，这块相对简单

方法一：通过载入图片来实现效果

```js
indicator: Image{
            source: "qrc:/Image/indicator.png"
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
        }
```

方法二：通过canvas绘制来实现效果

```js
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
```

#### 2.4.4 下拉弹框

下拉弹窗中包含了要显示的数据项，左右滑条以及一个大的背景Rectangle，下面我们通过代码进行讲解

```js
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

                highlight: Rectangle{
                    color: "red"
                    width: 220;
                    height: 10
                }

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
```

1、popup中有一个 y 属性，该属性可控制弹窗显示的方位，是向上还是向下

2、popup中的contentItem控制了popup弹窗整个内部空间，也即褐色框内的显示效果。此处的contentItem使用的listView控件控制显示，此处也可换成其他Item类型。

3、background控制了弹框显示的背景色。对其他内容不做影响。



完整代码如下：

```js
ComboBox {
        id: control
        model: ["First", "Second", "Third","Fourth","Fifth"]

        //该项只对于上部分显示起作用(标题栏)
        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.color: control.pressed ? "#17a81a" : "#21be2b"
            border.width: control.visualFocus ? 2 : 1
            radius: 2
        }

        //控制当前显示内容与background相对应
        contentItem: Text {
            leftPadding: 0
            rightPadding: control.indicator.width + control.spacing

            text: control.displayText
            font: control.font
            color: control.pressed ? "red" : "blue"
            verticalAlignment: Text.AlignVCenter
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
```









