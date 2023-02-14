// const host = ApiHost('http', '10.0.0.4', 8001);
//  const host = ApiHost('http', 'api.shengna.tv', 80);
//  const host = ApiHost('https', 'api.wanjiachufang.com', 443);
const host = ApiHost('http', 'xyywapp.com', 80);
// const host = ApiHost('http', 'admin.mmyyapp.com', 80);

class ApiHost {
  final String scheme;
  final String host;
  final int port;

  const ApiHost(this.scheme, this.host, this.port);

  // 默认服务器资源
  Uri $default(String path, [Map<String, String> query]) {
    return Uri.http(host.replaceFirst('api.', ''), path, query);
  }

  Uri $new(String path, [Map<String, String> query]) {
    return Uri(scheme: scheme, host: host, port: port, path: path, queryParameters: query);
  }
}
