import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/coupon_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/formatters.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _didRequestAdminData = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (!auth.canManageShop) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Quản trị shop')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 72,
                  color: AppTheme.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn không có quyền quản lý shop',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.home,
                  ),
                  child: const Text('Về trang chủ'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _scheduleAdminDataLoad();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Quản trị shop'),
          actions: [
            IconButton(
              tooltip: 'Tải lại',
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshAdminData(context),
            ),
            IconButton(
              tooltip: 'Đăng xuất',
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.grey,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Tổng quan'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Sản phẩm'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Đơn hàng'),
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'Người dùng'),
              Tab(icon: Icon(Icons.local_offer_outlined), text: 'Mã giảm giá'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(onRefresh: () => _refreshAdminData(context)),
            const _ProductsTab(),
            const _OrdersTab(),
            const _UsersTab(),
            const _CouponsTab(),
          ],
        ),
      ),
    );
  }

  void _scheduleAdminDataLoad() {
    if (_didRequestAdminData) return;
    _didRequestAdminData = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshAdminData(context);
    });
  }

  Future<void> _refreshAdminData(BuildContext context) async {
    await Future.wait([
      context.read<ProductProvider>().loadAdminProducts(),
      context.read<CategoryProvider>().loadCategories(),
      context.read<OrderProvider>().loadAdminOrders(),
      context.read<UserProvider>().loadUsers(),
      context.read<CouponProvider>().loadAdminCoupons(),
    ]);
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().adminProducts;
    final orders = context.watch<OrderProvider>().adminOrders;
    final users = context.watch<UserProvider>().users;
    final coupons = context.watch<CouponProvider>().adminCoupons;

    final activeProducts = products.where((product) => product.isActive).length;
    final lowStockProducts = products
        .where((product) => product.isActive && product.totalStock <= 5);
    final pendingOrders =
        orders.where((order) => order.status == OrderStatus.pending).length;
    final completedRevenue = orders
        .where((order) => order.status == OrderStatus.completed)
        .fold<int>(0, (total, order) => total + order.total);
    final activeCoupons = coupons.where((coupon) => coupon.isActive).length;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminHeader(
            title: 'Tổng quan',
            subtitle: 'Theo dõi nhanh hoạt động của cửa hàng',
            icon: Icons.dashboard_outlined,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 3 : 2;
              final spacing = 12.0;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: width,
                    child: _StatTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Sản phẩm',
                      value: '$activeProducts',
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _StatTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Đơn hàng',
                      value: '${orders.length}',
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _StatTile(
                      icon: Icons.pending_actions_outlined,
                      label: 'Chờ xử lý',
                      value: '$pendingOrders',
                      color: AppTheme.warning,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _StatTile(
                      icon: Icons.payments_outlined,
                      label: 'Doanh thu',
                      value: Formatters.currency(completedRevenue),
                      color: AppTheme.success,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _StatTile(
                      icon: Icons.people_alt_outlined,
                      label: 'Người dùng',
                      value: '${users.length}',
                      color: const Color(0xFF673AB7),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _StatTile(
                      icon: Icons.local_offer_outlined,
                      label: 'Coupon',
                      value: '$activeCoupons',
                      color: AppTheme.favorite,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Đơn gần đây',
            trailing: '${orders.take(5).length} đơn',
          ),
          const SizedBox(height: 8),
          if (orders.isEmpty)
            const _EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Chưa có đơn hàng',
            )
          else
            ...orders.take(5).map(
                  (order) => _AdminCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${Formatters.dateTime(order.createdAt)} • ${Formatters.currency(order.total)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(
                          label: order.statusLabel,
                          color: order.statusColor,
                        ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Sắp hết hàng',
            trailing: '${lowStockProducts.length} sản phẩm',
          ),
          const SizedBox(height: 8),
          if (lowStockProducts.isEmpty)
            const _EmptyState(
              icon: Icons.check_circle_outline,
              message: 'Tồn kho đang ổn',
            )
          else
            ...lowStockProducts.take(5).map(
                  (product) => _AdminCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusPill(
                          label: 'Còn ${product.totalStock}',
                          color: AppTheme.warning,
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

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  String _query = '';
  String _categoryId = 'all';
  bool _showInactive = true;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final products = _filteredProducts(
      productProvider.adminProducts,
      categoryProvider.categories,
    );

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => context.read<ProductProvider>().loadAdminProducts(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminHeader(
            title: 'Sản phẩm',
            subtitle: '${products.length} sản phẩm phù hợp',
            icon: Icons.inventory_2_outlined,
            action: ElevatedButton.icon(
              onPressed: productProvider.isAdminLoading
                  ? null
                  : () => _openProductForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm'),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm sản phẩm, thương hiệu',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _categoryId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_outlined),
              labelText: 'Danh mục',
            ),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('Tất cả')),
              ...categoryProvider.categories.map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _categoryId = value ?? 'all'),
          ),
          SwitchListTile(
            value: _showInactive,
            contentPadding: EdgeInsets.zero,
            title: const Text('Hiện sản phẩm đã ẩn'),
            onChanged: (value) => setState(() => _showInactive = value),
          ),
          if (productProvider.isAdminLoading &&
              productProvider.adminProducts.isEmpty)
            const _LoadingBlock()
          else if (productProvider.adminError != null)
            _ErrorBlock(message: productProvider.adminError!)
          else if (products.isEmpty)
            const _EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'Không có sản phẩm phù hợp',
            )
          else
            ...products.map(
              (product) => _ProductCard(
                product: product,
                categories: categoryProvider.categories,
                onEdit: () => _openProductForm(context, product: product),
                onToggleActive: () => _toggleProductActive(context, product),
                onCreateDeal: () => _openHotDealDialog(context, product),
                onDisableDeal: () => _disableHotDeal(context, product),
              ),
            ),
        ],
      ),
    );
  }

  List<Product> _filteredProducts(
    List<Product> products,
    List<CategoryModel> categories,
  ) {
    final query = _query.trim().toLowerCase();
    return products.where((product) {
      final category = categories.firstWhere(
        (item) => item.id == product.categoryId,
        orElse: () => CategoryModel(id: product.categoryId, name: ''),
      );
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          category.name.toLowerCase().contains(query);
      final matchesCategory =
          _categoryId == 'all' || product.categoryId == _categoryId;
      final matchesActive = _showInactive || product.isActive;

      return matchesQuery && matchesCategory && matchesActive;
    }).toList();
  }

  Future<void> _openProductForm(
    BuildContext context, {
    Product? product,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProductFormSheet(product: product),
    );
    if (!context.mounted || saved != true) return;

    _showSnack(
      context,
      product == null ? 'Đã thêm sản phẩm' : 'Đã cập nhật sản phẩm',
    );
  }

  Future<void> _toggleProductActive(
    BuildContext context,
    Product product,
  ) async {
    final nextActive = !product.isActive;
    if (!nextActive) {
      final confirmed = await _confirmAction(
        context,
        title: 'Ẩn sản phẩm',
        message: 'Sản phẩm sẽ không hiển thị cho khách hàng.',
      );
      if (!context.mounted || !confirmed) return;
    }

    final success = await context
        .read<ProductProvider>()
        .setProductActive(product.id, nextActive);
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? (nextActive ? 'Đã khôi phục sản phẩm' : 'Đã ẩn sản phẩm')
          : context.read<ProductProvider>().adminError ?? 'Không cập nhật được',
    );
  }

  Future<void> _openHotDealDialog(
    BuildContext context,
    Product product,
  ) async {
    final input = await showDialog<_HotDealInput>(
      context: context,
      builder: (_) => _HotDealDialog(product: product),
    );
    if (!context.mounted || input == null) return;

    final success = await context.read<ProductProvider>().updateHotDeal(
          product.id,
          input.salePrice,
          input.dealStartAt,
          input.dealEndAt,
          input.dealStock,
        );
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? 'Đã tạo deal'
          : context.read<ProductProvider>().adminError ?? 'Không tạo được deal',
    );
  }

  Future<void> _disableHotDeal(
    BuildContext context,
    Product product,
  ) async {
    final success =
        await context.read<ProductProvider>().disableHotDeal(product.id);
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? 'Đã tắt deal'
          : context.read<ProductProvider>().adminError ?? 'Không tắt được deal',
    );
  }
}

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _query = '';
  String _status = 'all';

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = _filteredOrders(orderProvider.adminOrders);

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => context.read<OrderProvider>().loadAdminOrders(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminHeader(
            title: 'Đơn hàng',
            subtitle: '${orders.length} đơn phù hợp',
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm mã đơn, số điện thoại, địa chỉ',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.tune),
              labelText: 'Trạng thái',
            ),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('Tất cả')),
              ...OrderStatus.values.map(
                (status) => DropdownMenuItem(
                  value: status.name,
                  child: Text(_orderStatusLabel(status)),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _status = value ?? 'all'),
          ),
          const SizedBox(height: 12),
          if (orderProvider.isAdminLoading && orderProvider.adminOrders.isEmpty)
            const _LoadingBlock()
          else if (orderProvider.adminError != null)
            _ErrorBlock(message: orderProvider.adminError!)
          else if (orders.isEmpty)
            const _EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Không có đơn hàng phù hợp',
            )
          else
            ...orders.map(
              (order) => _OrderCard(
                order: order,
                onStatusChanged: (status) =>
                    _updateOrderStatus(context, order, status),
              ),
            ),
        ],
      ),
    );
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    final query = _query.trim().toLowerCase();
    return orders.where((order) {
      final matchesStatus = _status == 'all' || order.status.name == _status;
      final matchesQuery = query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          order.phone.toLowerCase().contains(query) ||
          order.shippingAddress.toLowerCase().contains(query) ||
          order.userId.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    OrderModel order,
    OrderStatus status,
  ) async {
    if (status == order.status) return;

    final success =
        await context.read<OrderProvider>().updateOrderStatus(order.id, status);
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? 'Đã cập nhật đơn ${order.id}'
          : context.read<OrderProvider>().adminError ?? 'Không cập nhật được',
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUid = context.watch<AuthProvider>().currentUser?.uid;
    final users = _filteredUsers(userProvider.users);

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => context.read<UserProvider>().loadUsers(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminHeader(
            title: 'Người dùng',
            subtitle: '${users.length} tài khoản phù hợp',
            icon: Icons.people_alt_outlined,
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm tên, email, số điện thoại',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          if (userProvider.isAdminLoading && userProvider.users.isEmpty)
            const _LoadingBlock()
          else if (userProvider.adminError != null)
            _ErrorBlock(message: userProvider.adminError!)
          else if (users.isEmpty)
            const _EmptyState(
              icon: Icons.people_alt_outlined,
              message: 'Không có người dùng phù hợp',
            )
          else
            ...users.map(
              (user) => _UserCard(
                user: user,
                isCurrentUser: user.uid == currentUid,
                onRoleChanged: (role) => _updateRole(context, user, role),
                onActiveChanged: (isActive) =>
                    _updateActive(context, user, isActive),
              ),
            ),
        ],
      ),
    );
  }

  List<UserModel> _filteredUsers(List<UserModel> users) {
    final query = _query.trim().toLowerCase();
    return users.where((user) {
      return query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _updateRole(
    BuildContext context,
    UserModel user,
    String role,
  ) async {
    if (role == user.role) return;

    final success =
        await context.read<UserProvider>().updateUserRole(user.uid, role);
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? 'Đã cập nhật quyền ${user.email}'
          : context.read<UserProvider>().adminError ?? 'Không cập nhật được',
    );
  }

  Future<void> _updateActive(
    BuildContext context,
    UserModel user,
    bool isActive,
  ) async {
    final success =
        await context.read<UserProvider>().updateUserActive(user.uid, isActive);
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? (isActive ? 'Đã mở tài khoản' : 'Đã khóa tài khoản')
          : context.read<UserProvider>().adminError ?? 'Không cập nhật được',
    );
  }
}

