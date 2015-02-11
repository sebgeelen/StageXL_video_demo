part of videoTest;   

class VideoDemo extends DisplayObjectContainer {
  List      _allVideos        = new List<Video>();
  bool      _animationStarted = false;
  VideoData _videoData        = _resourceManager.getVideoData("video");
  Sprite3D  _sprite3D         = new Sprite3D();    

  InputElement autoplayInput  = html.querySelector('#autoplay');
  InputElement loopInput      = html.querySelector('#loop');
  InputElement fpsInput       = html.querySelector('#fps')
  InputElement alphaInput     = html.querySelector('#opacity');
  SelectElement filtersSelect = html.querySelector('#filters');

  VideoDemo() {
    // sprite 3d setup
    _sprite3D.pivotX = _canvas.width / 2 ;
    _sprite3D.pivotY = _canvas.height / 2;
    _sprite3D.perspectiveProjection = new PerspectiveProjection.fromDepth(10000, 10);
    _sprite3D.x = _canvas.width / 2;
    _sprite3D.y = _canvas.height / 2;
    //_sprite3D.scaleX = 0.5;
    //_sprite3D.scaleY = 0.5;
    _stage.addChild(_sprite3D);


    // add html-button event listeners
    html.querySelector('#addVideo').onClick.listen((e) => newVideo());

    html.querySelector('#toggleMute').onClick.listen((e) => toggleMuteVideo());
    html.querySelector('#play').onClick.listen((e) => playVideo());
    html.querySelector('#pause').onClick.listen((e) => pauseVideo());

    html.querySelector('#animate').onClick.listen((e) => animate());
    html.querySelector('#animate3d').onClick.listen((e) => animate3d());

    html.querySelector('#clear').onClick.listen((e) => clear());

    // add event listener for EnterFrame (fps meter)
    this.onEnterFrame.listen(_onEnterFrame);  
  }

  //---------------------------------------------------------------------------------

  num _fpsAverage = null;

  _onEnterFrame(EnterFrameEvent e) {

    if (_fpsAverage == null) {
      _fpsAverage = 1.00 / e.passedTime;
    } else {
      _fpsAverage = 0.05 / e.passedTime + 0.95 * _fpsAverage;
    }

    html.querySelector('#fpsMeter').innerHtml = "${_fpsAverage.round()}";
  }

  //---------------------------------------------------------------------------------
   
  void playVideo()
  {
    _allVideos.forEach((video) {
      video.play();
    });
  }
  void pauseVideo()
  {
    _allVideos.forEach((video) {
      video.pause();
    });
  }  

  void toggleMuteVideo()
  {
    _allVideos.forEach((video) {
      video.muted = !video.muted;
    });
  }

  void animate()
  {
    _allVideos.forEach((video) {
      if(_animationStarted) {
        _stage.juggler.removeTweens(video);
      } else {
        _stage.juggler.tween(video, 600, TransitionFunction.linear)
          ..animate.rotation.to(PI * 60.0);
      }
    });
    _animationStarted = !_animationStarted;
  }

  void animate3d()
  {
    _stage.juggler.transition(0.0, PI * 6, 100.0, TransitionFunction.linear, (value) {
      _sprite3D.rotationX = value * 0.4;
      _sprite3D.rotationY = value * 0.7;
      _sprite3D.rotationZ = value * 1.2;
      _sprite3D.offsetX = -50 * sin(value * 2);
      _sprite3D.offsetY = -50 * sin(value * 3);
      _sprite3D.offsetZ = -50 * sin(value * 4);
    });
  }

  void clear()
  {
    _allVideos.forEach((video) {
      video.pause();
    });

    _allVideos = new List<Video>();
    _sprite3D.removeChildren();
  }

  //---------------------------------------------------------------------------------

  void newVideo()
  {
    var autoplay    = autoplayInput.checked;
    var loop        = loopInput.checked;
    var frameRate   = int.parse(fpsInput.value);

    var video       = new Video(_videoData, autoplay: autoplay, loop: loop, frameRate: frameRate);

    var videoPerCol = (_canvas.width / video.width).ceil();
    var currentCell = _allVideos.length % videoPerCol;
    var videoPerRow = (_canvas.height / video.height).ceil();
    var currentRow  = (_allVideos.length / videoPerCol).floor() % videoPerRow;

    var x           = currentCell * video.width.toInt();
    var y           = currentRow * video.height.toInt();
    video.x         = x + video.width / 2;
    video.y         = y + video.height / 2;
    video.pivotX    = video.width / 2;
    video.pivotY    = video.height / 2;

    video.alpha     = num.parse(alphaInput.value);

    var filter      = _filters[filtersSelect.value];
    video.filters   = filter;
    if (!_webGL && filter.length > 0) {
      video.applyCache(0, 0, video.width, video.height);
    }

    _allVideos.add(video);
    _sprite3D.addChild(video);
  }
}
