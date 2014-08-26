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

  START_ANGLE = Math.PI*1.5

  constructor: (@element, @packName) ->

    @animation = @element.querySelector('.portrait-animation')
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
    center = @circleCanvas.width/2
    @ctx.translate(center, center)
    @ctx.rotate(START_ANGLE)
    @ctx.translate(-center, -center)

    @imagesLoaded = 0
    @imagesTotal = 6
    @onImageLoadedProxy = @onImageLoaded.bind(@)
    @onImageErrorProxy = @onImageError.bind(@)
    @onImageProgressProxy = @onImageProgress.bind(@)
    @forceBlinkProxy = @forceBlink.bind(@)
    @tickProxy = @tick.bind(@)
    @onLoadTestTickProxy = @onLoadTestTick.bind(@)

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
    @onLoadStart()
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

    @animation.style.display = 'none'

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
    # firefox, you stupid. why I gotta rotate tiny bits?
    @torsoImage.style.webkitTransform = "rotate(0.0001deg) scale(#{x}, #{y})"
    @torsoImage.style.transform = "rotate(0.0001deg) scale(#{x}, #{y})"

    translation = "rotate(0.0001deg) translate(0px, #{breathProgress*-4.00}px)"

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


  onLoadStart: ->
    # some magic to drop the logo dead center
    @animation.style.display = 'none'
    @circleCanvas.style.display = null
    @circleLoader.style.backgroundColor = 'transparent'

  onLoadComplete: ->
    # @headImage.style.display = 'block'
    # @eyesOpenedImage.style.display = 'block'
    # @eyesClosedImage.style.display = 'none'
    # @mouthImage.style.display = 'block'
    # @torsoImage.style.display = 'block'
    # @hairImage.style.display = 'block'

    # set the background color
    @circleLoader.style.backgroundColor = 'rgba(252, 202, 43, 1.0)'
    @circleCanvas.style.display = 'none'
    @animation.style.display = null

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
    @ctx.arc(center, center, 170, 0, (@imagesLoaded/@imagesTotal)*(TAU))
    @ctx.closePath()
    @ctx.fillStyle = 'rgba(252, 202, 43, 1.0)'
    @ctx.fill()
    if @imagesLoaded == @imagesTotal
      @onLoadComplete()

  loadTest: ->
    # just a quick script for testing the load
    @circleLoader.style.backgroundColor = 'transparent'
    @imagesLoaded = 0
    @imagesTotal = 60
    @isLoadTest = true
    @ctx.clearRect(0, 0, @circleCanvas.width, @circleCanvas.height)
    requestAnimationFrame(@onLoadTestTickProxy)

  onLoadTestTick: ->
    if @imagesLoaded <= @imagesTotal
      @imagesLoaded++
      @onImageProgress()
      requestAnimationFrame(@onLoadTestTickProxy)
    else
      @isLoadTest = false

