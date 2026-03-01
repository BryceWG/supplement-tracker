import '../models/supplement.dart';
import '../util/colors.dart';

class SampleData {
  static List<Supplement> supplements() {
    return [
      Supplement(
        id: '1',
        name: '维生素D3',
        specification: '2000IU, 180粒',
        dailyDosage: 1,
        dosageUnit: '粒',
        price: 128,
        purchaseDate: '2024-01-15',
        totalQuantity: 180,
        remainingQuantity: 120,
        category: '维生素',
        colorHex: CategoryColors.toHex(CategoryColors.vitamins),
      ),
      Supplement(
        id: '2',
        name: '鱼油 Omega-3',
        specification: '1000mg, 120粒',
        dailyDosage: 2,
        dosageUnit: '粒',
        price: 168,
        purchaseDate: '2024-02-01',
        totalQuantity: 120,
        remainingQuantity: 45,
        category: '脂肪酸',
        colorHex: CategoryColors.toHex(CategoryColors.fattyAcids),
      ),
      Supplement(
        id: '3',
        name: '复合维生素B',
        specification: '100片',
        dailyDosage: 1,
        dosageUnit: '片',
        price: 68,
        purchaseDate: '2024-01-20',
        totalQuantity: 100,
        remainingQuantity: 78,
        category: '维生素',
        colorHex: CategoryColors.toHex(CategoryColors.probiotics),
      ),
      Supplement(
        id: '4',
        name: '镁元素片',
        specification: '200mg, 90片',
        dailyDosage: 1,
        dosageUnit: '片',
        price: 88,
        purchaseDate: '2024-02-10',
        totalQuantity: 90,
        remainingQuantity: 82,
        category: '矿物质',
        colorHex: CategoryColors.toHex(CategoryColors.minerals),
      ),
    ];
  }
}

