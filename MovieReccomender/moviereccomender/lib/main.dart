import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MovieRecommenderApp());
}

class MovieRecommenderApp extends StatelessWidget {
  const MovieRecommenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Recommender',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font as per instructions
      ),
      home: const MovieRecommenderScreen(),
    );
  }
}

class MovieRecommenderScreen extends StatefulWidget {
  const MovieRecommenderScreen({super.key});

  @override
  State<MovieRecommenderScreen> createState() => _MovieRecommenderScreenState();
}

class _MovieRecommenderScreenState extends State<MovieRecommenderScreen> {
  // IMPORTANT: Replace with your actual Render API URL
  // Example: const String _baseUrl = 'https://your-render-app-name.onrender.com';
  final String _baseUrl = 'https://moviereccomendation.onrender.com'; // <--- REPLACE THIS WITH YOUR DEPLOYED RENDER URL

  List<String> _genres = [];
  String? _selectedGenre;
  List<dynamic> _recommendations = [];
  bool _isLoadingGenres = false;
  bool _isLoadingRecommendations = false;
  String? _genreError;
  String? _recommendationError;

  @override
  void initState() {
    super.initState();
    _fetchGenres(); // Fetch genres automatically when the app starts
  }

  // Fetches unique genres from the Flask API
  Future<void> _fetchGenres() async {
    setState(() {
      _isLoadingGenres = true;
      _genreError = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/genres'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _genres = List<String>.from(data['genres']);
          _isLoadingGenres = false;
          if (_genres.isNotEmpty) {
            _selectedGenre = _genres[0]; // Select the first genre by default
          }
        });
      } else {
        setState(() {
          _genreError = 'Failed to load genres: ${response.statusCode}';
          _isLoadingGenres = false;
        });
        print('Failed to load genres: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _genreError = 'Error fetching genres: $e';
        _isLoadingGenres = false;
      });
      print('Error fetching genres: $e');
    }
  }

  // Fetches movie recommendations for the selected genre from the Flask API
  Future<void> _fetchRecommendations() async {
    if (_selectedGenre == null) {
      setState(() {
        _recommendationError = 'Please select a genre.';
      });
      return;
    }

    setState(() {
      _isLoadingRecommendations = true;
      _recommendationError = null;
      _recommendations = []; // Clear previous recommendations
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/recommend/genre?genre=$_selectedGenre'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recommendations = data;
          _isLoadingRecommendations = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _recommendationError = 'No recommendations found for "${_selectedGenre}".';
          _isLoadingRecommendations = false;
        });
      } else {
        setState(() {
          _recommendationError = 'Failed to load recommendations: ${response.statusCode}';
          _isLoadingRecommendations = false;
        });
        print('Failed to load recommendations: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _recommendationError = 'Error fetching recommendations: $e';
        _isLoadingRecommendations = false;
      });
      print('Error fetching recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Recommender App'),
        centerTitle: true,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section for fetching and displaying genres
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select a Genre:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _isLoadingGenres
                        ? const Center(child: CircularProgressIndicator())
                        : _genreError != null
                            ? Text(
                                _genreError!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              )
                            : _genres.isEmpty
                                ? const Text('No genres available. Check API URL or connection.')
                                : DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    value: _selectedGenre,
                                    hint: const Text('Choose a genre'),
                                    items: _genres.map((String genre) {
                                      return DropdownMenuItem<String>(
                                        value: genre,
                                        child: Text(genre),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedGenre = newValue;
                                        _recommendations = []; // Clear recommendations when genre changes
                                        _recommendationError = null;
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoadingRecommendations || _selectedGenre == null
                          ? null
                          : _fetchRecommendations,
                      icon: _isLoadingRecommendations
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.movie),
                      label: const Text('Get Recommendations'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blueGrey.shade700,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section for displaying recommendations
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommendations:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_recommendationError != null)
                        Text(
                          _recommendationError!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        )
                      else if (_recommendations.isEmpty && !_isLoadingRecommendations)
                        const Center(
                          child: Text('Select a genre and click "Get Recommendations".'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              final movie = _recommendations[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['title'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Genres: ${movie['org_genres'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

