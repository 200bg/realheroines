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

  load: ->
    # hide still
    @stillImage.style.display = 'none'
    @circleLoader.style.backgroundColor = 'rgba(252, 202, 43, 0.0)'
    @ctx.clearRect(0, 0, @circleCanvas.width, @circleCanvas.height)

    prefix = "#{rh.MEDIA_URL}heroines/packs/#{@packName}/"
    @headImage.src = prefix + 'head.png'
    @headImage.addEventListener('load', @onImageLoadedProxy)
    @eyesOpenedImage.src = prefix + 'eyes-opened.png'
    @eyesOpenedImage.addEventListener('load', @onImageLoadedProxy)
    @eyesClosedImage.src = prefix + 'eyes-closed.png'
    @eyesClosedImage.addEventListener('load', @onImageLoadedProxy)
    @mouthImage.src = prefix + 'mouth.png'
    @mouthImage.addEventListener('load', @onImageLoadedProxy)
    @torsoImage.src = prefix + 'torso.png'
    @torsoImage.addEventListener('load', @onImageLoadedProxy)
    @hairImage.src = prefix + 'hair.png'
    @hairImage.addEventListener('load', @onImageLoadedProxy)

    @eyesOpenedImage.addEventListener('mouseenter', @forceBlinkProxy)

  forceBlink: ->
    if @currentTime - @lastForcedBlink < BLINK_FORCE_LIMIT then return
    @startBlink(@currentTime)
    @blinkDuration = 50
    @flutterState = true
    @lastForcedBlink = @currentTime

  tick: (t) ->
    @currentTime = t
    requestAnimationFrame(@tickProxy)

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

    @headImage.style.webkitTransform = "translate(0px, #{breathProgress*-4.00}px)"
    @headImage.style.transform = "translate(0px, #{breathProgress*-4.00}px)"

    @mouthImage.style.webkitTransform = "translate(0px, #{breathProgress*-4.00}px)"
    @mouthImage.style.transform = "translate(0px, #{breathProgress*-4.00}px)"
    @eyesOpenedImage.style.webkitTransform = "translate(0px, #{breathProgress*-4.00}px)"
    @eyesOpenedImage.style.transform = "translate(0px, -#{breathProgress*-4.00}px)"
    @eyesClosedImage.style.webkitTransform = "translate(0px, #{breathProgress*-4.00}px)"
    @eyesClosedImage.style.transform = "translate(0px, #{breathProgress*-4.00}px)"

    @hairImage.style.webkitTransform = "translate(0px, #{breathProgress*-4.00}px)"
    @hairImage.style.transform = "translate(0px, #{breathProgress*-4.00}px)"

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
    @headImage.style.display = 'block'
    @eyesOpenedImage.style.display = 'block'
    @eyesClosedImage.style.display = 'none'
    @mouthImage.style.display = 'block'
    @torsoImage.style.display = 'block'
    @hairImage.style.display = 'block'

    # start animating
    requestAnimationFrame(@tickProxy)


  onImageLoaded: (e) ->
    @imagesLoaded++

    @ctx.beginPath()
    @ctx.arc(@circleCanvas.width/2, @circleCanvas.height/2, 170, 0, (@imagesLoaded/@imagesTotal)*TAU)
    @ctx.closePath()
    @ctx.fill()

    if @imagesLoaded == @imagesTotal
      @onLoadComplete()

  onImageProgress: (e) ->
    return
    # console.log e.lengthComputable


class rh.App
  constructor: (@element) ->
    return

  loadPortrait: ->
    # juana-ines for debugging
    @currentFace = new rh.HeroineFace(document.querySelector('#portrait-view .portrait-image'), 'juana-ines')
    @currentFace.load()
