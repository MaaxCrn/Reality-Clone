import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../model/gaussian_model.dart';

part 'api_provider.g.dart';

final apiProvider = Api();

@RestApi()
abstract class Api {
  static Dio? _dio;

  factory Api() {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: "http://192.168.40.116:3000/",
        contentType: "application/json",
      ),
    );

    _dio!.interceptors.add(LogInterceptor(
      responseBody: true,
      requestHeader: true,
      requestBody: true,
    ));

    return _Api(_dio!);
  }

  static void updateBaseUrl(String baseUrl) {
    if (_dio != null) {
      _dio!.options.baseUrl = "$baseUrl/";
    }
  }

  @POST("image/compute-gaussian")
  @MultiPart()
  Future<HttpResponse> computeGaussian(
      @Part(name: "file") File zipFile,
      );


  @GET("image")
  Future<List<GaussianModel>> getGaussianList();

  @DELETE("image/delete/{id}")
  Future<HttpResponse> deleteGaussian(@Path("id") String id);

  @GET("/server/ping")
  Future<HttpResponse> ping();
}