class rh.PortraitView
  constructor: (@element, @heroine) ->
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

    @onDownProxy = @onDown.bind(@)
    @onMoveProxy = @onMove.bind(@)
    @onEndProxy = @onEnd.bind(@)

    @lastTouch = null
    @startAxis = null
    @swipableWidth = 100
    @element.style.marginLeft = '0px'

    @element.addEventListener('touchstart', @onDownProxy)

  onDown: (e) ->
    @swipableWidth = (@element.clientWidth/2) / window.devicePixelRatio
    @lastTouch = null
    @originalEvent = e
    app.viewsContainer.addEventListener('touchmove', @onMoveProxy)
    app.viewsContainer.addEventListener('touchend', @onEndProxy)
    @element.style.webkitTransition = 'none'
    @element.style.mozTransition = 'none'
    @element.style.transition = 'none'

  onMove: (e) ->
    touches = e.changedTouches
    if (touches && touches.length > 0)
      touch = touches[0]
      lastTouchWasNull = @lastTouch == null
      @lastTouch = touch
      @checkForSwipe(true, lastTouchWasNull, e)

  onEnd: (e) ->
    @element.style.webkitTransition = null
    @element.style.mozTransition = null
    @element.style.transition = null
    app.viewsContainer.removeEventListener('touchmove', @onMoveProxy)
    app.viewsContainer.removeEventListener('touchend', @onEndProxy)
    @checkForSwipe(false, false, e)
    @element.style.marginLeft = '0px'

  #similar to quo
  checkForSwipe: (moving, firstMove, e) ->
    if @lastTouch
      delta = 
        x: (@originalEvent.touches[0].pageX - @lastTouch.pageX) / window.devicePixelRatio
        y: (@originalEvent.touches[0].pageY - @lastTouch.pageY) / window.devicePixelRatio
    else
      delta =
        x: 0
        y: 0

    if moving
      if firstMove then @startAxis = @getAxis(delta)
      if @startAxis isnt null
        @onSwiping(@startAxis, @lastTouch, delta)
    else
      # if Math.abs(delta.y) > @element.clientHeight/3
      #   if delta.y < 0
      #     @onSwipe(@startAxis, -1, @lastTouch)
      #   else
      #     @onSwipe(@startAxis, 1, @lastTouch)

      if Math.abs(delta.x) > @swipableWidth/2
        if delta.x < 0
          @onSwipe(@startAxis, -1, @lastTouch, delta)
        else
          @onSwipe(@startAxis, 1, @lastTouch, delta)
      else
        @element.style.marginLeft = '0px'

  getAxis: (delta) ->
    axis = null
    if Math.round(Math.abs(delta.x / delta.y)) >= 2 then axis = "x"
    else if Math.round(Math.abs(delta.y / delta.x)) >= 2 then axis = "y"
    return axis

  onSwiping: (axis, touch, delta) ->
    if axis == 'x'
      d = Math.abs(delta.x)
      if d < @swipableWidth
        # console.log(delta.x/@swipableWidth)
        # console.log(easypeasy.quarticOut(delta.x/@swipableWidth))
        # swipe = @swipableWidth * (easypeasy.quarticOut(delta.x/@swipableWidth))
        swipe = delta.x
        if swipe < (@swipableWidth*-1)
          swipe = (@swipableWidth*-1)
      else
        swipe = @swipableWidth * (if delta.x > 0 then 1 else -1)
      @element.style.marginLeft = (swipe*-1) + 'px'

  onSwipe: (axis, direction, touch, delta) ->
    if axis == 'x'
      if delta.x > 0
        app.nextButton.click()
      else if delta.x < 0
        app.previousButton.click()


class rh.MugsView
  CYCLES = 1

  constructor: (@element) ->
    #.mug-shots
    @facesContainer = @element.querySelector('.mugs')

    @imagesLoaded = 0
    @imagesTotal = 34
    @images = []
    @onImageLoadedProxy = @onImageLoaded.bind(@)

    @setupMugs()

    # even if they're not all loaded, kick this off.
    setTimeout(@onAllFacesLoaded.bind(@), 500)

  setupMugs: ->
    for c in [0..CYCLES]
      for i in [1..@imagesTotal+1]
        if i < 10
          imageName = '0'+i+'.jpg'
        else
          imageName = i+'.jpg'

        img = document.createElement('img')
        img.className = 'mug animated-out'
        img.addEventListener('load', @onImageLoadedProxy)
        transitionTime = i
        # img.style.webkitTransitionDelay = (0.15*transitionTime) + 's'
        # img.style.mozTransitionDelay = (0.15*transitionTime) + 's'
        # img.style.transitionDelay = (0.15*transitionTime) + 's'
        img.src = rh.STATIC_URL + 'img/about/' + imageName
        @images.push(img)

        @facesContainer.appendChild(img)
    

  onImageLoaded: (e) ->
    @imagesLoaded++
    if @imagesLoaded >= @imagesTotal
      @onAllFacesLoaded()

  onAllFacesLoaded: ->
    for c in [0..CYCLES]
      for i in [0..@imagesTotal]
        @images[i+(c*@imagesTotal)].classList.remove('animated-out')

    @facesContainer.parentNode.style.height = @images[0].clientHeight * 3 + 'px'

