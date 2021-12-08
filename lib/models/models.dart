import 'package:intl/intl.dart';

class Product {
  const Product({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.imageUrl,
    required this.brand,
    required this.regularPrice,
    required this.cardPrice,
    required this.logo,
  });

  final String title;
  final String subtitle;
  final String url;
  final String imageUrl;
  final String brand;
  final String regularPrice;
  final List<CardPrice> cardPrice;
  final String logo;

  static Product fromEntity(ProductEntity entity) {
    return Product(
      title: entity.title,
      subtitle: entity.subtitle,
      url: entity.url,
      imageUrl: entity.imageUrl,
      brand: entity.brand,
      regularPrice: entity.regularPrice,
      cardPrice: entity.cardPrice,
      logo: entity.logo,
    );
  }
}

class ProductEntity {
  ProductEntity({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.imageUrl,
    required this.brand,
    required this.regularPrice,
    required this.cardPrice,
    required this.logo,
  });

  final String title;
  final String subtitle;
  final String url;
  final String imageUrl;
  final String brand;
  final String regularPrice;
  final List<CardPrice> cardPrice;
  final String logo;

  static ProductEntity fromJson(Map<String, dynamic> json, String shop) {
    if (shop == 'lenta') {
      return ProductEntity(
        title: json['title'],
        subtitle: json['subTitle'],
        url: json['url'],
        imageUrl: json['imageUrl'],
        brand: json['brand'],
        regularPrice: updatePrice(json['regularPrice']['value']),
        cardPrice: [
          CardPrice(
              price: 'с картой ' + updatePrice(json['cardPrice']['value']))
        ],
        logo: 'lenta',
      );
    } else if (shop == 'metro') {
      return ProductEntity(
        title: json['name'],
        subtitle:
            json['packing']['size'].toString() + ' ' + json['packing']['type'],
        url: json['url'],
        imageUrl: json['images'][0],
        brand: (json['manufacturer'].isNotEmpty)
            ? json['manufacturer']['name']
            : '',
        regularPrice: updatePrice(json['prices']['price']),
        cardPrice: (json['prices'].containsKey('levels'))
            ? json['prices']['levels']
                .map<CardPrice>((element) => CardPrice.fromEntity(
                    CardPriceEntity.fromJson(
                        element, updatePackingType(json['packing']['type']))))
                .toList()
            : [],
        logo: 'metro',
      );
    } else if (shop == '5ka') {
      return ProductEntity(
        title: json['name'],
        subtitle: '',
        url: 'https://new.5ka.ru/special_offers/' + json['id'].toString(),
        imageUrl: '',
        brand: '',
        regularPrice: updatePrice(json['current_prices']['price_promo__min']),
        cardPrice: [],
        logo: '5ka',
      );
    } else {
      return ProductEntity(
        title: json['name'],
        subtitle: '1 штука',
        url: 'https://www.auchan.ru/product/' + json['code'],
        imageUrl: '',
        brand: json['brandName'],
        regularPrice: updatePrice(json['price']['value']),
        cardPrice: [],
        logo: 'auchan',
      );
    }
  }
}

class CardPrice {
  CardPrice({required this.price});

  final String price;

  static CardPrice fromEntity(CardPriceEntity entity) {
    return CardPrice(
      price: entity.price,
    );
  }
}

class CardPriceEntity {
  CardPriceEntity({required this.price});

  final String price;

  static fromJson(Map<String, dynamic> json, String packingType) {
    return CardPriceEntity(
      price: 'от ' +
          NumberFormat('##0.##').format(json['count'].toDouble()) +
          packingType +
          NumberFormat('#,##0.00').format(json['price'].toDouble()) +
          ' руб.',
    );
  }
}

String updatePrice(double regularPrice) {
  return NumberFormat('#,##0.00').format(regularPrice.toDouble()) + ' руб.';
}

String updatePackingType(String packingType) {
  if (packingType == 'штука' || packingType == 'штуки') {
    return ' шт ';
  } else if (packingType == 'упаковка' || packingType == 'упаковок') {
    return ' уп ';
  } else if (packingType == 'кг') {
    return ' кг ';
  }
  return packingType;
}

// List<CardPrice> list(array, packingType) {
//   return array
//       .map<CardPrice>((element) =>
//           CardPrice.fromEntity(CardPriceEntity.fromJson(element, packingType)))
//       .toList();
// }
