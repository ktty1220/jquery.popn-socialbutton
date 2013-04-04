###!
* jQuery POP'n SocialButton v0.1.1
*
* http://github.com/ktty1220/jquery.popn-socialbutton
*
* Copyright (c) 2013 ktty1220 ktty1220@gmail.com
* Licensed under the MIT license
###
#jshint jquery:true, forin:false

do (jQuery) ->
  'use strict'

  $ = jQuery
  ###*
  * Twitter:ツイート数とFacebook:いいね数を取得
  * 参考: http://q.hatena.ne.jp/1320898356
  ###
  $.fn.popnSocialButton = (services, options = {}) ->
    exOptions = $.extend {},
      url: location.href
      text: $('title').html()
      imgDir: './img'
      buttonSpace: 12
      countPosition:
        top: 32
        right: -12
      countColor:
        text: '#ffffff'
        bg: '#cc0000'
        textHover: '#ffffff'
        bgHover: '#ff6666'
        border: '#ffffff'
      countSize: 10
    , options
    exOptions.urlOrg = exOptions.url
    exOptions.url = encodeURIComponent exOptions.url
    exOptions.text = encodeURIComponent exOptions.text

    iconSize = 44
    popnUp = 4

    servicesProp =
      twitter:
        img: 'twitter_2x.png'
        alt: 'Twitter Share Button'
        shareUrl: "https://twitter.com/share?url=#{exOptions.url}&text=#{exOptions.text}"
        commentUrl: "https://twitter.com/search/?q=#{exOptions.url}"
        countUrl: "http://urls.api.twitter.com/1/urls/count.json?url=#{exOptions.url}"
        jsonpFunc: (json) -> json.count ? 0

      facebook:
        img: 'facebook_2x.png'
        alt: 'Facebook Share Button'
        shareUrl: "http://www.facebook.com/sharer.php?u=#{exOptions.url}&t=#{exOptions.text}"
        countUrl: "https://graph.facebook.com/#{exOptions.url}"
        jsonpFunc: (json) -> json.shares ? 0

      hatebu:
        img: 'hatena_bookmark_2x.png'
        alt: 'Hatena Bookmark Share Button'
        shareUrl: "http://b.hatena.ne.jp/add?mode=confirm&url=#{exOptions.url}&title=#{exOptions.text}&mode=confirm"
        commentUrl: "http://b.hatena.ne.jp/entry/#{exOptions.urlOrg}"
        countUrl: "http://api.b.st-hatena.com/entry.count?url=#{exOptions.url}"
        jsonpFunc: (json) -> json ? 0

    _addLink = (name, prop) =>
      wrapTag = $('<div/>').attr(
        class: "popn-socialbutton-wrap #{name}"
      ).css
        float: 'left'
        position: 'relative'
        width: iconSize
        height: iconSize
        marginTop: popnUp
        marginLeft: exOptions.buttonSpace
        marginRight: exOptions.buttonSpace

      shareTag = $('<a/>').attr(
        href: prop.shareUrl
        class: 'popn-socialbutton-share'
        target: '_blank'
      ).css
        display: 'block'
        width: '100%'
        height: '100%'

      imgTag = $('<img/>').attr(
        src: "#{exOptions.imgDir}/#{prop.img}"
        alt: prop.alt
      ).css
        border: 'none'

      countCSS = $.extend {},
        display: 'none'
        position: 'absolute'
        color: exOptions.countColor.text
        backgroundColor: exOptions.countColor.bg
        border: "solid 2px #{exOptions.countColor.border}"
        fontSize: exOptions.countSize
        textDecoration: 'none'
        fontWeight: 'bold'
        lineHeight: 1.5
        padding: '0 4px'
        borderRadius: 6
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.8)'
        zIndex: 1
      , exOptions.countPosition
      countTag = $('<a/>').attr(
        href: prop.commentUrl ? prop.shareUrl
        class: 'popn-socialbutton-count'
        target: '_blank'
      ).css countCSS

      wrapTag.append(shareTag.append(imgTag)).append countTag
      $(@).append wrapTag

      $.ajax
        url: prop.countUrl
        dataType: 'jsonp'
        success: (json) -> countTag.show().text prop.jsonpFunc(json)

    for sName in services
      _addLink sName, servicesProp[sName] if servicesProp[sName]?
    $(@).height iconSize + popnUp

    $(@).find('.popn-socialbutton-share').click () ->
      top = (screen.height / 2) - 180
      left = (screen.width / 2) - 240
      window.open @href, '', "width=520, height=400, top=#{top}, left=#{left}"
      false

    $(@).find('.popn-socialbutton-count')
      .mouseenter () ->
        $(@).css
          color: exOptions.countColor.textHover
          backgroundColor: exOptions.countColor.bgHover
      .mouseleave () ->
        $(@).css
          color: exOptions.countColor.text
          backgroundColor: exOptions.countColor.bg

    $(@).find('.popn-socialbutton-wrap')
      .mouseenter () ->
        $(@).css marginTop: 0
      .mouseleave () ->
        $(@).css marginTop: 4