class rh.AboutView

  constructor: (@element) ->
    @mugs = new rh.MugsView(@element)
    @viewsContainer = document.getElementById('views')
    @whoContainer = @viewsContainer.querySelector('.who-made-this')
    @portraitContainers = @viewsContainer.querySelectorAll('.bio-block')
    @quoteOfTheMonth = @viewsContainer.querySelector('.quote-of-the-month')
    @quoteOfTheMonthContainer = @viewsContainer.querySelector('.quote-of-the-month .quote-container')

    worldIconSpriteSheetData = 
      images: [rh.STATIC_URL + 'img/animations/world-icon.png']
      framerate: 60
      frames: {width:218, height:52}
      animations: {load: [0,47,null]}
    # adobe's easel
    worldIconSpriteSheet = new createjs.SpriteSheet(worldIconSpriteSheetData)
    @worldIcon = new createjs.Sprite(worldIconSpriteSheet, 'load')
    @worldIcon.stop()
    worldIconCanvas = document.getElementById('world-icon')
    @worldIconStage = new createjs.Stage(worldIconCanvas)
    @worldIconStage.addChild(@worldIcon)

    @isActive = false
    @worldAnimated = false
    @whoAnimated = false
    @tickProxy = @tick.bind(@)
    @onResizeProxy = @onResize.bind(@)
    createjs.Ticker.addEventListener('tick', @worldIconStage)
    window.addEventListener('resize', @onResizeProxy)

    @onResize()

  centerQuote: ->
    header = @quoteOfTheMonth.querySelector('h3')
    quote = @quoteOfTheMonth.querySelector('.quote')
    attribution = @quoteOfTheMonth.querySelector('.attribution')
    headerCS = getComputedStyle(header)
    attributionCS = getComputedStyle(attribution)

    totalHeight = header.clientHeight + parseInt(headerCS.marginBottom) + quote.clientHeight + attribution.clientHeight + parseInt(attributionCS.marginTop)

    @quoteOfTheMonthContainer.style.height = totalHeight + 'px'


  listen: ->
    @worldAnimated = false
    @whoAnimated = false
    @isActive = true
    createjs.Ticker.addEventListener('tick', @tickProxy)

  stop: ->
    @isActive = false
    @worldAnimated = false
    @whoAnimated = false
    @worldIcon.gotoAndStop(0)
    createjs.Ticker.removeEventListener('tick', @tickProxy)

  onResize: (e) ->
    @mugs.facesContainer.parentNode.style.height = @mugs.images[0].clientHeight * 3 + 'px'
    if document.body.clientWidth < 767
      @whoContainer.classList.remove('animated-out')
      for portrait in @portraitContainers
        portrait.classList.remove('animated-out')
    else if document.documentElement.scrollTop >= document.body.clientHeight and @whoAnimated == false
      @whoContainer.classList.remove('animated-out')
      for portrait in @portraitContainers
        portrait.classList.remove('animated-out')

    @centerQuote()


  tick: (e) ->

    halfHeight = @mugs.facesContainer.clientHeight/2
    scrollTop = document.documentElement.scrollTop
    if scrollTop < halfHeight and (document.body.clientWidth > 960)
      @mugs.facesContainer.style.top = -(scrollTop * easypeasy.quarticOut(scrollTop/halfHeight)) + 'px'
      if scrollTop < (halfHeight/1.25)
        @quoteOfTheMonth.style.top = -(scrollTop * easypeasy.quarticOut(scrollTop/(halfHeight/1.25))) + 'px'


    if @worldAnimated == false and scrollTop > (@mugs.facesContainer.parentNode.clientHeight/2)
      @worldAnimated = true
      @worldIcon.gotoAndStop(0)
      @worldIcon.gotoAndPlay('load')
    else if scrollTop < (@mugs.facesContainer.parentNode.clientHeight/2)
      @worldIcon.gotoAndStop(0)
      @worldAnimated = false

    if document.body.clientWidth < 767
      return;

    if (scrollTop >= document.documentElement.scrollHeight - document.documentElement.clientHeight - 250)
      if @whoAnimated == false
        @whoAnimated = true
        @whoContainer.classList.remove('animated-out')
        for portrait in @portraitContainers
          portrait.classList.remove('animated-out')
    else
      if @whoAnimated
        @whoContainer.classList.add('animated-out')
        for portrait in @portraitContainers
          portrait.classList.add('animated-out')
      @whoAnimated = false


class rh.GridItem
  constructor: (@element) ->
    @portrait = @element.querySelector('.portrait')

    @portraitImage = @portrait.querySelector('.grid-portrait')
    # if it's an auto-generated one:
    try
      if @portraitImage.style.backgroundImage.indexOf("/composite") >= 0
        @portraitImage.style.top = '0px';
    catch error
      null


    ornamentSpriteSheetData = 
      images: [rh.STATIC_URL + 'img/animations/portrait-leaf.png']
      framerate: 120
      frames: {width:300, height:113}
      animations: {over: [0,88,null], out: {frames: [88..0], next: null}}
    # adobe's easel
    ornamentSpriteSheet = new createjs.SpriteSheet(ornamentSpriteSheetData)
    @ornament = new createjs.Sprite(ornamentSpriteSheet, 'over')
    @ornament.stop()
    @ornamentCanvas = @element.querySelector('canvas.grid-portrait-ornament')
    @ornamentStage = new createjs.Stage(@ornamentCanvas)
    @ornamentStage.addChild(@ornament)
    createjs.Ticker.addEventListener('tick', @ornamentStage)

    @onOverProxy = @onOver.bind(@)
    @onOutProxy = @onOut.bind(@)

    @element.addEventListener('mouseenter', @onOverProxy)
    @element.addEventListener('mouseleave', @onOutProxy)

  onOver: (e) ->
    @ornament.gotoAndStop(0)
    @ornament.gotoAndPlay('over')

  onOut: (e) ->
    @ornament.stop()
    @ornament.gotoAndPlay('out')
  
