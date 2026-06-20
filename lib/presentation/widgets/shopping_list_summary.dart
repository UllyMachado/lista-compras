import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lista_compras/data/models/models.dart';
import '../../core/theme.dart';

class ShoppingListSummary extends StatelessWidget {
  final ShoppingList list;

  const ShoppingListSummary({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final items = list.items ?? [];
    final totalItems = items.length;
    final checkedItems = items.where((item) => item.isChecked ?? false).length;
    final pendingItems = totalItems - checkedItems;

    final double budget = list.budget ?? 0.0;

    // Total estimated value (all items in the list)
    final double totalEstimated = items.fold(
      0.0,
      (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)),
    );

    // Total checked value (items already purchased)
    final double totalChecked = items
        .where((item) => item.isChecked ?? false)
        .fold(
          0.0,
          (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)),
        );

    final double remainingBudget = budget - totalChecked;
    final double economy = budget - totalEstimated;

    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final percentageChecked = totalItems > 0 ? (checkedItems / totalItems) * 100 : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Indicator Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Resumo: ${list.name ?? "Sem Nome"}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Orçamento',
                    value: currencyFormatter.format(budget),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Estimado',
                    value: currencyFormatter.format(totalEstimated),
                    icon: Icons.receipt_long_outlined,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Comprado',
                    value: currencyFormatter.format(totalChecked),
                    icon: Icons.shopping_bag_outlined,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: economy >= 0 ? 'Economia Prevista' : 'Excedido',
                    value: currencyFormatter.format(economy.abs()),
                    icon: economy >= 0 ? Icons.trending_down : Icons.trending_up,
                    color: economy >= 0 ? AppTheme.success : AppTheme.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Items breakdown & fl_chart Pie Chart
            const Text(
              'Progresso dos Itens',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            if (totalItems > 0)
              Row(
                children: [
                  // Pie Chart
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 38,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: AppTheme.success,
                                value: checkedItems.toDouble(),
                                title: '',
                                radius: 18,
                              ),
                              PieChartSectionData(
                                color: AppTheme.secondary.withOpacity(0.3),
                                value: pendingItems.toDouble(),
                                title: '',
                                radius: 18,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${percentageChecked.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'concluído',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          color: AppTheme.success,
                          label: 'Comprados',
                          count: '$checkedItems itens',
                        ),
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          color: AppTheme.secondary.withOpacity(0.5),
                          label: 'Pendentes',
                          count: '$pendingItems itens',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total da lista: $totalItems itens',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Nenhum item na lista para gerar gráficos.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Share and Close Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ShoppingListSummary.shareList(list),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('COMPARTILHAR'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white38),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('FECHAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String count,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void shareList(ShoppingList list) {
    final items = list.items ?? [];
    final double budget = list.budget ?? 0.0;
    
    final double totalEstimated = items.fold(
      0.0,
      (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)),
    );

    final double totalChecked = items
        .where((item) => item.isChecked ?? false)
        .fold(
          0.0,
          (sum, item) => sum + ((item.quantity ?? 1.0) * (item.price ?? 0.0)),
        );

    final double remainingBudget = budget - totalChecked;

    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final sb = StringBuffer();
    sb.writeln('🛒 LISTA DE COMPRAS: ${list.name ?? "Sem Nome"}');
    sb.writeln('───────────────────────────');
    sb.writeln('💰 Orçamento: ${currencyFormatter.format(budget)}');
    sb.writeln('📉 Estimativa Total: ${currencyFormatter.format(totalEstimated)}');
    sb.writeln('✅ Total Comprado: ${currencyFormatter.format(totalChecked)}');
    sb.writeln('💵 Saldo Restante: ${currencyFormatter.format(remainingBudget)}');
    sb.writeln('───────────────────────────\n');

    if (items.isEmpty) {
      sb.writeln('Nenhum item adicionado.');
    } else {
      sb.writeln('Itens:');
      for (final item in items) {
        final checkedBox = (item.isChecked ?? false) ? '[x]' : '[ ]';
        final qtyStr = item.quantity != null
            ? '${item.quantity!.toStringAsFixed(item.quantity!.truncateToDouble() == item.quantity ? 0 : 2)}${item.unit != null ? " ${item.unit!.value}" : ""}'
            : '';
        final priceStr = item.price != null && item.price! > 0
            ? ' - ${currencyFormatter.format(item.price)}'
            : '';
        final categoryStr = item.category?.name != null ? ' (Cat: ${item.category!.name})' : '';

        sb.writeln('$checkedBox $qtyStr ${item.description ?? ""}$priceStr$categoryStr');
      }
    }

    Share.share(sb.toString(), subject: 'Lista de Compras: ${list.name ?? "Sem Nome"}');
  }
}



