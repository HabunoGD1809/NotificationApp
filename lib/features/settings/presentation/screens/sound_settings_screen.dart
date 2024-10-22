import 'package:flutter/material.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundSettingsScreen extends StatefulWidget {
  final String userId;

  const SoundSettingsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  String _currentSound = 'default';
  bool _isLoading = true;
  bool _isPlaying = false;
  String? _currentlyPlayingUri;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Mapa plano para búsqueda rápida de sonidos
  final Map<String, String> _soundPaths = {
    'mario1up': 'assets/sounds/notification_sounds/Mario1up.mp3',
    'pokemon': 'assets/sounds/notification_sounds/Pokemon.mp3',
    'level_up': 'assets/sounds/notification_sounds/Level up.mp3',
    'sonic_ring': 'assets/sounds/notification_sounds/Sonic Ring.mp3',
    'zelda_secret': 'assets/sounds/notification_sounds/Zelda secret.mp3',
    'star_wars_intro': 'assets/sounds/notification_sounds/Star Wars intro.mp3',
    'indiana_jones': 'assets/sounds/notification_sounds/Indiana Jones.mp3',
    'x_files': 'assets/sounds/notification_sounds/X files.mp3',
    'mission_imposible': 'assets/sounds/notification_sounds/Mission Imposible.mp3',
    'this_is_sparta': 'assets/sounds/notification_sounds/This is sparta.mp3',
    'surprise_motherfucker': 'assets/sounds/notification_sounds/Surprise Motherfucker.mp3',
    'thug_life_1': 'assets/sounds/notification_sounds/Thug Life 1.mp3',
    'wilhelm_scream': 'assets/sounds/notification_sounds/Wilhelm Scream.mp3',
    'nokia3310': 'assets/sounds/notification_sounds/Nokia3310.mp3',
    'iphone_6_remix': 'assets/sounds/notification_sounds/iPhone 6 Remix.mp3',
    'android_remix': 'assets/sounds/notification_sounds/Android Remix.mp3',
    'dramatic': 'assets/sounds/notification_sounds/Dramatic.mp3',
    'wtf_boom': 'assets/sounds/notification_sounds/WTF boom.mp3',
    'badumtss': 'assets/sounds/notification_sounds/Badumtss.mp3',
  };

  // Categorías completas con todos los sonidos
  final List<Map<String, dynamic>> _soundCategories = [
    {
      'category': '🎮 Videojuegos',
      'icon': Icons.sports_esports,
      'sounds': [
        {
          'title': 'Super Mario 1UP',
          'uri': 'mario1up',
          'description': 'El clásico sonido de vida extra'
        },
        {
          'title': 'Pokémon',
          'uri': 'pokemon',
          'description': 'Música de la serie Pokémon'
        },
        {
          'title': 'Level Up',
          'uri': 'level_up',
          'description': 'Sonido de subida de nivel'
        },
        {
          'title': 'Sonic Ring',
          'uri': 'sonic_ring',
          'description': 'Sonido de anillo de Sonic'
        },
        {
          'title': 'Zelda Secret',
          'uri': 'zelda_secret',
          'description': 'Descubrimiento de secreto en Zelda'
        }
      ]
    },
    {
      'category': '🎬 Películas y Series',
      'icon': Icons.movie,
      'sounds': [
        {
          'title': 'Star Wars',
          'uri': 'star_wars_intro',
          'description': 'Introducción de Star Wars'
        },
        {
          'title': 'Indiana Jones',
          'uri': 'indiana_jones',
          'description': 'Tema principal de Indiana Jones'
        },
        {
          'title': 'X-Files',
          'uri': 'x_files',
          'description': 'Tema de Expedientes X'
        },
        {
          'title': 'Mission Impossible',
          'uri': 'mission_imposible',
          'description': 'Tema de Misión Imposible'
        }
      ]
    },
    {
      'category': '😂 Memes y Humor',
      'icon': Icons.sentiment_very_satisfied,
      'sounds': [
        {
          'title': 'This is Sparta',
          'uri': 'this_is_sparta',
          'description': '¡THIS IS SPARTA!'
        },
        {
          'title': 'Surprise!',
          'uri': 'surprise_motherfucker',
          'description': 'Sorpresa inesperada'
        },
        {
          'title': 'Thug Life',
          'uri': 'thug_life_1',
          'description': 'Momento Thug Life'
        },
        {
          'title': 'Wilhelm Scream',
          'uri': 'wilhelm_scream',
          'description': 'El grito más famoso del cine'
        }
      ]
    },
    {
      'category': '📱 Clásicos',
      'icon': Icons.phone_android,
      'sounds': [
        {
          'title': 'Nokia 3310',
          'uri': 'nokia3310',
          'description': 'El mítico tono de Nokia'
        },
        {
          'title': 'iPhone Remix',
          'uri': 'iphone_6_remix',
          'description': 'Remix del tono de iPhone'
        },
        {
          'title': 'Android Remix',
          'uri': 'android_remix',
          'description': 'Remix del sonido de Android'
        }
      ]
    },
    {
      'category': '🎵 Efectos de Sonido',
      'icon': Icons.music_note,
      'sounds': [
        {
          'title': 'Dramatic',
          'uri': 'dramatic',
          'description': 'Efecto dramático'
        },
        {
          'title': 'MLG Airhorn',
          'uri': 'wtf_boom',
          'description': 'Clásico sonido de airhorn'
        },
        {
          'title': 'Badumtss',
          'uri': 'badumtss',
          'description': 'Ba dum tss!'
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingUri = null;
        });
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final sound = await ApiService.getNotificationSound();
      if (mounted) {
        setState(() {
          _currentSound = sound;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar sonidos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _playSound(String uri) async {
    // Si ya está reproduciendo este sonido, lo detiene
    if (_isPlaying && _currentlyPlayingUri == uri) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentlyPlayingUri = null;
      });
      return;
    }

    // Si está reproduciendo otro sonido, lo detiene
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    try {
      final assetPath = _soundPaths[uri];
      if (assetPath == null) {
        throw Exception('Sonido no encontrado');
      }

      setState(() {
        _isPlaying = true;
        _currentlyPlayingUri = uri;
      });

      await _audioPlayer.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
        volume: 1.0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reproducir sonido: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isPlaying = false;
          _currentlyPlayingUri = null;
        });
      }
    }
  }

  Future<void> _saveSound(String uri) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.setNotificationSound(uri);
      if (mounted) {
        setState(() => _currentSound = uri);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Sonido guardado correctamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el sonido: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSoundTile({
    required String title,
    required String uri,
    required String description,
  }) {
    final isSelected = uri == _currentSound;
    final isThisPlaying = _currentlyPlayingUri == uri;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: isThisPlaying ? Colors.green : Theme.of(context).primaryColor,
          child: IconButton(
            icon: Icon(
              isThisPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () => _playSound(uri),
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
            : ElevatedButton(
          onPressed: () => _saveSound(uri),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Seleccionar'),
        ),
        tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando sonidos...'),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: _soundCategories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sonidos de Notificación'),
          elevation: 2,
          bottom: TabBar(
            isScrollable: true,
            tabs: _soundCategories.map((category) => Tab(
              icon: Icon(category['icon'] as IconData),
              text: category['category'] as String,
            )).toList(),
          ),
        ),
        body: TabBarView(
          children: _soundCategories.map((category) =>
              ListView.builder(
                itemCount: (category['sounds'] as List).length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final sound = (category['sounds'] as List)[index];
                  return _buildSoundTile(
                    title: sound['title'],
                    uri: sound['uri'],
                    description: sound['description'],
                  );
                },
              ),
          ).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}