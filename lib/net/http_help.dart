import 'dart:developer';
import 'dart:io';

import 'package:app/exception.dart';
import 'package:app/net/api_help.dart';
import 'package:app/tools.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

final dio = _init();

final bool isOpenProxy = false; //是否开通代理
final String proxyHost = '192.168.0.167'; //代理地址
//final String proxyHost = '192.168.0.119'; //代理地址
final String proxyPort = '8888'; //代理端口

Dio _init() {
  final dio = Dio(_baseOptions());

  dio.interceptors.addAll(
    [
      if (canLog('HTTP'))
        LogInterceptor(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseHeader: true,
          responseBody: true,
          logPrint: (it) => log('$it', name: 'HTTP'),
        ),
      //
      InterceptorsWrapper(
        onRequest: (options, handler) {
          ApiHelp.uidMixin(options.queryParameters);

          handler.next(options);
        },
      ),
      InterceptorsWrapper(onRequest: (options, handler) {
        final headers = options.headers;

        final now = '${DateTime.now().millisecondsSinceEpoch}';

        headers['t'] = now;
        headers['sn'] = ApiHelp.sign(options.queryParameters, now);

        handler.next(options);
      })
    ],
  );

  if (isOpenProxy) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => isOpenProxy;
      client.findProxy = (url) => isOpenProxy ? 'PROXY ${proxyHost + ':' + proxyPort}' : 'DIRECT';
    };
  }

  return dio;
}

BaseOptions _baseOptions() {
  final $5s = Duration(seconds: 25).inMilliseconds;
  return BaseOptions(
    method: 'POST',
    sendTimeout: $5s,
    receiveTimeout: $5s,
    connectTimeout: $5s,
    queryParameters: {
      'os': ApiHelp.os(),
      'imei': ApiHelp.imei(),
      'channelCode': channelCode,
      'appVersion': ApiHelp.version(),
    },
  );
}

Future request(String url, {data, Map<String, dynamic> query, String method, Options options}) async {
  try {
    Options _options;

    if (options == null) {
      _options = Options(method: method);
    } else {
      _options = options.copyWith(method: method);
    }

    final response = await dio.request(
      url,
      data: data,
      queryParameters: query,
      options: _options,
    );

    return response.data;
  } on DioError catch (e) {
    switch (e.type) {
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.connectTimeout:
        throw NetException('网络请求超时');
      case DioErrorType.response:
        final resp = e.response;
        final status = resp.statusCode;

        switch (status) {
          case 400:
            final data = resp.data;

            throw LogicException(data['code'], data['message']);
          case 500:
          case 502:
            break;
          default:
            xlog('未处理的网络请求状态【$status】', name: 'HTTP');
        }

        throw NetException('网络错误[$status]');
      case DioErrorType.other:
        throw NetException('网络错误');
      case DioErrorType.cancel:
        log('请求取消', error: e, name: 'HTTP');
        break;
    }
    if (canLog('HTTP')) log('网络错误', error: e, name: 'HTTP');
  }
}
