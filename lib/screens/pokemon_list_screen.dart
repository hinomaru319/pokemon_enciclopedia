import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fontsをインポート
import 'package:pokemon_encyclopedia/screens/pokemon_detail_screen.dart'; // 詳細画面をインポート
import 'package:pokemon_encyclopedia/services/pokeapi_service.dart'; // PokeApiServiceをインポート

/// ポケモン一覧画面のStatefulWidget
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

/// ポケモン一覧画面のState
class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Map<String, dynamic>> _pokemonList = [];
  List<Map<String, dynamic>> _filteredPokemonList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPokemonData(); // ポケモンデータをフェッチ
    _searchController.addListener(_filterPokemon); // 検索バーのリスナーを設定
  }

  @override
  void dispose() {
    _searchController.dispose(); // コントローラーを破棄
    super.dispose();
  }

  /// PokeAPIからポケモンデータを取得する非同期メソッド
  Future<void> _fetchPokemonData() async {
    try {
      final fetchedPokemon = await PokeApiService.fetchPokemonList();
      setState(() {
        _pokemonList = fetchedPokemon;
        _filteredPokemonList = _pokemonList;
        _isLoading = false;
      });
    } catch (e) {
      // エラーハンドリング
      setState(() {
        _isLoading = false;
      });
      // エラー表示など
      print('Error fetching pokemon list: $e');
    }
  }

  /// 検索クエリに基づいてポケモンリストをフィルタリング
  void _filterPokemon() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPokemonList = _pokemonList.where((pokemon) {
        return pokemon['name'].toLowerCase().contains(query) ||
               pokemon['japanese_name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // ドロワーヘッダー
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0F52BA) // テーマのプライマリカラーを使用
              ),
              child: Text(
                'メニュー',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: GoogleFonts.notoSansJp().fontFamily, // フォント設定
                ),
              ),
            ),
            // 設定タイル
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('設定', style: TextStyle(fontFamily: GoogleFonts.notoSansJp().fontFamily)), // フォント設定
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // このアプリについてタイル
            ListTile(
              leading: const Icon(Icons.info),
              title: Text('このアプリについて', style: TextStyle(fontFamily: GoogleFonts.notoSansJp().fontFamily)), // フォント設定
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // お気に入りタイル
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text('お気に入り', style: TextStyle(fontFamily: GoogleFonts.notoSansJp().fontFamily)), // フォント設定
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はインジケーターを表示
          : CustomScrollView(
              slivers: <Widget>[
                // アプリバー
                SliverAppBar(
                  title: Text('ポケモン図鑑', style: TextStyle(color: Colors.white, fontFamily: GoogleFonts.notoSansJp().fontFamily)), // フォント設定
                  centerTitle: true,
                  floating: true,
                  pinned: false,
                  snap: false,
                  backgroundColor: const Color(0xFF0F52BA),
                  elevation: 4.0,
                ),
                // 検索バー
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'ポケモンを検索',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      style: TextStyle(fontFamily: GoogleFonts.notoSansJp().fontFamily), // フォント設定
                    ),
                  ),
                ),
                // ポケモン一覧グリッド
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid.builder(
                    itemCount: _filteredPokemonList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final pokemon = _filteredPokemonList[index];
                      final pokemonId = pokemon['id'];
                      final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

                      return GestureDetector(
                        onTap: () {
                          // 詳細画面へ遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailScreen(pokemonUrl: pokemon['url']),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  pokemon['japanese_name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.notoSansJp().fontFamily, // フォント設定
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}