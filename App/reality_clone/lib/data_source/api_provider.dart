import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_provider.g.dart';

final apiProvider = Api();

@RestApi()
abstract class Api {
  factory Api() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.224.116:3000/",
        contentType: "application/json"
      ),
    );
    dio.interceptors.add(LogInterceptor(responseBody: true,
        requestHeader: true, requestBody: true));
    return _Api(dio);
  }


  @POST("image/compute-gaussian")
  @MultiPart()
  Future<HttpResponse> computeGaussian(
      @Part(name: "file") File zipFile
      );


  @GET("/image/ping")
  Future<HttpResponse> ping();
}