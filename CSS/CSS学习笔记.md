# 2、CSS学习笔记

## 2.2、层次选择器

1、后代选择器：在某个元素的后面   祖爷爷  爷爷  爸爸  你`

```css
/**后代选择器**/
body p{
	background:red;
}
```

2、子选择器，一代，儿子

```css
/**子选择器**/
body>p{
    background:red;
}
```

3、相邻兄弟选择器

```css
/**相邻兄弟选择器，只有一个，相邻（向下）**/
.active + p{
    background:red;
}
```

4、通用选择器

```css
/**通用兄弟选择器，当前选中元素的向下所有兄弟元素**/
.active~p{
    background:red;
}
```

## 2.3 结构伪类选择器

```html
 <style>
            /* ul的第一个元素 */
            ul li:first-child{

                background: red;
            }
            /* ul的最后一个元素 */
            ul li:last-child{

                background: green;
            }

            /* 选中p1:定位到父元素，选择当前的第一个元素
            选择当前p元素的父级元素，选中父级元素的第一个，并且是当前元素才生效！ 顺序(h1算第一个)
            */
            p:nth-child(2){
                background:yellow;
            }

            /* 选中p的父元素，下的P元素的第二个！类型，h1不作为p类型，不算数 */
            p:nth-of-type(2)
            {
                background: purple;
            }
            
   </style>
```

## 2.4 属性选择器（重要）

 

```html
<!DOCTYPE html>

<html lang="en">

<!-- head标签代表网页头部 -->

<head>
    <!-- meta标签是描述性标签，它用来描述我们网站的一些信息 -->
    <!-- meta一般用来做SEO -->
    <meta charset="UTF-8">
    <meta name="keywords" content="海亮学习网">
    <meta name="description" content="来这里可以跟我一起学习">
    <!-- title标签代表网页的标题 -->
    <title>来吧大兄弟</Title>
        
        
        <style> /**类选择器 的 后代选择器**/
            .demo a{
                float:left;
                display: block;
                height: 50px;
                width:50px;
                border-radius: 10px;
                background: lightblue;
                color: black;
                text-align: center;
                text-decoration: none;  /*去掉下划线*/
                margin-right: 10px;
                font: bold 20px/50px Arial;
            }

            /* 属性名，属性名 = 属性值（正则） 
                = 绝对等于
                *= 包含
                ^= 以这个开头
                $= 以这个结尾
            */
            /* 选中a标签中带有id属性   a[]{}*/
            a[id]{
                background: green;
            }
            /* 选中title = test的元素 */
            a[title = "test1"]{
                background: red;
            }
            /* class 中有links的元素 */
            a[class *= "links"]
            {
                background: purple;
            }

            /* 选中herf中以http开头的元素 */
            a[href^=http]{
                background: rgb(179, 18, 82);
            }

            /* 以pdf结尾的 */
            a[href$=pdf]{
                background: pink;
            }


        </style>

</head>
<!-- body标签代表网页主体 -->

<body>

    <p class="demo">

        <a href="http://wwww.baidu.com" class="links item  first" target="_blank" id="second">1</a>
        <a href="http://wwww.baidu.com" class="links item active" target="_blank" title="test" id="first">2</a>
        <a href="http://wwww.baidu.com" class="links item active" target="_blank" title="test1" >3</a>
        <a href="images/123.html" class="links tiem">4</a>
        <a href="images/123.png" class="links item">5</a>
        <a href="abc.pdf" class="links item">6</a>
        <a href="abc.doc" class="links item last">7</a>
    </p>

</body>

</html>
```

![image-20230818172133170](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230818172133170.png)

# 3、美化网页元素

## 3.1 为什么美化

span标签：重点突出的字，使用span括起来

## 3.2 字体的样式

```html
<!--  font-family:字体 
              font-size:字体大小
              font-weight:字体粗细
              color:字体颜色
        -->
    <style>
        body {
            font-family: "Arial Black",楷体; /**字体可以用多种**/
            color: red;
        }
        h1{
            font-size: 50px;
        }
        .p1{

            font-weight: bold;
        }
    </style>
```



## 3.3 文本样式

1、颜色 color rgb  rgba

2、文本对齐的方式  text-align = center

3、首行缩进 text-indent:2em;

4、行高  line-height:

5、装饰 text-decoration:underline;

## 3.4 超链接伪类

```html
<style>
        a{
            /* 去掉下划线 */
            text-decoration: none;
        }
        /* 鼠标悬浮态 */
        a:hover{
            color: orange;
            font-size: 20px;
        }
        /* 鼠标按住未释放的状态 */
        a:active{
            color: green;
        }

        /* 阴影效果 */
        #price{
            /* 参数：阴影颜色 水平偏移  垂直偏移 阴影半径 */
            text-shadow: blue 10px 10px 3px;
        }
    </style>
</head>
<!-- body标签代表网页主体 -->

<body>
    <a href="#" >
        <img src="../source/image/123.png" alt="">
    </a>
    <p><a href="#">遥远的救世主</a></p>
    <p><a href="#">豆豆</a></p>
    <p id="price">￥23</p>
    
</body>
```



# 4、盒子模型

## 4.1 什么是盒子

![image-20230821150456294](C:\Users\HP\AppData\Roaming\Typora\typora-user-images\image-20230821150456294.png)



position: 定位盒子的位置

margin:外边距

border:边框

padding:内边距

## 4.2 边框

1、边框的粗细

2、边框的样式

3、边框的颜色

```css
/**body总有一个默认的外边距 margin: 0 **/
/**常见操作
h1,ul,li,a,body{
margin:0;
padding:0;
text-decoration:none;
}
**/

#box{
    width:300px;
    border:1px solid red;
}

h2{
    font-size:16px;
    background:##3cbda6;
    line-height:30px;
    color:white;
}

form{
    background:#3cbda6;
}
div:nth-of-type(1) input{
    border:3px solid black;
}
div:nth-of-type(1) input{
    border:3px dashed black;
}
```