class _CouponsTab extends StatefulWidget {
  const _CouponsTab();

  @override
  State<_CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<_CouponsTab> {
  String _query = '';
  bool _showInactive = true;

  @override
  Widget build(BuildContext context) {
    final couponProvider = context.watch<CouponProvider>();
    final coupons = _filteredCoupons(couponProvider.adminCoupons);

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => context.read<CouponProvider>().loadAdminCoupons(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminHeader(
            title: 'Mã giảm giá',
            subtitle: '${coupons.length} mã phù hợp',
            icon: Icons.local_offer_outlined,
            action: ElevatedButton.icon(
              onPressed: couponProvider.isAdminLoading
                  ? null
                  : () => _openCouponForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm'),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm mã giảm giá',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          SwitchListTile(
            value: _showInactive,
            contentPadding: EdgeInsets.zero,
            title: const Text('Hiện mã đã tắt'),
            onChanged: (value) => setState(() => _showInactive = value),
          ),
          if (couponProvider.isAdminLoading &&
              couponProvider.adminCoupons.isEmpty)
            const _LoadingBlock()
          else if (couponProvider.adminError != null)
            _ErrorBlock(message: couponProvider.adminError!)
          else if (coupons.isEmpty)
            const _EmptyState(
              icon: Icons.local_offer_outlined,
              message: 'Không có mã giảm giá phù hợp',
            )
          else
            ...coupons.map(
              (coupon) => _CouponCard(
                coupon: coupon,
                onEdit: () => _openCouponForm(context, coupon: coupon),
                onToggleActive: () => _toggleCouponActive(context, coupon),
              ),
            ),
        ],
      ),
    );
  }

  List<CouponModel> _filteredCoupons(List<CouponModel> coupons) {
    final query = _query.trim().toUpperCase();
    return coupons.where((coupon) {
      final matchesQuery = query.isEmpty || coupon.code.contains(query);
      final matchesActive = _showInactive || coupon.isActive;
      return matchesQuery && matchesActive;
    }).toList();
  }

  Future<void> _openCouponForm(
    BuildContext context, {
    CouponModel? coupon,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CouponFormSheet(coupon: coupon),
    );
    if (!context.mounted || saved != true) return;

    _showSnack(
      context,
      coupon == null ? 'Đã thêm mã giảm giá' : 'Đã cập nhật mã giảm giá',
    );
  }

  Future<void> _toggleCouponActive(
    BuildContext context,
    CouponModel coupon,
  ) async {
    final nextActive = !coupon.isActive;
    final success = await context
        .read<CouponProvider>()
        .setCouponActive(coupon.id, nextActive);
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? (nextActive ? 'Đã bật mã giảm giá' : 'Đã tắt mã giảm giá')
          : context.read<CouponProvider>().adminError ?? 'Không cập nhật được',
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.categories,
    required this.onEdit,
    required this.onToggleActive,
    required this.onCreateDeal,
    required this.onDisableDeal,
  });

