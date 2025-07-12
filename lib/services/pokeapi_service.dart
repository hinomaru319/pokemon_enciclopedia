import 'dart:convert';
import 'package:http/http.dart' as http;

class PokeApiService {
  /// PokeAPIからポケモンデータを取得する非同期メソッド
  static Future<List<Map<String, dynamic>>> fetchPokemonList() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body)['results'];
      List<Map<String, dynamic>> fetchedPokemon = [];

      for (var pokemon in results) {
        final pokemonId = _getPokemonId(pokemon['url']);
        final speciesResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$pokemonId/'));
        if (speciesResponse.statusCode == 200) {
          final speciesData = json.decode(speciesResponse.body);
          String japaneseName = pokemon['name']; // デフォルトは英語名
          // 日本語名を取得
          for (var nameEntry in speciesData['names']) {
            if (nameEntry['language']['name'] == 'ja') {
              japaneseName = nameEntry['name'];
              break;
            }
          }
          fetchedPokemon.add({
            'name': pokemon['name'], // 英語名
            'japanese_name': japaneseName,
            'url': pokemon['url'],
            'id': pokemonId,
          });
        } else {
          // 種族データの取得に失敗した場合でも、英語名でポケモンを追加
          fetchedPokemon.add({
            'name': pokemon['name'],
            'japanese_name': pokemon['name'], // 英語名にフォールバック
            'url': pokemon['url'],
            'id': pokemonId,
          });
        }
      }
      return fetchedPokemon;
    } else {
      throw Exception('Failed to load pokemon list');
    }
  }

  /// ポケモンのURLからIDを抽出
  static String _getPokemonId(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments[uri.pathSegments.length - 2];
  }

  /// ポケモンの詳細データを取得する非同期メソッド
  static Future<Map<String, dynamic>> fetchPokemonDetails(String pokemonUrl) async {
    final response = await http.get(Uri.parse(pokemonUrl));
    if (response.statusCode == 200) {
      final details = json.decode(response.body);
      final speciesResponse = await http.get(Uri.parse(details['species']['url']));
      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);
        // 日本語名を取得
        for (var nameEntry in speciesData['names']) {
          if (nameEntry['language']['name'] == 'ja') {
            details['japanese_name'] = nameEntry['name']; // 詳細データに日本語名を追加
            break;
          }
        }

        // 進化チェーンのURLを取得し、進化チェーンのデータをフェッチ
        if (speciesData['evolution_chain'] != null) {
          final evolutionChainUrl = speciesData['evolution_chain']['url'];
          final evolutionChainData = await fetchEvolutionChain(evolutionChainUrl);
          details['evolution_chain'] = await _extractEvolutionChain(evolutionChainData); // 進化チェーンの日本語名とIDを追加
        }
      }

      // 日本語タイプ名を取得
      if (details['types'] != null) {
        List<Future> typeFutures = [];
        for (var typeInfo in (details['types'] as List)) {
          typeFutures.add(http.get(Uri.parse(typeInfo['type']['url'])));
        }
        final typeResponses = await Future.wait(typeFutures);

        for (int i = 0; i < typeResponses.length; i++) {
          final typeResponse = typeResponses[i];
          if (typeResponse.statusCode == 200) {
            final typeData = json.decode(typeResponse.body);
            String japaneseTypeName = details['types'][i]['type']['name']; // フォールバック
            for (var nameEntry in typeData['names']) {
              // ja-Hrktはカタカナ/ひらがな用
              if (nameEntry['language']['name'] == 'ja-Hrkt') {
                japaneseTypeName = nameEntry['name'];
                break;
              }
            }
            details['types'][i]['type']['japanese_name'] = japaneseTypeName;
          }
        }
      }
      return details;
    } else {
      throw Exception('Failed to load pokemon details');
    }
  }

  /// 進化チェーンのデータを取得する非同期メソッド
  static Future<Map<String, dynamic>> fetchEvolutionChain(String evolutionChainUrl) async {
    final response = await http.get(Uri.parse(evolutionChainUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load evolution chain');
    }
  }

  /// 進化チェーンからポケモンの日本語名とIDを抽出するヘルパーメソッド
  static Future<List<Map<String, dynamic>>> _extractEvolutionChain(Map<String, dynamic> chain) async {
    List<Map<String, dynamic>> evolutionList = [];
    Map<String, dynamic>? currentChain = chain['chain'];

    while (currentChain != null) {
      final speciesUrl = currentChain['species']['url'];
      final pokemonId = _getPokemonId(speciesUrl);
      final speciesResponse = await http.get(Uri.parse(speciesUrl));
      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);
        String japaneseName = speciesData['name'];
        for (var nameEntry in speciesData['names']) {
          if (nameEntry['language']['name'] == 'ja') {
            japaneseName = nameEntry['name'];
            break;
          }
        }
        evolutionList.add({
          'id': pokemonId,
          'japanese_name': japaneseName,
        });
      }

      if (currentChain['evolves_to'] != null && currentChain['evolves_to'].isNotEmpty) {
        currentChain = currentChain['evolves_to'][0]; // 最初の進化形のみを追跡
      } else {
        currentChain = null;
      }
    }
    return evolutionList;
  }
}
