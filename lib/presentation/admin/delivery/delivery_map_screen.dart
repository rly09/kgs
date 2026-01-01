import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/route_model.dart';
import '../../../data/services/route_service.dart';
import '../../../data/services/order_service.dart';
import '../../../providers.dart';

class DeliveryMapScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const DeliveryMapScreen({Key? key, required this.order}) : super(key: key);

  @override
  ConsumerState<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends ConsumerState<DeliveryMapScreen> {
  final RouteService _routeService = RouteService();
  RouteModel? _route;
  bool _isLoadingRoute = true;
  String? _error;
  bool _isMarkingDelivered = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      setState(() {
        _isLoadingRoute = true;
        _error = null;
      });

      // Parse customer coordinates from delivery address
      // Format expected: "lat,lng" or extract from address
      final customerLocation = _parseCustomerLocation();

      final route = await _routeService.getRoute(
        AppConfig.shopLocation,
        customerLocation,
      );

      setState(() {
        _route = route;
        _isLoadingRoute = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingRoute = false;
      });
    }
  }

  LatLng _parseCustomerLocation() {
    // Use coordinates from order if available
    if (widget.order.deliveryLatitude != null && widget.order.deliveryLongitude != null) {
      return LatLng(widget.order.deliveryLatitude!, widget.order.deliveryLongitude!);
    }
    
    // Fallback: Use a location near the shop
    // In production, you should either:
    // 1. Require coordinates when placing order
    // 2. Use a geocoding service to convert address to coordinates
    return LatLng(
      AppConfig.shopLocation.latitude + 0.01, // Slightly offset from shop
      AppConfig.shopLocation.longitude + 0.01,
    );
  }

  Future<void> _markAsDelivered() async {
    try {
      setState(() => _isMarkingDelivered = true);

      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(widget.order.id, 'DELIVERED');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as delivered'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingDelivered = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerLocation = _parseCustomerLocation();

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery to ${widget.order.customerName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              initialCenter: AppConfig.shopLocation,
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kgs.shop',
              ),
              
              // Route polyline
              if (_route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route!.coordinates,
                      strokeWidth: 4.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              
              // Markers
              MarkerLayer(
                markers: [
                  // Shop marker
                  Marker(
                    point: AppConfig.shopLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  // Customer marker
                  Marker(
                    point: customerLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Loading overlay
          if (_isLoadingRoute)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Error message
          if (_error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: AppColors.error,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Route error: $_error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order info
                  Row(
                    children: [
                      const Icon(Icons.receipt, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${widget.order.id}',
                              style: AppTextStyles.heading4,
                            ),
                            Text(
                              widget.order.deliveryAddress,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Distance and duration
                  if (_route != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _InfoChip(
                          icon: Icons.route,
                          label: '${_route!.distanceKm.toStringAsFixed(1)} km',
                        ),
                        _InfoChip(
                          icon: Icons.access_time,
                          label: '${_route!.durationMinutes} min',
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Mark as Delivered button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isMarkingDelivered ? null : _markAsDelivered,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isMarkingDelivered
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Mark as Delivered',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
