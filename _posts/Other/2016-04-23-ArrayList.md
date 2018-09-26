---
published: true
author: Wayne Sun
layout: post
title: 深入理解ArrayList的实现原理
category: JavaSE
summary: 作为<tt>Java</tt>中常用的容器之一，<tt>ArrayList</tt>无疑占据了相当大的比重，也是我们学习<tt>Java</tt>以来接触最多的数据集合，相信大家对它的使用早就达到了可以信手拈来的程度。然而，当我们潇洒的调用<tt>add()</tt>进行添加操作的时候，是否考虑过<tt>ArrayList</tt>的容量问题。当我们调用<tt>get()</tt>获取元素时，底层又是如何获得具体的对象值，<tt>ArrayList</tt>的使用场景与其他集合究竟有什么异同？
tags:
  - Java
  - ArrayList
  - 自动扩容
---

`文/孙少伟`

作为<tt>Java</tt>中常用的容器之一，<tt>ArrayList</tt>无疑占据了相当大的比重，也是我们学习<tt>Java</tt>以来接触最多的数据集合，相信大家对它的使用早就达到了可以信手拈来的程度。然而，当我们潇洒的调用<tt>add()</tt>进行添加操作的时候，是否考虑过<tt>ArrayList</tt>的容量问题。当我们调用<tt>get()</tt>方法获取元素时，底层又是如何获得具体的对象值，<tt>ArrayList</tt>的使用场景与其他集合究竟有什么异同？

惯例，先上一段<tt>ArrayList</tt>的官方注解：

> Resizable-array implementation of the <tt>List</tt> interface.  Implements all optional list operations, and permits all elements, including <tt>null</tt>.  In addition to implementing the <tt>List</tt> interface, this class provides methods to manipulate the size of the array that is used internally to store the list.  (This class is roughly equivalent to <tt>Vector</tt>, except that it is unsynchronized.)

<tt>ArrayList</tt>是一项以动态数组作为List接口实现的技术，并实现了其所有方法。ArrayList允许存放任何元素包括<tt>null</tt>值。其中有一段话颇有点耐人寻味，<q>**ArrayList除了实现了<tt>List</tt>的所有方法外，还提供了操作数组大小的方法**</q>(竟然有这样的方法？囧，为什么我从来没有用过？)，别急，还有下文。官方又说：<q>**仅在内部用作存储List**</q>。哦哦哦，这下懂了，<tt>ArrayList</tt>的实质不就是对<tt>Array</tt>进行了封装嘛，虽然内部依旧是数组，但暴露给我们的仅仅是十分简单的<tt>add()</tt>。像这种操作底层数组的方法，自然用不着我们来调用，因为全都由<tt>ArrayList</tt>帮我们代劳就好了。(注：官方尤其提到<q>**<tt>ArrayList</tt>和<tt>Vector</tt>同时作为<tt>List</tt>的实现类大体上是相同的，除了缺少同步机制**</q>)

接下来看一个关于集合的结构图:

![](http://cdowv.img48.wal8.com/img48/519761_20150601204824/1464240935.jpg)

不难看出，<tt>ArrayList</tt>显然是<tt>Collection</tt>集合的高级实现，与之同级别的还有<tt>LinkedList</tt>和<tt>Vector</tt>，也是后续我们将要涉及的概念。本文将通过阅读源代码的方式为大家展现<tt>ArrayList</tt>的内部构造和实现过程，主要关注<tt>ArrayList</tt>的<q>构造方法</q>和<q>自动扩容机制</q>。

首先是一组变量声明:

{% highlight java %} 
private static final int DEFAULT_CAPACITY = 10;
transient Object[] elementData; // non-private to simplify nested class access
private int size;
{% endhighlight %}

不难看出，这里声明了一个<tt>Object[]</tt>作为<tt>ArrayList</tt>的底层存储，并且使默认容量为<tt>10</tt>，然后声明了一个记录<tt>ArrayList</tt>大小的整型变量<tt>size</tt>。这里可能会感到奇怪，为什么要单独用一个变量记录<tt>elementData</tt>的长度，而不是直接用<tt>elementData.length</tt>，这是因为数组是定长的，当有元素为<tt>null</tt>时，出于节省容量的目的不需要再保存它们，因此会调用<tt>trimToSize()</tt>调整容量至当前实际元素的大小，所以数组实际存储容量并不等于<tt>elementData.length</tt>。

**ArrayList构造方法**。再来看一下<tt>ArrayList</tt>的三个构造方法：

{% highlight java %} 
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}
{% endhighlight %}

