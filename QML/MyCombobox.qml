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



