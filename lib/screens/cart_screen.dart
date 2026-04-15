import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/translate_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/custom_modals.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final t = context.watch<TranslateProvider>().t;


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t('shopping_cart'),style: tt.titleLarge?.copyWith(color: cs.onSurface)),
        backgroundColor: cs.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: cs.onSurface),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: cs.surface,
                        title: Text(t('clear_cart'), style: tt.titleMedium?.copyWith(color: cs.onSurface)),
                        content: Text(
                          t('are_you_sure'),
                          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(t('txt_cancel'), style: tt.labelLarge?.copyWith(color: cs.primary)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.error,
                              foregroundColor: cs.onError,
                            ),
                            child: Text(t('txt_clear_all')),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    t('txt_clear_all'),
                    style: tt.labelLarge?.copyWith(color: cs.error, fontWeight: FontWeight.w600),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t('txt_your_cart_is_empty'),
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('txt_add_some_products'),
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      elevation: 0,
                      disabledBackgroundColor: cs.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(t('txt_continue_shopping')),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Header
              Container(
                width: double.infinity,
                color: cs.surface,
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${cart.itemCount} ${t('txt_items_in_cart')}',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return CartItemWidget(cartItem: cart.items[index]);
                  },
                ),
              ),

              // Checkout Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${t('txt_total')} (${cart.itemCount} ${t('items')}):',
                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CheckoutScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            t('txt_proceed_to_checkout'),
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
