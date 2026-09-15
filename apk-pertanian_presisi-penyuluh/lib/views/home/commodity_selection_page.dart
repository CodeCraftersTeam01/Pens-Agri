import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/commodity_model.dart';
import '../checkup/soil_probe_capture_page.dart';

class CommoditySelectionPage extends StatefulWidget {
  const CommoditySelectionPage({super.key});

  @override
  State<CommoditySelectionPage> createState() => _CommoditySelectionPageState();
}

class _CommoditySelectionPageState extends State<CommoditySelectionPage> {
  final List<CommodityModel> _commodities = CommodityModel.defaultCommodities;
  late CommodityModel _selectedCommodity;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCommodity = _commodities.first;
  }

  IconData _getIconData(String iconCode) {
    switch (iconCode) {
      case 'grass':
        return Icons.grass;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'agriculture':
        return Icons.agriculture;
      case 'spa':
        return Icons.spa;
      case 'nutrition':
        return Icons.eco;
      case 'nature':
        return Icons.nature;
      case 'compost':
        return Icons.yard;
      case 'add_circle':
        return Icons.add_circle_outline;
      default:
        return Icons.park;
    }
  }

  List<CommodityModel> get _filteredCommodities {
    if (_searchQuery.trim().isEmpty) return _commodities;
    final query = _searchQuery.toLowerCase();
    return _commodities.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.variety.toLowerCase().contains(query);
    }).toList();
  }

  void _navigateToSoilProbePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoilProbeCapturePage(
          selectedCommodity: _selectedCommodity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.park, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'AgriSensor',
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PENS',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Presisi Tanah & Tanaman',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Top Greeting & Micro-Climate Strip
                  _buildGreetingClimateCard(),
                  const SizedBox(height: 14),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Komoditas Tani',
                        style: AppTypography.headlineSm.copyWith(fontSize: 17),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_commodities.length} Pilihan',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih tanaman untuk kalibrasi otomatis nilai rujukan sensor tanah.',
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: 12),

                  // 2-Column Commodity Grid
                  _buildCommodityGrid(),
                  const SizedBox(height: 14),

                  // IoT Quick Device Status Card
                  _buildIotStatusCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Sticky Bottom CTA Button
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingClimateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DASHBOARD LAPANGAN',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Halo, Petani Cerdas! 🌾',
                    style: AppTypography.headlineMd.copyWith(fontSize: 19),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'IoT Aktif',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.tertiaryAmber),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Lahan Sawah Blok B-4, Lamongan',
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Micro-Climate Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wb_sunny, color: AppColors.tertiaryAmber, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '29°C  |  RH 78%',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            'Kondisi Cocok untuk Sampling',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari komoditas pertanian...',
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildCommodityGrid() {
    final list = _filteredCommodities;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final crop = list[index];
        final isSelected = crop.id == _selectedCommodity.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCommodity = crop;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryFixed.withValues(alpha: 0.25)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getIconData(crop.iconCode),
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        if (crop.isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Unggulan',
                              style: AppTypography.labelSm.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          crop.variety,
                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryFixed.withValues(alpha: 0.4)
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            crop.sampleCount > 0 ? '${crop.sampleCount} Titik' : '+ Kustom',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            crop.status,
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIotStatusCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sensors, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sensor IoT PENS Probe',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'CH340 USB Serial @9600 Baud',
                    style: AppTypography.bodySm.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.battery_5_bar, color: AppColors.primary, size: 16),
                const SizedBox(width: 2),
                Text(
                  '94%',
                  style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _navigateToSoilProbePage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pilih ${_selectedCommodity.name} & Lanjut Cek Tanah',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