  final Product product;
  final List<CategoryModel> categories;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onCreateDeal;
  final VoidCallback onDisableDeal;

  @override
  Widget build(BuildContext context) {
    final categoryMatches =
        categories.where((category) => category.id == product.categoryId);
    final categoryName =
        categoryMatches.isEmpty ? '' : categoryMatches.first.name;

    return _AdminCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(imageUrl: product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _StatusPill(
                      label: product.isActive ? 'Đang bán' : 'Đã ẩn',
                      color:
                          product.isActive ? AppTheme.success : AppTheme.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (product.brand.isNotEmpty) product.brand,
                    if (categoryName.isNotEmpty) categoryName,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniMetric(
                      icon: Icons.sell_outlined,
                      text: Formatters.currency(product.minPrice),
                    ),
                    _MiniMetric(
                      icon: Icons.inventory_outlined,
                      text: 'Kho ${product.totalStock}',
                    ),
                    if (product.isFeatured)
                      const _MiniMetric(
                        icon: Icons.star_outline,
                        text: 'Nổi bật',
                      ),
                    if (product.hasActiveDeal)
                      const _MiniMetric(
                        icon: Icons.local_fire_department_outlined,
                        text: 'Đang deal',
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Sửa sản phẩm',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton.filledTonal(
                      tooltip: product.isActive
                          ? 'Ẩn sản phẩm'
                          : 'Khôi phục sản phẩm',
                      onPressed: onToggleActive,
                      icon: Icon(
                        product.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onCreateDeal,
                      icon: const Icon(Icons.local_fire_department, size: 16),
                      label: const Text('Tạo deal'),
                    ),
                    if (product.isHotDeal)
                      OutlinedButton.icon(
                        onPressed: onDisableDeal,
                        icon: const Icon(Icons.flash_off_outlined, size: 16),
                        label: const Text('Tắt deal'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HotDealInput {
  const _HotDealInput({
    required this.salePrice,
    required this.dealStartAt,
    required this.dealEndAt,
    this.dealStock,
  });

  final int salePrice;
  final DateTime dealStartAt;
  final DateTime dealEndAt;
  final int? dealStock;
}

class _HotDealDialog extends StatefulWidget {
  const _HotDealDialog({required this.product});

  final Product product;

  @override
  State<_HotDealDialog> createState() => _HotDealDialogState();
}

class _HotDealDialogState extends State<_HotDealDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;
  late DateTime _selectedEndAt;
  bool _formattingSalePrice = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _salePriceController = TextEditingController(
      text: product.salePrice == null ? '' : _moneyInput(product.salePrice!),
    );
    _stockController = TextEditingController(
      text: product.dealStock == null ? '' : product.dealStock.toString(),
    );
    final currentEndAt = product.dealEndAt;
    _selectedEndAt =
        currentEndAt != null && currentEndAt.isAfter(DateTime.now())
            ? currentEndAt
            : _todayAt2359();
  }

  @override
  void dispose() {
    _salePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final salePrice = _salePrice;
    final dealStock = _dealStock;
    final saving = salePrice > 0 && salePrice < product.price
        ? product.price - salePrice
        : 0;
    final discountPercent =
        saving > 0 ? (saving * 100 / product.price).round() : 0;

    return AlertDialog(
      title: const Text('Tạo deal'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dealProductSummary(product),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _salePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Giá deal',
                    hintText: '4.990.000đ',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                  onChanged: _formatSalePrice,
                  validator: _salePriceValidator,
                ),
                const SizedBox(height: 10),
                _sectionLabel('Gợi ý giảm giá'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [5, 10, 15, 20].map((percent) {
                    return _quickChip(
                      label: '-$percent%',
                      onTap: () => _applyDiscount(percent),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _sectionLabel('Thời gian kết thúc'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickChip(
                      label: 'Hôm nay 23:59',
                      selected: _isSameMinute(_selectedEndAt, _todayAt2359()),
                      onTap: () => _setEndAt(_todayAt2359()),
                    ),
                    _quickChip(
                      label: '24 giờ',
                      onTap: () => _setEndAt(
                          DateTime.now().add(const Duration(hours: 24))),
                    ),
                    _quickChip(
                      label: '3 ngày',
                      onTap: () => _setEndAt(
                          DateTime.now().add(const Duration(days: 3))),
                    ),
                    _quickChip(
                      label: '7 ngày',
                      onTap: () => _setEndAt(
                          DateTime.now().add(const Duration(days: 7))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _infoLine(
                  Icons.schedule_outlined,
                  'Kết thúc: ${Formatters.dateTime(_selectedEndAt)}',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng deal',
                    prefixIcon: Icon(Icons.inventory_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: _stockValidator,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...[10, 20, 50, 100].map(
                      (quantity) => _quickChip(
                        label: '$quantity',
                        selected: dealStock == quantity,
                        onTap: quantity <= product.totalStock
                            ? () => _setStock(quantity)
                            : null,
                      ),
                    ),
                    _quickChip(
                      label: 'Theo tồn kho',
                      selected: product.totalStock > 0 &&
                          dealStock == product.totalStock,
                      onTap: product.totalStock > 0
                          ? () => _setStock(product.totalStock)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _previewCard(
                  saving: saving,
                  discountPercent: discountPercent,
                  endAt: _selectedEndAt,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  Widget _dealProductSummary(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _summaryPill('Giá gốc ${Formatters.currency(product.price)}'),
              _summaryPill('Tồn kho ${product.totalStock}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppTheme.black),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppTheme.black,
      ),
    );
  }

  Widget _quickChip({
    required String label,
    required VoidCallback? onTap,
    bool selected = false,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap(),
      selectedColor: AppTheme.primary.withValues(alpha: 0.16),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primary : AppTheme.black,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected ? AppTheme.primary : AppTheme.greyLight,
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.grey),
          ),
        ),
      ],
    );
  }

  Widget _previewCard({
    required int saving,
    required int discountPercent,
    required DateTime endAt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            saving > 0
                ? 'Tiết kiệm ${Formatters.currency(saving)} • Giảm $discountPercent%'
                : 'Nhập giá deal để xem mức giảm',
            style: TextStyle(
              fontSize: 12,
              color: saving > 0 ? AppTheme.primary : AppTheme.grey,
              fontWeight: saving > 0 ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kết thúc lúc ${Formatters.dateTime(endAt)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_canSubmit || !_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      _HotDealInput(
        salePrice: _salePrice,
        dealStartAt: DateTime.now(),
        dealEndAt: _selectedEndAt,
        dealStock: _dealStock,
      ),
    );
  }

  void _formatSalePrice(String value) {
    if (_formattingSalePrice) return;
    final amount = _parseInt(value);
    final text = amount <= 0 ? '' : _moneyInput(amount);
    _formattingSalePrice = true;
    _salePriceController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.isEmpty ? 0 : text.length - 1,
      ),
    );
    _formattingSalePrice = false;
    setState(() {});
  }

  void _applyDiscount(int percent) {
    final salePrice = widget.product.price * (100 - percent) ~/ 100;
    final text = _moneyInput(salePrice);
    _salePriceController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length - 1),
    );
    setState(() {});
  }

  void _setEndAt(DateTime value) {
    setState(() => _selectedEndAt = value);
  }

  void _setStock(int value) {
    _stockController.text = value.toString();
    setState(() {});
  }

  DateTime _todayAt2359() {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59);
    return todayEnd.isAfter(now)
        ? todayEnd
        : now.add(const Duration(hours: 24));
  }

  bool _isSameMinute(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day &&
        first.hour == second.hour &&
        first.minute == second.minute;
  }

  int get _salePrice => _parseInt(_salePriceController.text);

  int get _dealStock => _parseInt(_stockController.text);

  bool get _canSubmit {
    final salePrice = _salePrice;
    final dealStock = _dealStock;
    return salePrice > 0 &&
        salePrice < widget.product.price &&
        _selectedEndAt.isAfter(DateTime.now()) &&
        dealStock > 0 &&
        dealStock <= widget.product.totalStock;
  }

  String? _salePriceValidator(String? value) {
    final salePrice = _parseInt(value ?? '');
    if (salePrice <= 0) return 'Giá deal phải > 0';
    if (salePrice >= widget.product.price) {
      return 'Giá deal phải nhỏ hơn giá gốc';
    }
    return null;
  }

  String? _stockValidator(String? value) {
    final stock = _parseInt(value ?? '');
    if (stock <= 0) return 'Số lượng phải > 0';
    if (stock > widget.product.totalStock) {
      return 'Không vượt tồn kho';
    }
    return null;
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  final OrderModel order;
  final ValueChanged<OrderStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final itemPreview = order.items
        .take(2)
        .map((item) => '${item.productName} x${item.quantity}')
        .join(', ');

    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.dateTime(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: order.statusLabel, color: order.statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            itemPreview.isEmpty ? 'Không có sản phẩm' : itemPreview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppTheme.black),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniMetric(
                icon: Icons.payments_outlined,
                text: Formatters.currency(order.total),
              ),
              _MiniMetric(
                icon: Icons.phone_outlined,
                text: order.phone.isEmpty ? 'Chưa có SĐT' : order.phone,
              ),
              _MiniMetric(
                icon: Icons.shopping_bag_outlined,
                text: '${order.items.length} món',
              ),
            ],
          ),
          if (order.shippingAddress.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              order.shippingAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppTheme.grey),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<OrderStatus>(
            initialValue: order.status,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.local_shipping_outlined),
              labelText: 'Cập nhật trạng thái',
            ),
            items: OrderStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_orderStatusLabel(status)),
                  ),
                )
                .toList(),
            onChanged: (status) {
              if (status != null) onStatusChanged(status);
            },
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isCurrentUser,
    required this.onRoleChanged,
    required this.onActiveChanged,
  });

  final UserModel user;
  final bool isCurrentUser;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                foregroundColor: AppTheme.primary,
                child: Text(_initials(user)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty ? user.email : user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: user.isActive ? 'Hoạt động' : 'Đã khóa',
                color: user.isActive ? AppTheme.success : AppTheme.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue:
                      user.isAdmin ? UserModel.roleAdmin : UserModel.roleUser,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    labelText: 'Quyền',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: UserModel.roleUser,
                      child: Text('User'),
                    ),
                    DropdownMenuItem(
                      value: UserModel.roleAdmin,
                      child: Text('Admin'),
                    ),
                  ],
                  onChanged:
                      isCurrentUser ? null : (value) => onRoleChanged(value!),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Switch(
                    value: user.isActive,
                    activeThumbColor: AppTheme.primary,
                    onChanged: isCurrentUser ? null : onActiveChanged,
                  ),
                  Text(
                    isCurrentUser ? 'Bạn' : 'Khóa',
                    style: const TextStyle(fontSize: 11, color: AppTheme.grey),
                  ),
                ],
              ),
            ],
          ),
          if (user.phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MiniMetric(icon: Icons.phone_outlined, text: user.phone),
          ],
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onToggleActive,
  });

  final CouponModel coupon;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.favorite.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: AppTheme.favorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _couponDescription(coupon),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: coupon.isActive ? 'Đang bật' : 'Đã tắt',
                color: coupon.isActive ? AppTheme.success : AppTheme.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniMetric(
                icon: Icons.shopping_cart_outlined,
                text: 'Tối thiểu ${Formatters.currency(coupon.minOrder)}',
              ),
              _MiniMetric(
                icon: Icons.timeline_outlined,
                text:
                    '${coupon.usedCount}/${coupon.usageLimit == 0 ? '∞' : coupon.usageLimit}',
              ),
              if (coupon.endAt != null)
                _MiniMetric(
                  icon: Icons.event_outlined,
                  text: 'Đến ${Formatters.date(coupon.endAt!)}',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Sửa mã',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: coupon.isActive ? 'Tắt mã' : 'Bật mã',
                onPressed: onToggleActive,
                icon: Icon(
                  coupon.isActive
                      ? Icons.toggle_on_outlined
                      : Icons.toggle_off_outlined,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  const _ProductFormSheet({this.product});

  final Product? product;

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;
  String _categoryId = '';
  bool _isFeatured = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _priceController = TextEditingController(
      text: product == null || product.minPrice == 0
          ? ''
          : product.minPrice.toString(),
    );
    _stockController = TextEditingController(
      text: product == null ? '' : product.totalStock.toString(),
    );
    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _categoryId = product?.categoryId ?? '';
    _isFeatured = product?.isFeatured ?? false;
    _isActive = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final isSaving = context.watch<ProductProvider>().isAdminLoading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHeader(
                title:
                    widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) => _required(value, 'Nhập tên sản phẩm'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Thương hiệu',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 10),
              if (categories.isEmpty)
                TextFormField(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Mã danh mục',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  onChanged: (value) => _categoryId = value,
                  validator: (value) => _required(value, 'Nhập mã danh mục'),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue:
                      categories.any((category) => category.id == _categoryId)
                          ? _categoryId
                          : null,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _categoryId = value ?? '';
                  }),
                  validator: (value) => _required(value, 'Chọn danh mục'),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giá',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      validator: (value) =>
                          _positiveNumber(value, 'Nhập giá hợp lệ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tồn kho',
                        prefixIcon: Icon(Icons.inventory_outlined),
                      ),
                      validator: (value) =>
                          _nonNegativeNumber(value, 'Nhập tồn kho hợp lệ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Ảnh sản phẩm',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              SwitchListTile(
                value: _isFeatured,
                contentPadding: EdgeInsets.zero,
                title: const Text('Sản phẩm nổi bật'),
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              SwitchListTile(
                value: _isActive,
                contentPadding: EdgeInsets.zero,
                title: const Text('Đang bán'),
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: isSaving ? null : _submit,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Lưu sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final categories = context.read<CategoryProvider>().categories;
    final product = widget.product;
    final name = _nameController.text.trim();
    final categoryId = _categoryId.trim().isNotEmpty
        ? _categoryId.trim()
        : categories.isEmpty
            ? ''
            : categories.first.id;
    final imageUrl = _imageController.text.trim().isNotEmpty
        ? _imageController.text.trim()
        : 'https://picsum.photos/seed/${_slugify(name)}/800/800';

    final value = Product(
      id: product?.id ?? '',
      name: name,
      brand: _brandController.text.trim(),
      categoryId: categoryId,
      description: _descriptionController.text.trim(),
      imageUrl: imageUrl,
      images: [imageUrl],
      minPrice: _parseInt(_priceController.text),
      maxPrice: _parseInt(_priceController.text),
      totalStock: _parseInt(_stockController.text),
      rating: product?.rating ?? 0,
      reviewCount: product?.reviewCount ?? 0,
      isFeatured: _isFeatured,
      isHotDeal: product?.isHotDeal ?? false,
      salePrice: product?.salePrice,
      dealStartAt: product?.dealStartAt,
      dealEndAt: product?.dealEndAt,
      dealStock: product?.dealStock,
      dealSold: product?.dealSold ?? 0,
      isActive: _isActive,
      createdAt: product?.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await context.read<ProductProvider>().saveProduct(value);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    _showSnack(
      context,
      context.read<ProductProvider>().adminError ?? 'Không lưu được sản phẩm',
    );
  }
}

class _CouponFormSheet extends StatefulWidget {
  const _CouponFormSheet({this.coupon});

  final CouponModel? coupon;

  @override
  State<_CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends State<_CouponFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _valueController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _maxDiscountController;
  late final TextEditingController _usageLimitController;
  late final TextEditingController _startAtController;
  late final TextEditingController _endAtController;
  String _type = CouponModel.typePercent;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final coupon = widget.coupon;
    _codeController = TextEditingController(text: coupon?.code ?? '');
    _valueController = TextEditingController(
      text: coupon == null ? '' : coupon.value.toString(),
    );
    _minOrderController = TextEditingController(
      text: coupon == null ? '' : coupon.minOrder.toString(),
    );
    _maxDiscountController = TextEditingController(
      text: coupon == null ? '' : coupon.maxDiscount.toString(),
    );
    _usageLimitController = TextEditingController(
      text: coupon == null ? '' : coupon.usageLimit.toString(),
    );
    _startAtController =
        TextEditingController(text: _dateInput(coupon?.startAt));
    _endAtController = TextEditingController(text: _dateInput(coupon?.endAt));
    _type = coupon?.type ?? CouponModel.typePercent;
    _isActive = coupon?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CouponProvider>().isAdminLoading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHeader(
                title: widget.coupon == null
                    ? 'Thêm mã giảm giá'
                    : 'Sửa mã giảm giá',
                icon: Icons.local_offer_outlined,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _codeController,
                enabled: widget.coupon == null,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: (value) => _required(value, 'Nhập mã giảm giá'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Loại giảm',
                  prefixIcon: Icon(Icons.percent_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: CouponModel.typePercent,
                    child: Text('Phần trăm'),
                  ),
                  DropdownMenuItem(
                    value: CouponModel.typeFixed,
                    child: Text('Số tiền'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _type = value ?? CouponModel.typePercent),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _type == CouponModel.typePercent
                      ? 'Giá trị %'
                      : 'Số tiền',
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
                validator: (value) =>
                    _positiveNumber(value, 'Nhập giá trị hợp lệ'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minOrderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Đơn tối thiểu',
                        prefixIcon: Icon(Icons.shopping_cart_outlined),
                      ),
                      validator: (value) =>
                          _nonNegativeNumber(value, 'Nhập giá trị hợp lệ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _maxDiscountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giảm tối đa',
                        prefixIcon: Icon(Icons.price_check_outlined),
                      ),
                      validator: (value) =>
                          _nonNegativeNumber(value, 'Nhập giá trị hợp lệ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usageLimitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượt dùng',
                  prefixIcon: Icon(Icons.timeline_outlined),
                ),
                validator: (value) =>
                    _nonNegativeNumber(value, 'Nhập số lượt hợp lệ'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startAtController,
                      decoration: const InputDecoration(
                        labelText: 'Bắt đầu',
                        hintText: 'yyyy-MM-dd',
                        prefixIcon: Icon(Icons.event_available_outlined),
                      ),
                      validator: _dateValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _endAtController,
                      decoration: const InputDecoration(
                        labelText: 'Kết thúc',
                        hintText: 'yyyy-MM-dd',
                        prefixIcon: Icon(Icons.event_busy_outlined),
                      ),
                      validator: _dateValidator,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _isActive,
                contentPadding: EdgeInsets.zero,
                title: const Text('Đang bật'),
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: isSaving ? null : _submit,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Lưu mã giảm giá'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final coupon = widget.coupon;
    final value = CouponModel(
      id: coupon?.id ?? '',
      code: CouponModel.normalizeCode(_codeController.text),
      type: _type,
      value: _parseInt(_valueController.text),
      minOrder: _parseInt(_minOrderController.text),
      maxDiscount: _parseInt(_maxDiscountController.text),
      usageLimit: _parseInt(_usageLimitController.text),
      usedCount: coupon?.usedCount ?? 0,
      startAt: _parseDate(_startAtController.text),
      endAt: _parseDate(_endAtController.text),
      isActive: _isActive,
      createdAt: coupon?.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await context.read<CouponProvider>().saveCoupon(value);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    _showSnack(
      context,
      context.read<CouponProvider>().adminError ?? 'Không lưu được mã giảm giá',
    );
  }

  String? _dateValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _parseDate(text) == null ? 'Nhập yyyy-MM-dd' : null;
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppTheme.grey),
              ),
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, maxWidth: 128),
            child: action,
          ),
        ],
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Đóng',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: child,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(fontSize: 12, color: AppTheme.grey),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.grey),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? const Icon(Icons.image_outlined, color: AppTheme.grey)
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.image_outlined, color: AppTheme.grey),
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.grey),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.grey),
          ),
        ],
      ),
    );
  }
}

