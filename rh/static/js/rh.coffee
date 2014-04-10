window.rh = window.rh || {}

TAU = Math.PI*2

class rh.HeroineFace
  MIN_BREATH_FRAMES = 150
  MAX_BREATH_FRAMES = 220
  MIN_REST_FRAMES = 45
  MAX_REST_FRAMES = 65
  MIN_BREATH_SCALEX = 0.010
  MAX_BREATH_SCALEX = 0.03
  MIN_BREATH_SCALEY = 0.010
  MAX_BREATH_SCALEY = 0.04
  # 100ms for blinks
  BLINK_DURATION = 300
  BLINK_FREQUENCY = 3800
  BLINK_FREQUENCY_VARIANCE = 5000
  BLINK_FORCE_LIMIT = 500

  constructor: (@element, @packName) ->
    # TODO: load pack from media

    @stillImage = @element.querySelector('.portrait-animation .portrait-still')
    # generate dom elements
    @headImage = @element.querySelector('.portrait-animation .portrait-head')
    @eyesOpenedImage = @element.querySelector('.portrait-animation .portrait-eyes-opened')
    @eyesClosedImage = @element.querySelector('.portrait-animation .portrait-eyes-closed')
    @mouthImage = @element.querySelector('.portrait-animation .portrait-mouth')
    @torsoImage = @element.querySelector('.portrait-animation .portrait-torso')
    @hairImage = @element.querySelector('.portrait-animation .portrait-hair')


    @torsoImage.style.webkitTransformOrigin = "50% 100%"
    @torsoImage.style.transformOrigin = "50% 100%"

    @circleLoader = @element.querySelector('.portrait-circle')
    @circleCanvas = @circleLoader.querySelector('canvas')
    @ctx = @circleCanvas.getContext('2d')
    @ctx.fillStyle = 'rgba(252, 202, 43, 1.0)'
    # @ctx.rotate(TAU/-4)

    @imagesLoaded = 0
    @imagesTotal = 6
    @onImageLoadedProxy = @onImageLoaded.bind(@)
    @onImageErrorProxy = @onImageError.bind(@)
    @onImageProgressProxy = @onImageProgress.bind(@)
    @forceBlinkProxy = @forceBlink.bind(@)
    @tickProxy = @tick.bind(@)

    @sizeTotals = {}

    @breathFrame = 0
    @breathOut = false
    @restFrame = 0
    @inRest = false
    @onResetBreath()
    @breathXScale = MIN_BREATH_SCALEX + (Math.random()*(MAX_BREATH_SCALEX - MIN_BREATH_SCALEX))
    @breathYScale = MIN_BREATH_SCALEY + (Math.random()*(MAX_BREATH_SCALEY - MIN_BREATH_SCALEY))

    @isBlinking = false
    @lastBlink = 0
    @nextBlink = BLINK_FREQUENCY + Math.floor(Math.random() * BLINK_FREQUENCY_VARIANCE)
    @blinkDuration = BLINK_DURATION + (Math.random() * (BLINK_DURATION/10))
    @currentTime = 0
    @lastForcedBlink = @currentTime

    @lastRequestId = 0

  load: ->
    # hide still
    @stillImage.style.display = 'none'
    @circleLoader.style.backgroundColor = 'rgba(252, 202, 43, 0.0)'
    @ctx.clearRect(0, 0, @circleCanvas.width, @circleCanvas.height)

    prefix = "#{rh.MEDIA_URL}packs/#{@packName}/"
    @headImage.addEventListener('load', @onImageLoadedProxy)
    @headImage.addEventListener('error', @onImageErrorProxy)
    @headImage.src = prefix + 'head.png'
    @eyesOpenedImage.addEventListener('load', @onImageLoadedProxy)
    @eyesOpenedImage.addEventListener('error', @onImageErrorProxy)
    @eyesOpenedImage.src = prefix + 'eyes-opened.png'
    @eyesClosedImage.addEventListener('load', @onImageLoadedProxy)
    @eyesClosedImage.addEventListener('error', @onImageErrorProxy)
    @eyesClosedImage.src = prefix + 'eyes-closed.png'
    @mouthImage.addEventListener('load', @onImageLoadedProxy)
    @mouthImage.addEventListener('error', @onImageErrorProxy)
    @mouthImage.src = prefix + 'mouth.png'
    @torsoImage.addEventListener('load', @onImageLoadedProxy)
    @torsoImage.addEventListener('error', @onImageErrorProxy)
    @torsoImage.src = prefix + 'torso.png'
    @hairImage.addEventListener('load', @onImageLoadedProxy)
    @hairImage.addEventListener('error', @onImageErrorProxy)
    @hairImage.src = prefix + 'hair.png'

    @eyesOpenedImage.addEventListener('mouseenter', @forceBlinkProxy)

  unload: ->
    @headImage.removeEventListener('load', @onImageLoadedProxy)
    @headImage.removeEventListener('error', @onImageErrorProxy)
    @eyesOpenedImage.removeEventListener('load', @onImageLoadedProxy)
    @eyesOpenedImage.removeEventListener('error', @onImageErrorProxy)
    @eyesClosedImage.removeEventListener('load', @onImageLoadedProxy)
    @eyesClosedImage.removeEventListener('error', @onImageErrorProxy)
    @mouthImage.removeEventListener('load', @onImageLoadedProxy)
    @mouthImage.removeEventListener('error', @onImageErrorProxy)
    @torsoImage.removeEventListener('load', @onImageLoadedProxy)
    @torsoImage.removeEventListener('error', @onImageErrorProxy)
    @hairImage.removeEventListener('load', @onImageLoadedProxy)
    @hairImage.removeEventListener('error', @onImageErrorProxy)
    @eyesOpenedImage.removeEventListener('mouseenter', @forceBlinkProxy)

    cancelAnimationFrame(@lastRequestId)


  forceBlink: ->
    if @currentTime - @lastForcedBlink < BLINK_FORCE_LIMIT then return
    @startBlink(@currentTime)
    @blinkDuration = 50
    @flutterState = true
    @lastForcedBlink = @currentTime

  tick: (t) ->
    @currentTime = t
    @lastRequestId = requestAnimationFrame(@tickProxy)

    # breathOutg
    if @breathFrame >= @breathDuration
      @onResetBreath()
    else
      if not @inRest
        @breathFrame++
      else
        @restFrame++
        if @restFrame > @restDuration
          @inRest = false

    p = @breathFrame/@breathDuration
    if not @breathOut then p = 1.0 - p
    breathProgress = easypeasy.sineInOut(p)
    x = 1.0 + (breathProgress * @breathXScale)
    y = 1.0 + (breathProgress * @breathYScale)
    @torsoImage.style.webkitTransform = "scale(#{x}, #{y})"
    @torsoImage.style.transform = "scale(#{x}, #{y})"

    translation = "translate(0px, #{breathProgress*-4.00}px)"

    @headImage.style.webkitTransform = translation
    @headImage.style.transform = translation

    @mouthImage.style.webkitTransform = translation
    @mouthImage.style.transform = translation
    @eyesOpenedImage.style.webkitTransform = translation
    @eyesOpenedImage.style.transform = translation
    @eyesClosedImage.style.webkitTransform = translation
    @eyesClosedImage.style.transform = translation

    @hairImage.style.webkitTransform = translation
    @hairImage.style.transform = translation

    if not @isBlinking and t >= @nextBlink
       @startBlink(t)
    else if @isBlinking and t - @lastBlink >= @blinkDuration
       @endBlink(t)

  startBlink: (tick) ->
    @eyesOpenedImage.style.display = 'none'
    @eyesClosedImage.style.display = 'block'

    @lastBlink = tick
    @isBlinking = true

  endBlink: (tick) ->
    @eyesOpenedImage.style.display = 'block'
    @eyesClosedImage.style.display = 'none'

    if not @flutterState
      @nextBlink = tick + BLINK_FREQUENCY + Math.floor(Math.random() * BLINK_FREQUENCY_VARIANCE)
      @blinkDuration = BLINK_DURATION + (Math.random() * (BLINK_DURATION/10))
    else
      @flutterState = !@flutterState
      @blinkDuration = 50
      @nextBlink = tick + 100
    @isBlinking = false

  onResetBreath: ->
    @breathFrame = 0
    @breathOut = !@breathOut
    @restFrame = 0
    @inRest = @breathOut
    @restDuration = MIN_REST_FRAMES + (Math.random()*(MAX_REST_FRAMES - MIN_REST_FRAMES))
    @breathDuration = MIN_BREATH_FRAMES + (Math.random()*(MAX_BREATH_FRAMES - MIN_BREATH_FRAMES))


  onLoadComplete: ->
    # @headImage.style.display = 'block'
    # @eyesOpenedImage.style.display = 'block'
    # @eyesClosedImage.style.display = 'none'
    # @mouthImage.style.display = 'block'
    # @torsoImage.style.display = 'block'
    # @hairImage.style.display = 'block'

    # set the background color
    @circleLoader.style.backgroundColor = 'rgba(252, 202, 43, 1.0)'

    # start animating
    requestAnimationFrame(@tickProxy)

  onImageError: (e) ->
    e.preventDefault()
    e.currentTarget.style.display = 'none'
    @imagesLoaded++
    @onImageProgress()

  onImageLoaded: (e) ->
    @imagesLoaded++
    if (e.currentTarget.src.indexOf('eyes-closed')) == -1
      e.currentTarget.style.display = 'block'
    @onImageProgress()

  onImageProgress: (e) ->
    center = @circleCanvas.width/2
    @ctx.beginPath()
    @ctx.moveTo(center, center)
    @ctx.lineTo(170*2, center)
    @ctx.arc(center, center, 170, 0, (@imagesLoaded/@imagesTotal)*TAU)
    @ctx.closePath()
    @ctx.fillStyle = 'rgba(252, 202, 43, 1.0)'
    @ctx.fill()
    if @imagesLoaded == @imagesTotal
      @onLoadComplete()


