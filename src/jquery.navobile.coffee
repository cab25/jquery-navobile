(($) ->
  $.navobile = (el, method) ->
    base = this
    base.$el = $(el)
    base.el = el
    base.$el.data "navobile", base

    base.attach = ->
      base.$el.data
          open: false

      base.$content.data
          swipe: false,
          drag: false

      base.bindClick base.$cta, base.$nav, base.$content
      base.bindDrag base.$nav, base.$content
      base.bindSwipe base.$nav, base.$content

    base.bindClick = ($cta, $nav, $content) ->
      $cta.click (e) ->
        if $nav.data('open')
          base.slideContentIn $nav, $content
          $nav.data 'open', false
        else
          base.slideContentOut $nav, $content
          $nav.data 'open', true
        e.preventDefault()

    base.bindSwipe = ($nav, $content) ->
      $nav.on 'swipe', (e) ->
        if e.direction is 'left'
          base.slideContentIn $nav, $content
          e.preventDefault()

      $content.on 'swipe', (e) ->
        if $content.data('drag')
          base.removeInlineStyles $nav, $content
          $content.data 'drag', false

        $content.data 'swipe', true

        if e.direction is 'right'
          base.slideContentOut $nav, $content
        else if e.direction is 'left'
          base.slideContentIn $nav, $content
        e.preventDefault();

    base.bindDrag = ($nav, $content) ->
      $content.on 'dragstart drag dragend release', (e) ->

        if e.type is 'release'
          base.removeInlineStyles $nav, $content

        if e.direction is 'left'
          if !$content.hasClass('navobile-content-hidden')
            return false
          else
            base.slideContentIn $nav, $content

        if e.direction is 'right'
          if e.type is 'dragend'
            if e.distance > 60
              base.slideContentOut $nav, $content
            else
              base.slideContentIn $nav, $content
            return false

          if e.type is 'dragstart'
            $content.data 'drag', true

          $nav.css 'opacity', 0
          posX = e.position.x
          translateX = Math.ceil base.calculateTranslate posX
          if translateX > 80 || translateX < 0
            return false

          $nav.css 'opacity', "#{base.draggedNavOpacity translateX}"
          if $('html').hasClass('csstransforms3d')
            $content.css 'transform', "translate3d(#{translateX}%, 0, 0)"
          else if $('html').hasClass('csstransforms')
            $content.css 'transform', "translateX(#{translateX}%)"

    base.animateLeft = (percent, $nav, $content) ->
      if !$('html').hasClass('csstransforms3d') and !$('html').hasClass('csstransforms')
        $content.animate
            left: percent
        , 200
        , 'linear'
      else
        if percent is '0%' then $content.removeClass 'navobile-content-hidden' else $content.addClass 'navobile-content-hidden'

      if percent is '0%' then $nav.removeClass 'navobile-navigation-visible' else $nav.addClass 'navobile-navigation-visible'

      base.removeInlineStyles $nav, $content

    base.slideContentIn = ($nav, $content) ->
      base.animateLeft '0%', $nav, $content

    base.slideContentOut = ($nav, $content) ->
      base.animateLeft '80%', $nav, $content

    base.calculateTranslate = (posX) ->
      (posX / $(document).width()) * 100

    base.removeInlineStyles = ($nav, $content) ->
      $content.css 'transform', ''
      $nav.css 'opacity', ''

    base.draggedNavOpacity = (translateX) ->
      if translateX > 40 then return 1 else return parseFloat translateX/40

    methods =
      init: (options) ->
        base.options = $.extend({}, $.navobile.defaultOptions, options)
        base.$cta = $(base.options.cta)
        base.$content = $(base.options.content)
        base.$nav = if base.options.changeDOM then base.$el.clone() else base.$el

        base.$content.addClass 'navobile-content'

        if base.options.changeDOM
          base.$el.addClass 'desktop-only'
          base.$nav.addClass 'mobile-only'
          base.$content.before base.$nav

        base.$nav.addClass 'navobile-navigation'

        base.attach()

      # method: ->
      #   do method

    if methods[method]
      return methods[method].apply this, Array::slice.call(argument, 1)
    else if typeof method is "object" or not method
      return methods.init method
    else
      return $.error "Method #{ method } does not exist on jQuery.navobile"

  $.navobile.defaultOptions =
    cta: '#show-navigation'
    content: '#content'
    easing: 'linear'
    changeDOM: false
    accordians: false
    accordianCta: false

  $.fn.navobile = (method) ->
    @each ->
      new $.navobile(this, method)

) jQuery