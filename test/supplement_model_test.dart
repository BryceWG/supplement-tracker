import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supplement_tracker/src/controllers/supplements_controller.dart';
import 'package:supplement_tracker/src/models/supplement.dart';
import 'package:supplement_tracker/src/models/supplement_stock.dart';
import 'package:supplement_tracker/src/services/supplements_store.dart';

void main() {
  test('Supplement JSON preserves new fields', () {
    final s = Supplement(
      id: 'x',
      name: 'Test',
      specification: 'Spec',
      dailyDosage: 3,
      dosageUnit: '粒',
      price: 10,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-02',
      purchaseUrl: 'https://example.com/item',
      totalQuantity: 10,
      remainingQuantity: 10,
      category: '其他',
      colorHex: '#000000',
      skippedDates: const ['2026-03-03'],
      dosageChanges: const [
        DosageChange(effectiveDate: '2026-03-02', dailyDosage: 1),
        DosageChange(effectiveDate: '2026-03-03', dailyDosage: 3),
      ],
    );

    final encoded = Supplement.encodeList([s]);
    final decoded = Supplement.decodeList(encoded).single;
    expect(decoded.startUseDate, '2026-03-02');
    expect(decoded.purchaseUrl, 'https://example.com/item');
    expect(decoded.skippedDates, ['2026-03-03']);
    expect(decoded.dosageChanges.length, 2);
    expect(decoded.dosageChanges.first.effectiveDate, '2026-03-02');
    expect(decoded.dosageChanges.first.dailyDosage, 1);
  });

  test('Remaining days follows start date', () {
    final s = Supplement(
      id: 'x',
      name: 'Test',
      specification: 'Spec',
      dailyDosage: 2,
      dosageUnit: '粒',
      price: 10,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      totalQuantity: 10,
      remainingQuantity: 10,
      category: '其他',
      colorHex: '#000000',
    );

    expect(s.remainingDaysAt(DateTime(2026, 3, 1)), 4);
    expect(s.remainingDaysAt(DateTime(2026, 3, 3)), 2);
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 3)), 4);
  });

  test('Remaining uses totalQuantity as baseline', () {
    final s = Supplement(
      id: 'x',
      name: 'Fish Oil',
      specification: '1000mg, 120粒',
      dailyDosage: 2,
      dosageUnit: '粒',
      price: 168,
      purchaseDate: '2024-02-01',
      startUseDate: '2026-02-28',
      totalQuantity: 120,
      remainingQuantity: 45, // legacy/sample value; should not shrink the estimate
      category: '脂肪酸',
      colorHex: '#000000',
    );

    expect(s.remainingDaysAt(DateTime(2026, 3, 1)), 58);
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 1)), 116);
  });

  test('Skipping a day delays consumption', () {
    final s = Supplement(
      id: 'x',
      name: 'Test',
      specification: 'Spec',
      dailyDosage: 2,
      dosageUnit: '粒',
      price: 10,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      totalQuantity: 10,
      remainingQuantity: 10,
      category: '其他',
      colorHex: '#000000',
      skippedDates: const ['2026-03-02'],
    );

    // On 3/3, 3/2 was skipped, so only 3/1 and 3/3 are consumed.
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 3)), 6);
    expect(s.remainingDaysAt(DateTime(2026, 3, 3)), 3);
  });

  test('Controller postponeStartUseOneDay moves start date when not started', () async {
    SharedPreferences.setMockInitialValues({});

    final controller = SupplementsController(store: SupplementsStore(), defaultProfileName: 'Me');
    await controller.init();

    const id = 'postpone-test';
    await controller.upsert(
      Supplement(
        id: id,
        name: 'Test',
        specification: 'Spec',
        dailyDosage: 1,
        dosageUnit: '粒',
        price: 10,
        purchaseDate: '2026-03-01',
        totalQuantity: 10,
        remainingQuantity: 10,
        category: '其他',
        colorHex: '#000000',
      ),
    );

    final skipped = await controller.postponeStartUseOneDay(
      id,
      today: DateTime(2026, 3, 1),
    );
    expect(skipped, isNotNull);
    expect(skipped!.startUseDate, '2026-03-02');
  });

  test('Changing daily dosage does not affect past consumption', () {
    final s = Supplement(
      id: 'x',
      name: 'Test',
      specification: 'Spec',
      dailyDosage: 3, // current dosage
      dosageUnit: '粒',
      price: 10,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      totalQuantity: 100,
      remainingQuantity: 100,
      category: '其他',
      colorHex: '#000000',
      dosageChanges: const [
        DosageChange(effectiveDate: '2026-03-01', dailyDosage: 2),
        DosageChange(effectiveDate: '2026-03-11', dailyDosage: 3),
      ],
    );

    expect(s.dailyDosageOn(DateTime(2026, 3, 10)), 2);
    expect(s.dailyDosageOn(DateTime(2026, 3, 11)), 3);
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 10)), 80);
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 11)), 77);
  });

  test('Controller replenishQuantity increases totals', () async {
    SharedPreferences.setMockInitialValues({});

    final controller = SupplementsController(store: SupplementsStore(), defaultProfileName: 'Me');
    await controller.init();

    const id = 'replenish-test';
    await controller.upsert(
      Supplement(
        id: id,
        name: 'Test',
        specification: 'Spec',
        dailyDosage: 1,
        dosageUnit: '粒',
        price: 10,
        purchaseDate: '2026-03-01',
        startUseDate: '2026-03-01',
        totalQuantity: 10,
        remainingQuantity: 10,
        category: '其他',
        colorHex: '#000000',
      ),
    );

    final updated = await controller.replenishQuantity(
      id,
      addQuantity: 5,
      today: DateTime(2026, 3, 2),
    );
    expect(updated, isNotNull);
    expect(updated!.stockChanges, isNotEmpty);
    expect(updated.totalQuantityAt(DateTime(2026, 3, 2)), 15);
  });

  test('Daily cost on a date respects start/skip/stock', () {
    final s = Supplement(
      id: 'x',
      name: 'Test',
      specification: 'Spec',
      dailyDosage: 1,
      dosageUnit: '粒',
      price: 10,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-02',
      totalQuantity: 2,
      remainingQuantity: 2,
      category: '其他',
      colorHex: '#000000',
      skippedDates: const ['2026-03-02'],
    );

    // Before start date: not consuming.
    expect(s.dailyCostOn(DateTime(2026, 3, 1)), 0);
    // Start day is skipped: still not consuming.
    expect(s.dailyCostOn(DateTime(2026, 3, 2)), 0);
    // Next day: consuming and has stock.
    expect(s.dailyCostOn(DateTime(2026, 3, 3)), 5);
    // Out of stock after consuming 2 days (3/3 and 3/4).
    expect(s.dailyCostOn(DateTime(2026, 3, 5)), 0);
  });

  test('Controller daily/monthly totals follow per-day consumption', () async {
    SharedPreferences.setMockInitialValues({});

    final controller = SupplementsController(store: SupplementsStore(), defaultProfileName: 'Me');
    await controller.init();

    await controller.upsert(
      Supplement(
        id: 'a',
        name: 'A',
        specification: 'Spec',
        dailyDosage: 1,
        dosageUnit: '粒',
        price: 10,
        purchaseDate: '2026-03-01',
        startUseDate: '2026-03-01',
        totalQuantity: 10,
        remainingQuantity: 10,
        category: '其他',
        colorHex: '#000000',
      ),
    );

    await controller.upsert(
      Supplement(
        id: 'b',
        name: 'B',
        specification: 'Spec',
        dailyDosage: 1,
        dosageUnit: '粒',
        price: 20,
        purchaseDate: '2026-03-01',
        startUseDate: '2026-03-02',
        totalQuantity: 10,
        remainingQuantity: 10,
        category: '其他',
        colorHex: '#000000',
      ),
    );

    await controller.upsert(
      Supplement(
        id: 'c',
        name: 'C',
        specification: 'Spec',
        dailyDosage: 1,
        dosageUnit: '粒',
        price: 30,
        purchaseDate: '2026-03-01',
        startUseDate: '2026-03-01',
        totalQuantity: 10,
        remainingQuantity: 10,
        category: '其他',
        colorHex: '#000000',
        skippedDates: const ['2026-03-01'],
      ),
    );

    final today = DateTime(2026, 3, 1);

    expect(controller.dailyCostTotalAt(today), 1);
    expect(controller.monthlyCostTotalFrom(today, days: 3), 13);
  });

  test('Shared stock aggregates depletion across usages', () {
    const stockId = 'stock-1';
    final stock = SupplementStock(
      id: stockId,
      name: 'D3',
      specification: '2000IU',
      dosageUnit: '粒',
      price: 30,
      purchaseDate: '2026-03-01',
      totalQuantity: 30,
      category: '维生素',
      colorHex: '#000000',
    );

    final u1 = Supplement(
      id: 'u1',
      name: 'D3',
      specification: '2000IU',
      dailyDosage: 2,
      dosageUnit: '粒',
      price: 30,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      stockId: stockId,
      totalQuantity: 30,
      remainingQuantity: 30,
      category: '维生素',
      colorHex: '#000000',
    );

    final u2 = Supplement(
      id: 'u2',
      name: 'D3',
      specification: '2000IU',
      dailyDosage: 1,
      dosageUnit: '粒',
      price: 30,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      stockId: stockId,
      totalQuantity: 30,
      remainingQuantity: 30,
      category: '维生素',
      colorHex: '#000000',
    );

    final stats = SharedStockStats.compute(
      stock: stock,
      usages: [u1, u2],
      today: DateTime(2026, 3, 1),
    );

    expect(stats.totalQuantity, 30);
    expect(stats.remainingQuantity, 27);
    expect(stats.remainingDays, 9);
    expect(stats.remainingPercent, closeTo(0.9, 1e-12));
  });

  test('Shared stock respects skip days', () {
    const stockId = 'stock-2';
    final stock = SupplementStock(
      id: stockId,
      name: 'D3',
      specification: '2000IU',
      dosageUnit: '粒',
      price: 30,
      purchaseDate: '2026-03-01',
      totalQuantity: 30,
      category: '维生素',
      colorHex: '#000000',
    );

    final u1 = Supplement(
      id: 'u1',
      name: 'D3',
      specification: '2000IU',
      dailyDosage: 2,
      dosageUnit: '粒',
      price: 30,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      stockId: stockId,
      totalQuantity: 30,
      remainingQuantity: 30,
      category: '维生素',
      colorHex: '#000000',
    );

    final u2 = Supplement(
      id: 'u2',
      name: 'D3',
      specification: '2000IU',
      dailyDosage: 1,
      dosageUnit: '粒',
      price: 30,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      stockId: stockId,
      totalQuantity: 30,
      remainingQuantity: 30,
      category: '维生素',
      colorHex: '#000000',
      skippedDates: const ['2026-03-02'],
    );

    final stats = SharedStockStats.compute(
      stock: stock,
      usages: [u1, u2],
      today: DateTime(2026, 3, 3),
    );

    expect(stats.remainingQuantity, 22);
    expect(stats.remainingDays, 7);
  });

  test('Shared stock does not retroactively apply dosage changes', () {
    const stockId = 'stock-3';
    final stock = SupplementStock(
      id: stockId,
      name: 'D3',
      specification: '2000IU',
      dosageUnit: '粒',
      price: 100,
      purchaseDate: '2026-03-01',
      totalQuantity: 100,
      category: '维生素',
      colorHex: '#000000',
    );

    final u1 = Supplement(
      id: 'u1',
      name: 'D3',
      specification: '2000IU',
      dailyDosage: 3, // current dosage
      dosageUnit: '粒',
      price: 100,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      stockId: stockId,
      totalQuantity: 100,
      remainingQuantity: 100,
      category: '维生素',
      colorHex: '#000000',
      dosageChanges: const [
        DosageChange(effectiveDate: '2026-03-01', dailyDosage: 2),
        DosageChange(effectiveDate: '2026-03-11', dailyDosage: 3),
      ],
    );

    final u2 = Supplement(
      id: 'u2',
      name: 'D3',
      specification: '2000IU',
      dailyDosage: 1,
      dosageUnit: '粒',
      price: 100,
      purchaseDate: '2026-03-01',
      startUseDate: '2026-03-01',
      stockId: stockId,
      totalQuantity: 100,
      remainingQuantity: 100,
      category: '维生素',
      colorHex: '#000000',
    );

    final stats = SharedStockStats.compute(
      stock: stock,
      usages: [u1, u2],
      today: DateTime(2026, 3, 11),
    );

    expect(stats.remainingQuantity, 66);
  });
}

