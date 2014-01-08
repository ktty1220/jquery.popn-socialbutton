###!
* jQuery POP'n SocialButton v0.1.8
*
* http://github.com/ktty1220/jquery.popn-socialbutton
*
* 参考サイト
*
* - http://q.hatena.ne.jp/1320898356
* - http://stackoverflow.com/questions/5699270/how-to-get-share-counts-using-graph-api
* - http://stackoverflow.com/questions/8853342/how-to-get-google-1-count-for-current-page-in-php
* - http://hail2u.net/blog/coding/jquery-query-yql-plugin.html
* - http://hail2u.net/blog/coding/jquery-query-yql-plugin-supports-open-data-tables.html
* - http://www.absolute-keitarou.net/blog/?p=1068
*
* Copyright (c) 2013 ktty1220 ktty1220@gmail.com
* Licensed under the MIT license
###
#jshint jquery:true, forin:false

do (jQuery) ->
  'use strict'
  $ = jQuery

  $.fn.popnSocialButton = (services, options = {}) ->
    exOptions = $.extend {},
      url: document.location.href
      text: $('title').html()
      imgDir: './img'
      buttonSpace: 24
      countPosition:
        top: 32
        right: -12
      countColor:
        text: '#ffffff'
        bg: '#cc0000'
        textHover: '#ffffff'
        bgHover: '#ff6666'
        border: '#ffffff'
      countSize: 11
      popupWindow:
        width: 640
        height: 480
    , options
    exOptions.urlOrg = exOptions.url
    exOptions.url = encodeURIComponent exOptions.url
    exOptions.text = encodeURIComponent exOptions.text

    # ボタン画像のサイズ
    iconSize = 44
    # ボタンの浮き上がり距離
    popnUp = 4
    # 現在のページのURLスキーム
    scheme = if /https/.test document.location.protocol then 'https' else 'http'
    # YQLのURL作成
    mkYQL = (url) -> "#{scheme}://query.yahooapis.com/v1/public/yql?env=http://datatables.org/alltables.env&q=#{encodeURIComponent "SELECT content FROM data.headers WHERE url='#{url}' and ua='Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 5.1)'"}"

    servicesProp =
      twitter:
        img: 'twitter_2x.png'
        alt: 'Twitter Share Button'
        shareUrl: "https://twitter.com/share?url=#{exOptions.url}&text=#{exOptions.text}"
        commentUrl: "https://twitter.com/search/?q=#{exOptions.url}"
        countUrl: "http://urls.api.twitter.com/1/urls/count.json?url=#{exOptions.url}"
        jsonpFunc: (json, cb) -> cb(json.count ? 0)

      facebook:
        img: 'facebook_2x.png'
        alt: 'Facebook Share Button'
        shareUrl: "https://www.facebook.com/sharer.php?u=#{exOptions.url}&t=#{exOptions.text}"
        countUrl: "https://graph.facebook.com/#{exOptions.url}"
        jsonpFunc: (json, cb) ->
          ###
          * - Graph APIでsharesが取得できない場合はFQLでtotal_countを取得する
          * - Graph APIのlikes + FQLのtotal_countでいいねボタンと同じ件数になる模様(いくつかのケースを調べた結果)
          * - ほとんどのサイトではFQLのtotal_countだけでいいねボタンと同じ件数になる
          ###
          return cb(json.shares) if json.shares?
          graphLikes = json.likes ? 0
          $.ajax
            url: "https://graph.facebook.com/fql?q=#{encodeURIComponent "SELECT total_count FROM link_stat WHERE url='#{exOptions.urlOrg}'"}"
            dataType: 'jsonp'
          .done (json) ->
            fqlTotal = json.data[0]?.total_count ? 0
            cb(graphLikes + fqlTotal)

      hatebu:
        img: 'hatena_bookmark_2x.png'
        alt: 'Hatena Bookmark Share Button'
        shareUrl: "http://b.hatena.ne.jp/add?mode=confirm&url=#{exOptions.url}&title=#{exOptions.text}&mode=confirm"
        commentUrl: "http://b.hatena.ne.jp/entry/#{exOptions.urlOrg}"
        countUrl: "http://api.b.st-hatena.com/entry.count?url=#{exOptions.url}"
        jsonpFunc: (json, cb) -> cb(json ? 0)

      gplus:
        img: 'google+1_2x.png'
        alt: 'Google Plus Share Button'
        shareUrl: "https://plusone.google.com/share?url=#{exOptions.url}"
        ###
        * - Google+1ボタンはシェア数に関するjsonpを提供していない(jsonすら提供していない)ので+1ボタンのhtmlを取得してその中から件数を取得する
        * - クロスドメインによる取得になるのでYQLを使用する
        * - ただしgoogleのサーバーに設置してあるrobots.txtはYQL(というかYahooのロボット全般？)のUAを拒否するのでOpen Data Tableのdata.headerプラグインを使用する
        ###
        countUrl: mkYQL "https://plusone.google.com/_/+1/fastbutton?hl=ja&url=#{exOptions.urlOrg}"
        jsonpFunc: (json, cb) ->
          count = 0
          if json.query?.count > 0
            m = json.results[0].match /window\.__SSR = {c: ([\d]+)/
            count = m[1] if m?
          cb count

      pocket:
        img: 'pocket_2x.png'
        alt: 'Pocket Stock Button'
        shareUrl: "https://getpocket.com/save?url=#{exOptions.url}&title=#{exOptions.text}"
        ###
        * Google+1ボタンと同様にYQLでカウントを取得する
        ###
        countUrl: mkYQL "https://widgets.getpocket.com/v1/button?label=pocket&count=vertical&align=left&v=1&url=#{exOptions.urlOrg}&src=#{exOptions.urlOrg}&r=#{Math.random() * 100000000}"
        jsonpFunc: (json, cb) ->
          count = 0
          if json.query?.count > 0
            m = json.results[0].match /em id="cnt"&gt;(\d+)&lt;/
            count = m[1] if m?
          cb count

      github:
        img: 'github_alt_2x.png'
        alt: 'GitHub Repository'
        shareUrl: "https://github.com/#{exOptions.githubRepo}"
        commentUrl: "https://github.com/#{exOptions.githubRepo}/stargazers"
        countUrl: "https://api.github.com/repos/#{exOptions.githubRepo}"
        jsonpFunc: (json, cb) -> cb(json.data.watchers ? 0)

    _addLink = (name, prop, idx) =>
      wrapTag = $('<div/>').attr(
        class: "popn-socialbutton-wrap #{name}"
      ).css
        'float': 'left'
        position: 'relative'
        width: iconSize
        height: iconSize
        marginTop: popnUp
      wrapTag.css marginLeft: exOptions.buttonSpace if idx > 0

      shareTag = $('<a/>').attr(
        href: prop.shareUrl
        class: 'popn-socialbutton-share'
        target: '_blank'
      ).css
        outline: 'none'
        display: 'block'
        width: '100%'
        height: '100%'

      imgTag = $('<img/>').attr(
        src: "#{exOptions.imgDir}/#{prop.img}"
        alt: prop.alt
      ).css
        border: 'none'

      countTagType = if prop.commentUrl then 'a' else 'span'
      countTag = $("<#{countTagType}/>").attr class: 'popn-socialbutton-count'
      if countTagType is 'a'
        countTag.attr
          href: prop.commentUrl
          target: '_blank'
      else
        countTag.css cursor: 'default'

      countTag.css $.extend {},
        display: 'none'
        position: 'absolute'
        color: exOptions.countColor.text
        backgroundColor: exOptions.countColor.bg
        border: "solid 2px #{exOptions.countColor.border}"
        fontSize: exOptions.countSize
        textDecoration: 'none'
        outline: 'none'
        fontWeight: 'bold'
        #lineHeight: 1.5
        padding: '0 4px'
        borderRadius: 6
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.8)'
        zIndex: 1
      , exOptions.countPosition

      wrapTag.append(shareTag.append(imgTag)).append countTag
      $(@).append wrapTag

      $.ajax
        url: prop.countUrl
        dataType: 'jsonp'
      .done (json) -> prop.jsonpFunc json, (count) -> countTag.show().text count

    for sName, idx in services
      _addLink sName, servicesProp[sName], idx if servicesProp[sName]?
    $(@).height iconSize + popnUp

    $(@).find('.popn-socialbutton-share').click () ->
      return true if $(@).parent().hasClass 'github'
      top = (screen.height / 2) - (exOptions.popupWindow.height / 2)
      left = (screen.width / 2) - (exOptions.popupWindow.width / 2)
      window.open @href, '', "width=#{exOptions.popupWindow.width}, height=#{exOptions.popupWindow.height}, top=#{top}, left=#{left}"
      false

    $(@).find('a.popn-socialbutton-count').mouseenter () ->
      $(@).css
        color: exOptions.countColor.textHover
        backgroundColor: exOptions.countColor.bgHover
    .mouseleave () ->
      $(@).css
        color: exOptions.countColor.text
        backgroundColor: exOptions.countColor.bg

    $(@).find('.popn-socialbutton-wrap').mouseenter () ->
      $(@).stop().animate marginTop: 0, 100, 'swing'
    .mouseleave () ->
      $(@).stop().animate marginTop: 4, 100, 'swing'
