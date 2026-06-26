import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../data/models/nearby_place.dart';
import '../providers/nearby_provider.dart';

class NearbyHomeScreen extends StatelessWidget {
  const NearbyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NearBy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NearbyProvider>().loadPlaces(),
          ),
        ],
      ),
      body: const _NearbyBody(),
    );
  }
}

class _NearbyBody extends StatefulWidget {
  const _NearbyBody();

  @override
  State<_NearbyBody> createState() => _NearbyBodyState();
}

class _NearbyBodyState extends State<_NearbyBody> {
  final _mapController = MapController();
  String? _highlightedPlaceId;

  void _moveToPlace(NearbyPlace place) {
    setState(() => _highlightedPlaceId = place.id);
    _mapController.move(LatLng(place.latitude, place.longitude), 15);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NearbyProvider>();
    final theme = Theme.of(context);
    final center =
        provider.userLatitude != null && provider.userLongitude != null
        ? LatLng(provider.userLatitude!, provider.userLongitude!)
        : LatLng(48.8566, 2.3522);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: provider.selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: provider.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: theme.textTheme.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.changeCategory(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.loadPlaces(),
                child: provider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Actualiser'),
              ),
            ],
          ),
        ),
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  provider.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
        if (!provider.hasPermission)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Accès GPS requis pour afficher les lieux à proximité.',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        if (provider.userLatitude != null && provider.userLongitude != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Position: ${provider.userLatitude!.toStringAsFixed(5)}, ${provider.userLongitude!.toStringAsFixed(5)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text('Rayon 5 km', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (provider.userLatitude != null && provider.userLongitude != null)
          SizedBox(
            height: 260,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.hardEdge,
              child: FlutterMap(
                mapController: _mapController,
                // 1. Changement ici : initialCenter et initialZoom
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13,
                  minZoom: 3,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'fr.example.quiz_master',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: center,
                        // 2. Changement ici : 'child' au lieu de 'builder'
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blueAccent,
                        ),
                      ),
                      ...provider.places.map((place) {
                        final isHighlighted = place.id == _highlightedPlaceId;
                        return Marker(
                          width: isHighlighted ? 52 : 40,
                          height: isHighlighted ? 52 : 40,
                          point: LatLng(place.latitude, place.longitude),
                          child: Icon(
                            Icons.location_on,
                            color: isHighlighted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            size: isHighlighted ? 52 : 40,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: provider.isLoading && provider.places.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.places.isEmpty
              ? Center(
                  child: Text(
                    provider.isLoading ? 'Chargement...' : 'Aucun lieu trouvé.',
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.places.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final place = provider.places[index];
                    return _NearbyPlaceTile(
                      place: place,
                      onTap: () => _moveToPlace(place),
                      isHighlighted: place.id == _highlightedPlaceId,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NearbyPlaceTile extends StatelessWidget {
  const _NearbyPlaceTile({
    required this.place,
    required this.onTap,
    this.isHighlighted = false,
  });

  final NearbyPlace place;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isHighlighted ? 6 : 2,
      color: isHighlighted
          ? theme.colorScheme.primary.withValues(alpha: 20)
          : null,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Text(place.name, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.category, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              place.address.isNotEmpty ? place.address : 'Adresse inconnue',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          '${(place.distanceMeters / 1000).toStringAsFixed(1)} km',
          style: theme.textTheme.labelLarge,
        ),
      ),
    );
  }
}