该构造方法是空构造，意味着当我们<tt>new ArrayList()</tt>的时候，会分配一个<tt>{}</tt>给该<tt>list</tt>。

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

该构造方法是构造一个包含指定集合的<tt>list</tt>，判断如果传入的集合长度不为空，且调用<tt>toArray()</tt>之后其<tt>class</tt>类型不为<tt>Object[]</tt>才重新<tt>copy</tt>到一个新的<tt>Object[]</tt>，长度和指定<tt>list</tt>相等。需要说明的是，该方法使用了泛型中的**PECS**原则<q>生产者(Producer)使用extends，消费者(Consumer)使用super</q>，用来专门提供<q>E</q>类型的元素，以确保取到的元素类型都是<q>E</q>。

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

该构造方法是构造一个具有默认容量大小的<tt>list</tt>，这里只考虑容量<tt>>=0</tt>的情况，否则抛出异常。当指定<tt>0</tt>时，与调用空构造方法的效果相同，指定<tt>>0</tt>的容量时，则<tt>new</tt>一个相应大小的<tt>Object[]</tt>作为当前<tt>list</tt>的容量。

**ArrayList自动扩容机制**。本人用的是<tt>JDK1.8</tt>，对比之前的JDK版本会发现关于<tt>add()</tt>1.8版本进行了重构，代码变得更加结构化，也更加清晰易读。

{% highlight java %} 
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
{% endhighlight %}

此<tt>add()</tt>用作添加已经指定类型的元素，把添加进来的元素赋值到末尾位置。

{% highlight java %} 
private void ensureCapacityInternal(int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    ensureExplicitCapacity(minCapacity);
}
{% endhighlight %}

首先传递当前容量作为最小容量，并判断当前<tt>Object[]</tt>是否为空，如果为空，则把最小容量和<tt>DEFAULT_CAPACITY</tt>作比较，取最大的一方作为新的容量值。如果当前<tt>list</tt>不为空，则继续向下进行，确保精确容量。

{% highlight java %} 
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;
    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
{% endhighlight %}

判断如果当前容量大于初始容量，则实现增加方法。

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

到了这里我们方才能够一窥庐山真面目。首先把原始容量进行位运算，其效果等同于<tt>int newCapacity = (oldCapacity * 3)/2</tt>。如果没记错的话，这也是之前的JDK版本所沿用的代码，也算是<tt>JDK1.8</tt>做出的新改变，位运算的速度总是比普通运算快很多。**如果新扩容的数组长度还是比最小需要的容量小，则以最小需要的容量为长度进行扩容。反之，如果扩容的长度大于数组最大容量，也要强行设定上限**。当获得了最新的容量值后，最后调用<tt>Array</tt>的<tt>copyOf()</tt>给当前数组扩容。值得一提的是，<tt>Array</tt>的这种拷贝，是要移动所有数据元素的，因此造成的开销相当的大，因此也就明白了为什么<tt>JVM</tt>在进行扩容的时候如此之谨慎了吧。

现在想想，<tt>ArrayList</tt>在调用<tt>add()</tt>时的自动扩容，其本质就是给数组的扩容。但经过这么一番分析，发现远远不是给数组长度加1那么简单。

<tt>add()</tt>到此结束，再来看看<tt>remove()</tt>：

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

<tt>ArrayList</tt>的<tt>remove()</tt>相比较而言就显得简单多了，实现原理是传入待删除元素的下标到<q>快速删除</q>方法，然后进行数组内部的<tt>copy</tt>，移动量取决于下标所处的位置。

到这里关于<tt>ArrayList</tt>的内容就基本结束了。