String? _required(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

String? _positiveNumber(String? value, String message) {
  return _parseInt(value ?? '') <= 0 ? message : null;
}

String? _nonNegativeNumber(String? value, String message) {
  return _parseInt(value ?? '') < 0 ? message : null;
}

int _parseInt(String value) {
  final normalized = value.replaceAll(RegExp(r'[^\d-]'), '');
  return int.tryParse(normalized) ?? 0;
}

String _moneyInput(int amount) {
  final text = amount.toString();
  final formatted = text.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '$formatted\u0111';
}

DateTime? _parseDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _dateInput(DateTime? value) {
  if (value == null) return '';
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _slugify(String value) {
  final slug = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : slug;
}

String _orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Chờ xác nhận';
    case OrderStatus.confirmed:
      return 'Đã xác nhận';
    case OrderStatus.shipping:
      return 'Đang giao';
    case OrderStatus.completed:
      return 'Hoàn thành';
    case OrderStatus.cancelled:
      return 'Đã hủy';
  }
}

String _couponDescription(CouponModel coupon) {
  final discount = coupon.isPercent
      ? 'Giảm ${coupon.value}%'
      : 'Giảm ${Formatters.currency(coupon.value)}';
  if (coupon.maxDiscount > 0 && coupon.isPercent) {
    return '$discount, tối đa ${Formatters.currency(coupon.maxDiscount)}';
  }
  return discount;
}

String _initials(UserModel user) {
  final source = user.fullName.trim().isEmpty ? user.email : user.fullName;
  final parts = source.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return _firstRune(parts.first).toUpperCase();
  return '${_firstRune(parts.first)}${_firstRune(parts.last)}'.toUpperCase();
}

String _firstRune(String value) {
  if (value.isEmpty) return '?';
  return String.fromCharCode(value.runes.first);
}

Future<bool> _confirmAction(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
  return result ?? false;
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
