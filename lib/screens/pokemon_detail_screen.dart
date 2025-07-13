import 'package:flutter/material.dart';
import 'package:pokemon_encyclopedia/services/pokeapi_service.dart'; // PokeApiServiceをインポート

/// ポケモン詳細画面のStatefulWidget
class PokemonDetailScreen extends StatefulWidget {
  final String pokemonUrl;

  const PokemonDetailScreen({super.key, required this.pokemonUrl});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

/// ポケモン詳細画面のState
class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? _pokemonDetails;
  String _japaneseName = 'Loading...';
  bool _isLoading = true;

  // ヘルパー関数：16進数カラーコード文字列をColorオブジェクトに変換
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // ポケモンタイプ名と対応する色のマップ
  static final Map<String, Color> _typeColors = {
    'grass': Color(0xFF60BB5B), // GRASSのカラーコードを適用
    'fire': Color(0xFFEE7F31),
    'ice': Color(0xFF6EDCF9),
    'fighting': Color(0xFFD93B3E),
    'steel': Color(0xFF6D90AB),
    'rock': Color(0xFFBE9A40),
    'water': Color(0xFF4197D6),
    'ghost': Color(0xFF646EB9),
    'electric': Color(0xFFF3D53E),
    'dark': Color(0xFF4F4F4F),
    'poison': Color(0xFFA6579E),
    'flying': Color(0xFF9AC2F2),
    'psychic': Color(0xFFF96F89),
    'normal': Color(0xFF9A999A),
    'ground': Color(0xFFD8B763),
    'fairy': Color(0xFFF0A5EC),
    'dragon': Color(0xFF6D82BC),
    'bug': Color(0xFF9AB22C),
  };

  // ヘルパー関数：タイプ名に基づいて色を取得
  Color _getTypeColor(String typeName) {
    return _typeColors[typeName.toLowerCase()] ??
        Colors.grey; // 見つからない場合はグレーをデフォルトとする
  }

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetails(); // ポケモン詳細データをフェッチ
  }

  /// ポケモンの詳細データを取得する非同期メソッド
  Future<void> _fetchPokemonDetails() async {
    try {
      final details =
          await PokeApiService.fetchPokemonDetails(widget.pokemonUrl);
      setState(() {
        _pokemonDetails = details;
        _japaneseName = details['japanese_name'] ?? 'Loading...'; // 日本語名を設定
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching pokemon details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // 戻るボタンを追加
          icon: const Icon(Icons.arrow_back, color: Colors.white), // 色を白に固定
          onPressed: () => Navigator.pop(context),
        ),
        title: _isLoading
            ? Text('Loading...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
            : Text(_japaneseName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _pokemonDetails != null
            ? _getTypeColor((_pokemonDetails!['types'] as List)[0]['type']
                ['name']) // ポケモンの第一タイプの色を使用
            : Theme.of(context).brightness == Brightness.light
                ? Colors.grey[400] // ライトモードのロード中はグレー
                : Theme.of(context).primaryColor, // ダークモードのロード中はテーマのプライマリカラー
        elevation: 4.0, // 影をつける
        iconTheme: const IconThemeData(
          color: Colors.white, // 色を白に固定
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading || _pokemonDetails == null
          ? const Center(child: CircularProgressIndicator()) // ロード中はインジケーターを表示
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            20),
                    // ポケモンの公式アートワーク画像
                    Image.network(
                      _pokemonDetails!['sprites']['other']['official-artwork']
                          ['front_default'],
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // ポケモンの日本語名
                        Text(
                          _japaneseName,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10), // 名前と詳細の間のスペース
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ポケモンの高さ
                            Text(
                              '高さ: ${_pokemonDetails!['height'] / 10} m',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            // ポケモンの重さ
                            Text(
                              '重さ: ${_pokemonDetails!['weight'] / 10} kg',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ポケモンのタイプ表示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: (_pokemonDetails!['types'] as List)
                          .map<Widget>((typeInfo) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Chip(
                            label: Text(
                              typeInfo['type']['japanese_name'] ??
                                  typeInfo['type']['name'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: _getTypeColor(
                                typeInfo['type']['name']), // タイプに基づいて背景色を設定
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // 進化系統の表示
                    if (_pokemonDetails!['evolution_chain'] != null &&
                        (_pokemonDetails!['evolution_chain'] as List)
                            .isNotEmpty)
                      Column(
                        children: [
                          Text(
                            '進化',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120, // カードの高さに合わせて調整
                            child: Center( // ListViewを中央に配置
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true, // 内容に合わせてサイズを調整
                                physics: const ClampingScrollPhysics(), // スクロール時の挙動を調整
                                itemCount: (_pokemonDetails!['evolution_chain'] as List).length,
                                itemBuilder: (context, index) {
                                  final evoPokemon = (_pokemonDetails!['evolution_chain'] as List)[index];
                                  final evoPokemonId = evoPokemon['id'];
                                  final evoImageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$evoPokemonId.png';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Card(
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: SizedBox(
                                        width: 100, // カードの幅を調整
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Image.network(
                                                evoImageUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 30),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text(
                                                evoPokemon['japanese_name'],
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