class rh.PortraitView
  constructor: (@element, @heroine) ->
    # juana-ines for debugging
    @containerElement = @element.querySelector('.portrait-image')
    @animationElement = @containerElement.querySelector('.portrait-animation')
    @animationElement.style.top = @heroine.topOffset + 'px'
    @currentFace = null
    @currentFace = new rh.HeroineFace(@containerElement, @heroine.slug)
    @currentFace.load()

    @nameElement = @element.querySelector('.portrait-details h1')
    @titleElement = @element.querySelector('.portrait-details .portrait-title')
    @birthElement = @element.querySelector('.portrait-details .portrait-data-item-birth .portrait-data-item-value')
    @deathElement = @element.querySelector('.portrait-details .portrait-data-item-death .portrait-data-item-value')
    @nationalityElement = @element.querySelector('.portrait-details .portrait-data-item-nationality .portrait-data-item-value')
    @copyElement = @element.querySelector('.portrait-details .portrait-copy-text')


    @nameElement.innerHTML = @heroine.name
    @titleElement.innerHTML = @heroine.title
    @birthElement.innerHTML = @heroine.birthdate
    @deathElement.innerHTML = @heroine.deathdate
    @nationalityElement.innerHTML = @heroine.country
    @copyElement.innerHTML = @heroine.descriptionHtml


