import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/mock_sim_data.dart';
import '../../models/beautiful_sim.dart';
import '../../models/sim_list_filter.dart';

class SimListScreen extends StatefulWidget {
  const SimListScreen({super.key});

  @override
  State<SimListScreen> createState() => _SimListScreenState();
}

class _SimListScreenState extends State<SimListScreen> {
  static const _allOption = 'Tất cả';

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _filterPanelKey = GlobalKey();

  var _query = '';
  var _selectedCarrier = _allOption;
  var _selectedType = _allOption;
  var _selectedPriceRange = SimPriceRange.all;
  var _didReadInitialFilter = false;
  var _showFilterShortcut = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadInitialFilter) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is SimListFilter) {
      _query = arguments.query;
      _selectedCarrier = arguments.carrier ?? _allOption;
      _selectedType = arguments.type ?? _allOption;
      _searchController.text = _query;
    }
    _didReadInitialFilter = true;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _carriers {
    final values = mockSims.map((sim) => sim.carrier).toSet().toList()..sort();
    return [_allOption, ...values];
  }

  List<String> get _types {
    final values = mockSims.map((sim) => sim.type).toSet().toList()..sort();
    return [_allOption, ...values];
  }

  List<BeautifulSim> get _filteredSims {
    final queryDigits = _query.replaceAll(RegExp(r'[^0-9]'), '');
    final queryText = _query.trim().toLowerCase();

    return mockSims.where((sim) {
      final simDigits = sim.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final matchesDigits =
          queryDigits.isNotEmpty && simDigits.contains(queryDigits);
      final matchesText = sim.phoneNumber.toLowerCase().contains(queryText);
      final matchesQuery = queryText.isEmpty || matchesDigits || matchesText;
      final matchesCarrier =
          _selectedCarrier == _allOption || sim.carrier == _selectedCarrier;
      final matchesType =
          _selectedType == _allOption || sim.type == _selectedType;
      final matchesPrice = _selectedPriceRange.matches(sim.price);

      return matchesQuery && matchesCarrier && matchesType && matchesPrice;
    }).toList();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 260;
    if (shouldShow != _showFilterShortcut) {
      setState(() => _showFilterShortcut = shouldShow);
    }
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _selectedCarrier = _allOption;
      _selectedType = _allOption;
      _selectedPriceRange = SimPriceRange.all;
      _searchController.clear();
    });
  }

  void _scrollToFilter() {
    final filterContext = _filterPanelKey.currentContext;
    if (filterContext != null) {
      Scrollable.ensureVisible(
        filterContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sims = _filteredSims;
    final availableCount = sims
        .where((sim) => sim.status == SimStatus.available)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho SIM đẹp'),
        actions: [
          IconButton(
            tooltip: 'Xóa lọc',
            onPressed: _resetFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _showFilterShortcut
            ? FloatingActionButton.small(
                key: const ValueKey('filter_shortcut_button'),
                tooltip: 'Về bộ lọc',
                onPressed: _scrollToFilter,
                child: const Icon(Icons.tune),
              )
            : const SizedBox.shrink(key: ValueKey('no_filter_shortcut')),
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 92),
          children: [
            _SearchPanel(
              controller: _searchController,
              query: _query,
              resultCount: sims.length,
              availableCount: availableCount,
              onChanged: (value) => setState(() => _query = value),
              onClear: () {
                setState(() {
                  _query = '';
                  _searchController.clear();
                });
              },
            ),
            const SizedBox(height: 12),
            _FilterPanel(
              key: _filterPanelKey,
              carriers: _carriers,
              types: _types,
              selectedCarrier: _selectedCarrier,
              selectedType: _selectedType,
              selectedPriceRange: _selectedPriceRange,
              onCarrierChanged: (value) {
                setState(() => _selectedCarrier = value ?? _allOption);
              },
              onTypeChanged: (value) {
                setState(() => _selectedType = value ?? _allOption);
              },
              onPriceRangeChanged: (value) {
                setState(() {
                  _selectedPriceRange = value ?? SimPriceRange.all;
                });
              },
              onReset: _resetFilters,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tất cả sim đang bán',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppPalette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    '${sims.length} sim',
                    key: ValueKey(sims.length),
                    style: const TextStyle(
                      color: AppPalette.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (sims.isEmpty)
              const _EmptySimList()
            else
              ...sims.map(
                (sim) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SimListItem(sim: sim),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.query,
    required this.resultCount,
    required this.availableCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final int resultCount;
  final int availableCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.red, AppPalette.redDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn số hợp gu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$availableCount SIM còn hàng trong $resultCount kết quả',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('sim_list_search_field'),
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              hintText: 'Nhập số cần tìm',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa từ khóa',
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                    ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    super.key,
    required this.carriers,
    required this.types,
    required this.selectedCarrier,
    required this.selectedType,
    required this.selectedPriceRange,
    required this.onCarrierChanged,
    required this.onTypeChanged,
    required this.onPriceRangeChanged,
    required this.onReset,
  });

  final List<String> carriers;
  final List<String> types;
  final String selectedCarrier;
  final String selectedType;
  final SimPriceRange selectedPriceRange;
  final ValueChanged<String?> onCarrierChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<SimPriceRange?> onPriceRangeChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppPalette.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppPalette.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bộ lọc',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppPalette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Đặt lại'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final useGrid = constraints.maxWidth >= 620;
                final fields = [
                  DropdownButtonFormField<String>(
                    key: ValueKey('carrier-$selectedCarrier'),
                    initialValue: selectedCarrier,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Nhà mạng',
                      prefixIcon: Icon(Icons.cell_tower_outlined),
                    ),
                    items: carriers
                        .map(
                          (carrier) => DropdownMenuItem(
                            value: carrier,
                            child: Text(carrier),
                          ),
                        )
                        .toList(),
                    onChanged: onCarrierChanged,
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey('type-$selectedType'),
                    initialValue: selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Loại sim',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: types
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: onTypeChanged,
                  ),
                  DropdownButtonFormField<SimPriceRange>(
                    key: ValueKey('price-$selectedPriceRange'),
                    initialValue: selectedPriceRange,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Khoảng giá',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    items: SimPriceRange.values
                        .map(
                          (range) => DropdownMenuItem(
                            value: range,
                            child: Text(range.label),
                          ),
                        )
                        .toList(),
                    onChanged: onPriceRangeChanged,
                  ),
                ];

                if (!useGrid) {
                  return Column(
                    children: [
                      fields[0],
                      const SizedBox(height: 10),
                      fields[1],
                      const SizedBox(height: 10),
                      fields[2],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: fields[0]),
                    const SizedBox(width: 10),
                    Expanded(child: fields[1]),
                    const SizedBox(width: 10),
                    Expanded(child: fields[2]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SimListItem extends StatelessWidget {
  const _SimListItem({required this.sim});

  final BeautifulSim sim;

  @override
  Widget build(BuildContext context) {
    final isAvailable = sim.status == SimStatus.available;
    final statusColor = isAvailable ? AppPalette.teal : AppPalette.danger;

    return Card(
      child: InkWell(
        onTap: isAvailable
            ? () => Navigator.of(context).pushNamed(AppRoutes.checkout)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.sim_card, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sim.phoneNumber,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppPalette.ink,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                              icon: Icons.cell_tower_outlined,
                              label: sim.carrier,
                            ),
                            _InfoPill(
                              icon: Icons.category_outlined,
                              label: sim.type,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: sim.status.label, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.red.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: AppPalette.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formatCurrency(sim.price),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppPalette.red,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: isAvailable
                        ? () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.checkout)
                        : null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(104, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text('Mua'),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppPalette.paper,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppPalette.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptySimList extends StatelessWidget {
  const _EmptySimList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppPalette.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.manage_search,
              size: 32,
              color: AppPalette.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy sim phù hợp',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thử đổi nhà mạng, loại sim hoặc khoảng giá.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppPalette.muted,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

enum SimPriceRange { all, under10m, from10mTo30m, from30mTo100m, above100m }

extension SimPriceRangeInfo on SimPriceRange {
  String get label {
    return switch (this) {
      SimPriceRange.all => 'Tất cả',
      SimPriceRange.under10m => 'Dưới 10 triệu',
      SimPriceRange.from10mTo30m => '10 - 30 triệu',
      SimPriceRange.from30mTo100m => '30 - 100 triệu',
      SimPriceRange.above100m => 'Trên 100 triệu',
    };
  }

  bool matches(int price) {
    return switch (this) {
      SimPriceRange.all => true,
      SimPriceRange.under10m => price < 10000000,
      SimPriceRange.from10mTo30m => price >= 10000000 && price <= 30000000,
      SimPriceRange.from30mTo100m => price > 30000000 && price <= 100000000,
      SimPriceRange.above100m => price > 100000000,
    };
  }
}
