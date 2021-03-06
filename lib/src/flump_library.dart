part of stagexl_flump;

class FlumpLibrary {

  final List<_FlumpMovieData> _movieDatas = new List<_FlumpMovieData>();
  final List<_FlumpTextureGroup> _textureGroups = new List<_FlumpTextureGroup>();

  String _url;
  String _md5;
  int _frameRate;

  static Future<FlumpLibrary> load(String url)  async {

    var jsonString = await HttpRequest.getString(url);
    var jsonFlump = json.decode(jsonString);
    var textureGroupLoaders = new List<Future<_FlumpTextureGroup>>();
    var flumpLibrary = new FlumpLibrary();

    flumpLibrary._url = _ensureString(url);
    flumpLibrary._md5 = _ensureString(jsonFlump["md5"]);
    flumpLibrary._frameRate = _ensureInt(jsonFlump["frameRate"]);

    for(var jsonMovie in jsonFlump["movies"] as List) {
      var flumpMovieData = new _FlumpMovieData(flumpLibrary, jsonMovie);
      flumpLibrary._movieDatas.add(flumpMovieData);
    }

    for(var jsonTextureGroup in jsonFlump["textureGroups"] as List) {
      var future = _FlumpTextureGroup.load(flumpLibrary, jsonTextureGroup);
      textureGroupLoaders.add(future);
    }

    List<_FlumpTextureGroup> textureGroups = await Future.wait(textureGroupLoaders);
    flumpLibrary._textureGroups.addAll(textureGroups);
    return flumpLibrary;
  }

  //---------------------------------------------------------------------------

  String get url => _url;
  String get md5 => _md5;
  int get frameRate => _frameRate;

  //---------------------------------------------------------------------------

  _FlumpMovieData _getFlumpMovieData(String name) {

    for(int i = 0; i < _movieDatas.length; i++) {
      var movieData = _movieDatas[i];
      if (movieData.id == name) return movieData;
    }

    throw new ArgumentError("The movie '$name' is not available.");
  }

  BitmapDrawable _createSymbol(String name) {

    for(int i = 0; i < _textureGroups.length; i++) {
      var flumpTextures = _textureGroups[i].flumpTextures;
      if (flumpTextures.containsKey(name)) return flumpTextures[name];
    }

    for(int i = 0; i < _movieDatas.length; i++) {
      var movieData = _movieDatas[i];
      if (movieData.id == name) return new FlumpMovie(this, name);
    }

    throw new ArgumentError("The symbol '$name' is not available.");
  }
}