class rh.App
  constructor: (@element, @heroinesUrl) ->
    # proxy setups
    @onPortraitClickProxy = @onPortraitClick.bind(@)
    @onGridButtonClickProxy = @onGridButtonClick.bind(@)
    window.addEventListener('popstate', @onHistoryPopState.bind(@))

    @viewsContainer = document.querySelector('#views')

    # ui elements
    @gridView = @element.querySelector('#grid-view')
    @portraitNav = @element.querySelector('#portrait-navigation')
    @portraitView = @element.querySelector('.portrait-view')
    @previousPortraitView = null
    @aboutView = @element.querySelector('#about-view')

    @aboutFooter = document.querySelector('footer')
    @aboutLink = document.querySelector('#about-link')

    @gridLink = document.querySelector('a.link-grid')
    @portraitLink = document.querySelector('a.link-portrait')
    @gridButton = document.querySelector('#grid-button')

    @nextButton = document.querySelector('#next-button')
    @previousButton = document.querySelector('#previous-button')

    @aboutLink.addEventListener('click', @onAboutClick.bind(@))
    @portraitLink.addEventListener('click', @onPortraitLinkClick.bind(@))
    @gridLink.addEventListener('click', @onGridButtonClickProxy)
    @gridButton.addEventListener('click', @onGridButtonClickProxy)

    @nextButton.addEventListener('click', @onPortraitClickProxy)
    @previousButton.addEventListener('click', @onPortraitClickProxy)

    @portraitCleanupTimerId = 0

    # load the heroines json synchronously.
    @loadJson()

    @captureGrid()

    # initially delay the switch
    setTimeout(@init.bind(@), 150);
    return

  init: ->
    # autoswitch to the appropriate section
    state = @getSectionFromUrl()
    @switchSection(state['section'], state, false)
    document.body.setAttribute('data-initial', '')

  loadJson: ->
    request = null
    if (window.XDomainRequest)
      request = new XDomainRequest()
    else
      request = new XMLHttpRequest()

    request.onload = ((e) ->
      @heroinesData = JSON.parse(request.responseText)
    ).bind(@)

    request.onerror = (e) ->
      console.log('Couldn\'t load heroines data. Falling back to traditional links.');

    request.open("get", @heroinesUrl, false)
    request.send()

  switchSection: (section, options={}, pushState=false) ->
    switch section
      when 'portrait'
        @gridView.classList.add('animated-out')
        @aboutView.classList.add('animated-out')
        @portraitNav.classList.remove('animated-out')
        @portraitView.classList.remove('animated-out')
        @aboutFooter.style.bottom = null
        @aboutFooter.classList.add('animated-out')
        heroine = @getHeroineBySlug(options.slug)
        previous = @getPreviousHeroineBySlug(options.slug)
        next = @getNextHeroineBySlug(options.slug)
        document.body.className = section
        document.title = 'Real Heroines - ' + heroine.name
        @loadPortrait(heroine, options['direction'])
        @updatePortaitNavButton(@previousButton, previous)
        @updatePortaitNavButton(@nextButton, next)
        @currentHeroine = heroine
        if pushState
          history.pushState({'section': 'portrait', 'slug': heroine.slug}, null, "/portrait/#{heroine.slug}/")
      when 'about'
        @aboutView.classList.remove('animated-out')
        # @aboutFooter.style.bottom = (document.body.clientHeight - 105 - 112) + 'px'
        @aboutFooter.classList.remove('animated-out')
        @gridView.classList.add('animated-out')
        @portraitNav.classList.add('animated-out')
        @portraitView.classList.add('animated-out')
        document.body.className = section
        document.title = 'Real Heroines - About'
        if pushState
          history.pushState({'section': 'about'}, null, '/about/')
      when '', 'grid'
        @gridView.classList.remove('animated-out')
        @aboutView.classList.add('animated-out')
        @portraitNav.classList.add('animated-out')
        @portraitView.classList.add('animated-out')
        @aboutFooter.style.bottom = null
        @aboutFooter.classList.add('animated-out')
        document.body.className = section
        document.title = 'Real Heroines - Grid View'
        if pushState
          history.pushState({'section': 'grid'}, null, '/')


    return

  getSectionFromUrl: (pathname=window.location.pathname)->
    parts = pathname.split('/')
    section = parts[1]
    if parts.length > 2
      slug = parts[2]
    else
      slug = null

    return {'section': section, 'slug': slug}

  getHeroineBySlug: (slug) ->
    heroine = null
    for heroineData in @heroinesData
      if heroineData['slug'] == slug
        heroine = heroineData
        break

    return heroine

  getPreviousHeroineBySlug: (slug) ->
    lastHeroine = null
    for heroineData in @heroinesData
      if heroineData['slug'] == slug
        break
      lastHeroine = heroineData

    return lastHeroine

  getNextHeroineBySlug: (slug) ->
    heroine = null
    stopAtNext = false
    for heroineData in @heroinesData
      if stopAtNext
        heroine = heroineData
        break
      if heroineData['slug'] == slug
        stopAtNext = true

    return heroine

  portraitHousekeeping: ->
    inactiveViews = document.querySelectorAll('.portrait-view.animated-out,.portrait-view.animated-out-left,.portrait-view.animated-unload-next,.portrait-view.animated-unload-previous')
    for inactiveView in inactiveViews
      if (inactiveView.portrait)
        # not sure if this matters, but I'm trying to force a gc
        inactiveView.potrait = null
      inactiveView.parentNode.removeChild(inactiveView)

  updatePortaitNavButton: (button, heroine) ->
    if not heroine
      button.style.opacity = 0.0
      button.setAttribute('data-id', '')
      return
    else
      button.style.opacity = 1.0

    button.setAttribute('data-id', heroine.slug)
    button.href = "/portrait/#{heroine.slug}/"
    button.querySelector('.button-title').innerHTML = heroine.name

  loadPortrait: (heroine, direction) ->
    @previousPortraitView = @portraitView
    clone = @previousPortraitView.cloneNode(true)
    @portraitView = clone
    @viewsContainer.insertBefore(@portraitView, @aboutView)
    @portraitView.classList.remove('animated-unload-next')
    @portraitView.classList.remove('animated-unload-previous')
    if direction == 'next'
      @portraitView.classList.add('animated-out')
      @previousPortraitView.classList.add('animated-unload-next')
    else
      @portraitView.classList.add('animated-out-left')
      @previousPortraitView.classList.add('animated-unload-previous')
    @currentPortrait = new rh.PortraitView(@portraitView, heroine)
    # force dom stuff
    document.body.clientWidth
    @portraitView.classList.remove('animated-out')
    @portraitView.classList.remove('animated-out-left')
    @portraitView.portrait = @currentPortrait

    @portraitCleanupTimerId = setTimeout(@portraitHousekeeping.bind(@), 1000)

  captureGrid: ->
    @portraitElements = document.querySelectorAll('#grid-view .heroine-card')

    for portrait in @portraitElements
      portrait.addEventListener('click', @onPortraitClickProxy)

  onPortraitLinkClick: (e) ->
    e.preventDefault()
    if @currentHeroine != null
      heroine = @currentHeroine
    else
      heroine = @heroinesData[0]
    
    @switchSection('portrait', {'slug': heroine.slug, 'direction': null}, true)

  onGridButtonClick: (e) ->
    e.preventDefault()
    @switchSection('grid', {'slug': null}, true)

  onPortraitClick: (e) ->
    e.preventDefault()
    heroineName = e.currentTarget.getAttribute('data-id')
    if heroineName.length == 0
      return
    direction = e.currentTarget.getAttribute('data-direction')
    @switchSection('portrait', {'slug': heroineName, 'direction': direction}, true)

  onResize: (e) ->
    @aboutView.style.bottom = (window.clientHeight - 105) + 'px'

  onAboutClick: (e) ->
    e.preventDefault()
    if window.location.pathname.indexOf('/about/') == 0
      if @previousUrl
        state = @getSectionFromUrl(@previousUrl)
      else
        state = {'section': 'grid', 'slug': null} 
      console.log(state)
      @switchSection(state['section'], state, true)
    else
      @previousUrl = window.location.pathname
      @switchSection('about', {}, true)

  onHistoryPopState: (e) ->
    if (e.state && e.state['section'])
      @switchSection(e.state['section'], e.state, false)

      


