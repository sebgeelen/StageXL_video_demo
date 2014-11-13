library videoTest;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

import 'dart:html';
import 'dart:math';

part 'video_demo.dart';

//vars
bool            _webGL            = true;
var             _canvas           = html.querySelector('#stage');
Stage           _stage            = new Stage(_canvas, webGL: _webGL);
RenderLoop      _renderLoop       = new RenderLoop();
ResourceManager _resourceManager  = new ResourceManager();

var _filters = {
  'none': [],
  'grayscale': [new ColorMatrixFilter.grayscale()],
  'chromaKey': [new ChromaKeyFilter(0xFFA2CFFC, 25)],
  'invert': [new ColorMatrixFilter.invert()],
  'blur': [new BlurFilter(5, 5)]
};

// start
void main()
{
  _renderLoop.addStage(_stage);

  _resourceManager
    ..addBitmapData('bg', 'bg.jpg')
    ..addVideoData('video', 'video/mov.mp4');

  _resourceManager.load()
    .then((_) {

      var bitmapData = _resourceManager.getBitmapData('bg');
      _stage.addChild(new Bitmap(bitmapData));

      _stage.addChild(new VideoDemo());
    })
    .catchError((e) => print(e));
}
