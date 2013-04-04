###!
* jQuery POP'n SocialButton v0.1.0
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
      text: $('title').text()
      imgDir: './img'
      buttonSpace: 12
      countPosition:
        top: 32
        right: -12
      countSize: 10
      countForeColor: '#ffffff'
      countBackColor: '#cc0000'
      countBorderColor: '#ffffff'
    , options
    exOptions.url = encodeURIComponent exOptions.url
    exOptions.text = encodeURIComponent exOptions.text

    servicesProp =
      twitter:
        img: 'twitter_2x.png'
        alt: 'Twitter Share Button'
        shareUrl: "http://twitter.com/share?url=#{exOptions.url}&text=#{exOptions.text}"
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
        countUrl: "http://api.b.st-hatena.com/entry.count?url=#{exOptions.url}"
        jsonpFunc: (json) -> json ? 0

    _addLink = (name, prop) =>
      linkTag = $('<a/>').attr(
        class: name
        href: prop.shareUrl
        target: '_blank'
      ).css
        float: 'left'
        display: 'block'
        position: 'relative'
        textDecration: 'none'
        width: 44
        height: 44
        marginTop: 4
        marginLeft: exOptions.buttonSpace
        marginRight: exOptions.buttonSpace

      imgTag = $('<img/>').attr(
        src: "#{exOptions.imgDir}/#{prop.img}"
        alt: prop.alt
      ).css
        border: 'none'

      countCSS = $.extend {},
        display: 'none'
        position: 'absolute'
        color: exOptions.countForeColor
        backgroundColor: exOptions.countBackColor
        border: "solid 2px #{exOptions.countBorderColor}"
        fontSize: exOptions.countSize
        fontWeight: 'bold'
        lineHeight: 1.5
        padding: '0 4px'
        borderRadius: 6
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.8)'
        zIndex: 1
      , exOptions.countPosition
      countTag = $('<small/>').css countCSS

      linkTag.append(imgTag).append(countTag)
      $(@).append linkTag

      $.ajax
        url: prop.countUrl
        dataType: 'jsonp'
        success: (json) -> countTag.show().text prop.jsonpFunc(json)

    for sName in services
      _addLink sName, servicesProp[sName] if servicesProp[sName]?
    clearTag = $('<div/>').css clear: 'both'
    $(@).append clearTag

    $(@).find('a').click () ->
      top = (screen.height / 2) - 180
      left = (screen.width / 2) - 240
      window.open @href, '', "width=520, height=400, top=#{top}, left=#{left}"
      false
    .mouseenter () ->
      $(@).css marginTop: 0
    .mouseleave () ->
      $(@).css marginTop: 4
