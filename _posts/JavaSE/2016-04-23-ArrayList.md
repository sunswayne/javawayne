---
published: true
author: Wayne Sun
layout: post
title: ArrayList和LinkedList
category: JavaSE
summary: 提到HashMap，想必都不会陌生，作为Java开发中最为常用的几个数据集合之一，HashMap的出场率简直不要太高。不管你是仅仅为了应付面试，还是纯粹的的想要深入学习，对于你自己代码中经常在敲的「家伙」多些了解总是没有坏处的，以下就让我们来一窥它的庐山真面目。
tags:
  - Java
  - ArrayList
---

`文/孙少伟`

作为Java中常用的容器之一，ArrayList无疑占据了相当大的比重，也是我们学习Java以来接触最多的数据集合，相信大家对它的使用早就达到了可以信手拈来的程度。然而，当我们潇洒的调用add()进行添加操作的时候，是否考虑过ArrayList的容量问题。当我们调用get()方法获取元素时，底层又是如何获得具体的对象值。ArrayList和LinkedList在性能和使用场景方面究竟有什么异同？我们将从以下两个方面对ArrayList进行详细分析：

* ArrayList自动扩容
* ArrayList和LinkedList对比

「」

> 

{% highlight java %} 
/**
 * Default initial capacity.
 */
private static final int DEFAULT_CAPACITY = 10;
/**
 * The array buffer into which the elements of the ArrayList are stored.
 * The capacity of the ArrayList is the length of this array buffer. Any
 * empty ArrayList with elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA
 * will be expanded to DEFAULT_CAPACITY when the first element is added.
 */
transient Object[] elementData; // non-private to simplify nested class access

/**
 * The size of the ArrayList (the number of elements it contains).
 *
 * @serial
 */
private int size;
{% endhighlight %}

**  ** 