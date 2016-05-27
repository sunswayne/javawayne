---
published: true
author: Wayne Sun
layout: post
title: ArrayList实现原理解析
category: JavaSE
summary: 作为Java中常用的容器之一，ArrayList无疑占据了相当大的比重，也是我们学习Java以来接触最多的数据集合，相信大家对它的使用早就达到了可以信手拈来的程度。然而，当我们潇洒的调用add()进行添加操作的时候，是否考虑过ArrayList的容量问题。当我们调用get()方法获取元素时，底层又是如何获得具体的对象值，ArrayList的使用场景与其他集合究竟有什么异同？
tags:
  - Java
  - ArrayList
  - 自动扩容
---

`文/孙少伟`

作为Java中常用的容器之一，<tt>ArrayList</tt>无疑占据了相当大的比重，也是我们学习Java以来接触最多的数据集合，相信大家对它的使用早就达到了可以信手拈来的程度。然而，当我们潇洒的调用add()进行添加操作的时候，是否考虑过ArrayList的容量问题。当我们调用get()方法获取元素时，底层又是如何获得具体的对象值，ArrayList的使用场景与其他集合究竟有什么异同？

惯例，先上一段ArrayList的官方注解：

> Resizable-array implementation of the <tt>List</tt> interface.  Implements all optional list operations, and permits all elements, including <tt>null</tt>.  In addition to implementing the <tt>List</tt> interface, this class provides methods to manipulate the size of the array that is used internally to store the list.  (This class is roughly equivalent to <tt>Vector</tt>, except that it is unsynchronized.)

ArrayList是一项以动态数组作为List接口实现的技术，并实现了其所有方法。ArrayList允许存放任何元素包括null值。其中有一段话颇有点耐人寻味，<q>**ArrayList除了实现了List的所有方法外，还提供了操作数组大小的方法**</q>(竟然有这样的方法？囧，为什么我从来没有用过？)，别急，还有下文。官方又说：<q>**仅在内部用作存储List**</q>。哦哦哦，这下懂了，ArrayList的实质不就是对Array进行了封装嘛，虽然内部依旧是数组，但暴露给我们的仅仅是十分简单的add方法。像这种操作底层数组的方法，自然用不着我们来调用，因为全都由ArrayList帮我们代劳就好了。(注：官方尤其提到<q>**ArrayList和Vector同时作为List的实现类大体上是相同的，除了缺少同步机制**</q>)

接下来看一个关于集合的结构图:

![](http://cdowv.img48.wal8.com/img48/519761_20150601204824/1464240935.jpg)

不难看出，ArrayList显然是Collection集合的高级实现，与之同级别的还有LinkedList和Vector，也是后续我们将要涉及的概念。本文将通过阅读源代码的方式为大家展现ArrayList的内部构造和实现过程，主要关注ArrayList的构造方法和自动扩容机制。

首先是一组变量声明:

{% highlight java %} 
private static final int DEFAULT_CAPACITY = 10;
transient Object[] elementData; // non-private to simplify nested class access
private int size;
{% endhighlight %}

不难看出，这里声明了一个Object数组作为ArrayList的底层存储，并且使初始容量为<tt>10</tt>，然后声明了一个记录ArrayList大小的整型变量size。

**ArrayList构造方法**。再来看一下ArrayList的三个构造方法：

{% highlight java %} 
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}
{% endhighlight %}

第一个构造方法。

{% highlight java %} 
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // replace with empty array.
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
{% endhighlight %}

第二个构造方法。

{% highlight java %} 
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    }
}
{% endhighlight %}

第三个构造方法。

**ArrayList自动扩容机制**。本人用的是<tt>JDK1.8</tt>，对比之前的JDK版本会发现关于add方法1.8版本进行了重构，代码变得更加结构化，也更加清晰易读。

{% highlight java %} 
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
{% endhighlight %}

此add方法用作添加已经指定类型的元素。这里使用模计数来计算增量，并把添加进来的元素赋值到末尾位置。

{% highlight java %} 
private void ensureCapacityInternal(int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    ensureExplicitCapacity(minCapacity);
}
{% endhighlight %}

首先传递list增加元素之后的大小size，并判断当前Object数组是否为空，如果为空，则把size和默认容量10作比较，取最大的一方作为新的容量值。如果当前list不为空，则继续向下进行，确保精确容量。

{% highlight java %} 
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;
    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
{% endhighlight %}

这里模计数加1，判断如果当前容量大于初始容量，则实现增加方法。

{% highlight java %} 
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
{% endhighlight %}

到了这里我们方才能够一窥庐山真面目。首先把原始容量进行位运算，其效果等同于int newCapacity = (oldCapacity * 3)/2，如果没记错的话，之前的JDK版本用的是这样的代码<tt>int newCapacity = (oldCapacity * 3)/2 + 1;</tt>，这也是JDK1.8做出的新改变，位运算的速度总是比普通运算快很多。如果新扩容的数组长度还是比最小需要的容量小，则以最小需要的容量为长度进行扩容。不禁感叹，JVM在内存分配上真是抠门啊，似乎像是在菜市场买菜时讨价还价一样，直接做这一步哪里有那么多事，一点也不豪爽。当获得了最新的容量值后，最后调用Array的copyOf方法给当前list扩容。

现在想想，ArrayList的自动扩容，似乎远远不是给数组长度加1那么简单。

最后是remove方法。

{% highlight java %} 
public boolean remove(Object o) {
    if (o == null) {
        for (int index = 0; index < size; index++)
            if (elementData[index] == null) {
                fastRemove(index);
                return true;
            }
    } else {
        for (int index = 0; index < size; index++)
            if (o.equals(elementData[index])) {
                fastRemove(index);
                return true;
            }
    }
    return false;
}

private void fastRemove(int index) {
    modCount++;
    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
    elementData[--size] = null; // clear to let GC do its work
}
{% endhighlight %}

到这里关于ArrayList的内容就基本结束了。
