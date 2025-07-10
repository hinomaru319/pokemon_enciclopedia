
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Encyclopedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PokemonListScreen(),
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Map<String, dynamic>> _pokemonList = [];
  List<Map<String, dynamic>> _filteredPokemonList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPokemonData();
    _searchController.addListener(_filterPokemon);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPokemonData() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body)['results'];
      List<Map<String, dynamic>> fetchedPokemon = [];

      for (var pokemon in results) {
        final pokemonId = _getPokemonId(pokemon['url']);
        final speciesResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$pokemonId/'));
        if (speciesResponse.statusCode == 200) {
          final speciesData = json.decode(speciesResponse.body);
          String japaneseName = pokemon['name']; // Default to English name
          for (var nameEntry in speciesData['names']) {
            if (nameEntry['language']['name'] == 'ja') {
              japaneseName = nameEntry['name'];
              break;
            }
          }
          fetchedPokemon.add({
            'name': pokemon['name'], // English name
            'japanese_name': japaneseName,
            'url': pokemon['url'],
            'id': pokemonId,
          });
        } else {
          // If species data fetching fails, still add the pokemon with English name
          fetchedPokemon.add({
            'name': pokemon['name'],
            'japanese_name': pokemon['name'], // Fallback to English
            'url': pokemon['url'],
            'id': pokemonId,
          });
        }
      }

      setState(() {
        _pokemonList = fetchedPokemon;
        _filteredPokemonList = _pokemonList;
        _isLoading = false;
      });
    } else {
      // Handle the error
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPokemon() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPokemonList = _pokemonList.where((pokemon) {
        return pokemon['name'].toLowerCase().contains(query) ||
               pokemon['japanese_name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  String _getPokemonId(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments[uri.pathSegments.length - 2];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'メニュー',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('このアプリについて'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('お気に入り'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: <Widget>[
                const SliverAppBar(
                  title: const Text('ポケモン図鑑', style: TextStyle(color: Colors.white)),
                  centerTitle: true,
                  floating: true,
                  pinned: false,
                  snap: false,
                  backgroundColor: Colors.blue,
                  elevation: 4.0,
                ),
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
                    ),
                  ),
                ),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonUrl;

  const PokemonDetailScreen({super.key, required this.pokemonUrl});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? _pokemonDetails;
  String _japaneseName = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetails();
  }

  Future<void> _fetchPokemonDetails() async {
    final response = await http.get(Uri.parse(widget.pokemonUrl));
    if (response.statusCode == 200) {
      final details = json.decode(response.body);
      final speciesResponse = await http.get(Uri.parse(details['species']['url']));
      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);
        for (var nameEntry in speciesData['names']) {
          if (nameEntry['language']['name'] == 'ja') {
            _japaneseName = nameEntry['name'];
            break;
          }
        }
      }

      // Fetch Japanese type names
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
            String japaneseTypeName = details['types'][i]['type']['name']; // fallback
            for (var nameEntry in typeData['names']) {
              // ja-Hrkt is for Katakana/Hiragana
              if (nameEntry['language']['name'] == 'ja-Hrkt') {
                japaneseTypeName = nameEntry['name'];
                break;
              }
            }
            details['types'][i]['type']['japanese_name'] = japaneseTypeName;
          }
        }
      }

      setState(() {
        _pokemonDetails = details;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? const Text('Loading...')
            : Text(_japaneseName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading || _pokemonDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 20),
                    Image.network(
                      _pokemonDetails!['sprites']['other']['official-artwork']['front_default'],
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _japaneseName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: (_pokemonDetails!['types'] as List).map<Widget>((typeInfo) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Chip(
                            label: Text(typeInfo['type']['japanese_name'] ?? typeInfo['type']['name']),
                            backgroundColor: Colors.amber,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('高さ: ${_pokemonDetails!['height'] / 10} m'),
                    const SizedBox(height: 10),
                    Text('重さ: ${_pokemonDetails!['weight'] / 10} kg'),
                  ],
                ),
              ),
            ),
    );
  }
}
