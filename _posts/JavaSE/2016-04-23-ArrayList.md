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

作为Java中常用的容器之一，ArrayList无疑占据了相当大的比重，也是我们学习Java以来接触最多的数据集合，相信大家对它的使用早就达到了可以信手拈来的程度。然而，当我们潇洒的调用add()进行添加操作的时候，是否考虑过ArrayList的容量问题。当我们调用get()方法获取元素时，底层又是如何获得具体的对象值，ArrayList的使用场景与其他集合究竟有什么异同？

> Resizable-array implementation of the <tt>List</tt> interface.  Implements all optional list operations, and permits all elements, including <tt>null</tt>.  In addition to implementing the <tt>List</tt> interface, this class provides methods to manipulate the size of the array that is used internally to store the list.  (This class is roughly equivalent to <tt>Vector</tt>, except that it is unsynchronized.)

首先看一个关于集合的结构图：

![](http://cdowv.img48.wal8.com/img48/519761_20150601204824/1464240935.jpg)

本文将通过阅读源代码的方式为大家展现ArrayList的内部构造和实现过程。重点关注ArrayList的构造方法和自动扩容机制。

首先是一组变量声明。

{% highlight java %} 
private static final int DEFAULT_CAPACITY = 10;
transient Object[] elementData; // non-private to simplify nested class access
private int size;
{% endhighlight %}

不难看出这里声明了一个Object数组作为ArrayList的底层存储，并且固定初始容量为10，然后声明了一个记录ArrayList大小的整型变量。

{% highlight java %} 
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
{% endhighlight %}

{% highlight java %} 
private void ensureCapacityInternal(int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    ensureExplicitCapacity(minCapacity);
}
{% endhighlight %}

{% highlight java %} 
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;
    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
{% endhighlight %}

真正的逻辑处理在下面的grow方法中：

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