class rh.GridView
  constructor: (@element) ->
    gridItemElements = @element.querySelectorAll('a.heroine-card')
    @gridItems = []
    for e in gridItemElements
      gridItem = new rh.GridItem(e)
      @gridItems.push(gridItem)

    @onResizeProxy = @onResize.bind(@)
    @tickProxy = @tick.bind(@)

    # document.body.addEventListener('DOMContentLoaded', @onResizeProxy)
    # document.body.addEventListener('resize', @onResizeProxy)

    # @onResize()
    requestAnimationFrame(@tickProxy)


  onResize: (e) ->
    for item in @gridItems
      item.portrait.style.height = item.portrait.clientWidth + 'px'

  tick: (t) ->
    requestAnimationFrame(@tickProxy)
    for item in @gridItems
      item.portrait.style.height = item.portrait.clientWidth + 'px'
    

class rh.App
  constructor: (@element, @heroinesUrl) ->
    # all animations are 30fps
    createjs.Ticker.useRAF = true
    createjs.Ticker.setFPS(60)
    # proxy setups
    @onPortraitClickProxy = @onPortraitClick.bind(@)
    @onGridButtonClickProxy = @onGridButtonClick.bind(@)
    @onAnimationFrameProxy = @onAnimationFrame.bind(@)
    window.addEventListener('popstate', @onHistoryPopState.bind(@))

    @navContainer = document.querySelector('nav')
    @globalNav = @navContainer.parentNode
    @viewsContainer = document.querySelector('#views')
    @footer = document.querySelector('footer')

    # ui elements
    @gridViewElement = @element.querySelector('#grid-view')
    @portraitNav = document.querySelector('#portrait-navigation')
    @portraitView = @element.querySelector('.portrait-view')
    @previousPortraitView = null
    @aboutView = new rh.AboutView(@element.querySelector('#about-view')); 

    @veggieBurger = document.querySelector('.veggie-burger')

    # @aboutFooter = document.querySelector('footer')

    @logoLink = document.querySelector('a.link-home')
    @gridLink = document.querySelector('a.link-grid')
    @portraitLink = document.querySelector('a.link-portrait')
    @aboutLink = document.querySelector('a.link-about')
    @gridButton = document.querySelector('#grid-button')

    @nextButton = document.querySelector('#next-button')
    @previousButton = document.querySelector('#previous-button')

    @aboutLink.addEventListener('click', @onAboutClick.bind(@))
    @portraitLink.addEventListener('click', @onPortraitLinkClick.bind(@))
    @gridLink.addEventListener('click', @onGridButtonClickProxy)
    @logoLink.addEventListener('click', @onGridButtonClickProxy)
    @gridButton.addEventListener('click', @onGridButtonClickProxy)

    @nextButton.addEventListener('click', @onPortraitClickProxy)
    @previousButton.addEventListener('click', @onPortraitClickProxy)

    @veggieBurger.addEventListener('click', @onBurgerFlip.bind(@))

    @portraitCleanupTimerId = 0

    # load the heroines json synchronously.
    @loadJson()

    @captureGrid()
    @gridView = new rh.GridView(@gridViewElement)

    # initially delay the switch
    setTimeout(@init.bind(@), 150)

    requestAnimationFrame(@onAnimationFrameProxy)

    return

  init: ->
    # autoswitch to the appropriate section
    state = @getSectionFromUrl()
    @switchSection(state['section'], state, false)
    document.body.setAttribute('data-initial', '')

    window.addEventListener('resize', @onResize.bind(@))

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
    document.documentElement.scrollTop = 0;
    @limboFooter()
    switch section
      when 'portrait'
        @gridViewElement.classList.add('animated-out')
        @aboutView.element.classList.add('animated-out')
        @portraitNav.classList.remove('animated-out')
        @portraitView.classList.remove('animated-out')
        # @aboutFooter.style.bottom = null
        # @aboutFooter.classList.add('animated-out')
        heroine = @getHeroineBySlug(options.slug)
        previous = @getPreviousHeroineBySlug(options.slug)
        next = @getNextHeroineBySlug(options.slug)
        document.body.className = section
        document.title = 'Real Heroines - ' + heroine.name
        @loadPortrait(heroine, options['direction'])
        @updatePortaitNavButton(@previousButton, previous)
        @updatePortaitNavButton(@nextButton, next)
        @currentHeroine = heroine
        @aboutView.stop()
        @placeFooter(@portraitView)
        if pushState
          history.pushState({'section': 'portrait', 'slug': heroine.slug}, null, "/portrait/#{heroine.slug}/")
      when 'about'
        @aboutView.element.classList.remove('animated-out')
        # @aboutFooter.style.bottom = (document.body.clientHeight - 105 - 112) + 'px'
        # @aboutFooter.classList.remove('animated-out')        
        @gridViewElement.classList.add('animated-out')
        @portraitNav.classList.add('animated-out')
        @portraitView.classList.add('animated-out')
        document.body.className = section
        document.title = 'Real Heroines - About'
        @aboutView.listen()
        @placeFooter(@aboutView.element)
        if pushState
          history.pushState({'section': 'about'}, null, '/about/')
      when '', 'grid'
        @gridViewElement.classList.remove('animated-out')
        @aboutView.element.classList.add('animated-out')
        @portraitNav.classList.add('animated-out')
        @portraitView.classList.add('animated-out')
        # @aboutFooter.style.bottom = null
        # @aboutFooter.classList.add('animated-out')
        document.body.className = 'grid'
        document.title = 'Real Heroines - Grid View'
        @aboutView.stop()
        @placeFooter(@gridViewElement, @gridViewElement)
        if pushState
          history.pushState({'section': 'grid'}, null, '/')
    
    @pendingSection = section

    return

  # this hack brought to you by desperation and a late night
  limboFooter: ->
    try
      @footer.parentNode.removeChild(@footer)
    catch error
      null

  # 
  placeFooter: (inside, pinBasedOn=@viewsContainer) ->
    @limboFooter()
    inside.appendChild(@footer)
    
    if inside == @gridViewElement
      if pinBasedOn.clientHeight < (document.body.clientHeight - @globalNav.offsetHeight) and not document.body.classList.contains('about')
        @footer.classList.add('pinned-to-bottom')
      else
        @footer.classList.remove('pinned-to-bottom')
    else
      @footer.classList.remove('pinned-to-bottom')

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

  # Navigate to the last loaded portrait or the first one we know of.
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

  onAnimationFrame: (t) ->
    requestAnimationFrame(@onAnimationFrameProxy)
    if @lastScrollTop == document.documentElement.scrollTop
      return
    if document.documentElement.scrollTop > @gridLink.clientHeight + 20
      if not @navContainer.classList.contains('scrolled-down')
        @navContainer.classList.add('scrolled-down')
    else if @navContainer.classList.contains('scrolled-down')
      @navContainer.classList.remove('scrolled-down')
    @lastScrollTop = document.documentElement.scrollTop

  loadPortrait: (heroine, direction) ->
    @previousPortraitView = @portraitView
    clone = @previousPortraitView.cloneNode(true)
    @portraitView = clone
    @viewsContainer.insertBefore(@portraitView, @aboutView.element)
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
    if @currentHeroine
      heroine = @currentHeroine
    else
      heroine = @heroinesData[0]

    if heroine
      @switchSection('portrait', {'slug': heroine.slug, 'direction': null}, true)

    @globalNav.classList.remove('expanded')

  onGridButtonClick: (e) ->
    e.preventDefault()
    @switchSection('grid', {'slug': null}, true)

    @globalNav.classList.remove('expanded')

  onPortraitClick: (e) ->
    e.preventDefault()
    heroineName = e.currentTarget.getAttribute('data-id')
    if heroineName.length == 0
      return
    direction = e.currentTarget.getAttribute('data-direction')
    @switchSection('portrait', {'slug': heroineName, 'direction': direction}, true)

    @globalNav.classList.remove('expanded')

  onResize: (e) ->
    @aboutView.element.style.bottom = (window.clientHeight - 105) + 'px'
    # @placeFooter()

  onAboutClick: (e) ->
    e.preventDefault()
    if window.location.pathname.indexOf('/about/') == 0
      if @previousUrl
        state = @getSectionFromUrl(@previousUrl)
      else
        state = {'section': 'grid', 'slug': null} 
      @switchSection(state['section'], state, true)
    else
      @previousUrl = window.location.pathname
      @switchSection('about', {}, true)

    @globalNav.classList.remove('expanded')


  onHistoryPopState: (e) ->
    if (e.state && e.state['section'])
      @switchSection(e.state['section'], e.state, false)

  onBurgerFlip: (e) ->
    @globalNav.classList.toggle('expanded')
    

      


