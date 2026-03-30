import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/pokemon_model.dart';
import '../models/pokemon_list_model.dart';

abstract class PokemonRemoteDataSource {
  Future<PokemonModel> getPokemon(String nameOrId);
  Future<PokemonListModel> getPokemonList({int limit = 20, int offset = 0});
}

class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  final Dio dio;

  PokemonRemoteDataSourceImpl({required this.dio});

  @override
  Future<PokemonModel> getPokemon(String nameOrId) async {
    try {
      final response = await dio.get('pokemon/${nameOrId.toLowerCase()}');
      return PokemonModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<PokemonListModel> getPokemonList({int limit = 20, int offset = 0}) async {
    try {
      final response = await dio.get('pokemon', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return PokemonListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
