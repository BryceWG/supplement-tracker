import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supplement_tracker/src/controllers/supplements_controller.dart';
import 'package:supplement_tracker/src/models/supplement.dart';
import 'package:supplement_tracker/src/services/supplements_store.dart';

void main() {
  test('Supplement JSON preserves new fields', () {
    final s = Supplement(
      id: 'x',
      name: 'Test',
      specification: 'Spec',
      dailyDosage: 1,
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
    );

    final encoded = Supplement.encodeList([s]);
    final decoded = Supplement.decodeList(encoded).single;
    expect(decoded.startUseDate, '2026-03-02');
    expect(decoded.purchaseUrl, 'https://example.com/item');
    expect(decoded.skippedDates, ['2026-03-03']);
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

    expect(s.remainingDaysAt(DateTime(2026, 3, 1)), 5);
    expect(s.remainingDaysAt(DateTime(2026, 3, 3)), 3);
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 3)), 6);
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

    expect(s.remainingDaysAt(DateTime(2026, 3, 1)), 59);
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 1)), 118);
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

    // On 3/3, two days have passed since 3/1, but 3/2 was skipped, so only 1 day is consumed.
    expect(s.estimatedRemainingQuantityAt(DateTime(2026, 3, 3)), 8);
    expect(s.remainingDaysAt(DateTime(2026, 3, 3)), 4);
  });

  test('Controller postponeStartUseOneDay skips today', () async {
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
    expect(skipped!.skippedDates, contains('2026-03-01'));
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

    final updated = await controller.replenishQuantity(id, addQuantity: 5);
    expect(updated, isNotNull);
    expect(updated!.totalQuantity, 15);
    expect(updated.remainingQuantity, 15);
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
}

