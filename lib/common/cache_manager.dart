import 'package:app/tools.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class _FileService extends HttpFileService {
  final String name;

  _FileService(this.name);

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String> headers = const {}}) {
    xlog(url, name: name);

    return super.get(url, headers: headers);
  }
}

class ImgCacheManager extends CacheManager {
  static const _key = 'AppImgCache';

  ImgCacheManager._() : super(Config(_key, fileService: _FileService(_key)));

  static final obj = ImgCacheManager._();
}

class GiftCacheManager extends CacheManager {
  static const _key = 'AppGiftCache';

  GiftCacheManager._() : super(Config(_key, fileService: _FileService(_key)));

  static final obj = GiftCacheManager._();
}
