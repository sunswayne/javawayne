---
layout: page
title: Categories
permalink: /categories/
---

<ul class="tags-box">
   {% if site.posts != empty %}
      {% for cat in site.categories %}
         {% if cat[0] == 'db' %}
         <a href="#{{ cat[0] }}" title="{{ cat[0] }}" rel="{{ cat[1].size }}">DB<span class="size"> {{ cat[1].size }}</span></a>
         {% elsif cat[0] == 'javase' %}
         <a href="#{{ cat[0] }}" title="{{ cat[0] }}" rel="{{ cat[1].size }}">JavaSE<span class="size"> {{ cat[1].size }}</span></a>
         {% elsif cat[0] == 'j2ee' %}
         <a href="#{{ cat[0] }}" title="{{ cat[0] }}" rel="{{ cat[1].size }}">J2EE<span class="size"> {{ cat[1].size }}</span></a>
         {% elsif cat[0] == 'swift' %}
         <a href="#{{ cat[0] }}" title="{{ cat[0] }}" rel="{{ cat[1].size }}">Swift<span class="size"> {{ cat[1].size }}</span></a>
         {% else %}
         <a href="#{{ cat[0] }}" title="{{ cat[0] }}" rel="{{ cat[1].size }}">{{ cat[0] | join: "/" | capitalize }}<span class="size"> {{ cat[1].size }}</span></a>
         {% endif %}
      {% endfor %}
</ul>

<ul class="tags-box">
   {% for cat in site.categories %}
      {% if cat[0] == 'db' %}
         <li id="{{ cat[0] }}">DB</li>
      {% elsif cat[0] == 'javase' %}
         <li id="{{ cat[0] }}">JavaSE</li>
      {% elsif cat[0] == 'j2ee' %}
         <li id="{{ cat[0] }}">J2EE</li>
      {% elsif cat[0] == 'swift' %}
         <li id="{{ cat[0] }}">Swift</li>
      {% else %}
         <li id="{{ cat[0] }}">{{ cat[0] | capitalize }}</li>
      {% endif %}
      {% for post in cat[1] %}
         <time datetime="{{ post.date | date:"%Y-%m-%d" }}">{{ post.date | date:"%Y-%m-%d" }}</time> &raquo;
         <a href="https://sunswayne.com/{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a><br />
      {% endfor %}
   {% endfor %}
   {% else %}
      <span>No posts</span>
   {% endif %}
</ul>
