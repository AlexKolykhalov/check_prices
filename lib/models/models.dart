import 'package:intl/intl.dart';

class Product {
  final String title;
  final String subtitle;
  final String url;
  final String imageUrl;
  final String brand;
  final String regularPrice;
  final List<CardPrice> cardPrice;
  final String logo;

  Product({
    this.title,
    this.subtitle,
    this.url,
    this.imageUrl,
    this.brand,
    this.regularPrice,
    this.cardPrice,
    this.logo,
  });

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

  /// Функция, которая создает List из
  /// результат запроса result к API магазина,
  /// параметр shop 'lenta' или 'metro'
  List<Product> mapProducts({result, shop}) {
    return result
        .map<Product>((element) =>
            Product.fromEntity(ProductEntity.fromJson(element, shop)))
        .toList();
  }
}

class ProductEntity {
  final String title;
  final String subtitle;
  final String url;
  final String imageUrl;
  final String brand;
  final String regularPrice;
  final List<CardPrice> cardPrice;
  final String logo;

  ProductEntity({
    this.title,
    this.subtitle,
    this.url,
    this.imageUrl,
    this.brand,
    this.regularPrice,
    this.cardPrice,
    this.logo,
  });

  static ProductEntity fromJson(Map<String, dynamic> json, String shop) {
    if (shop == 'lenta') {
      return ProductEntity(
        title: json['title'],
        subtitle: json['subTitle'],
        url: json['url'],
        imageUrl: json['imageUrl'],
        brand: json['brand'],
        regularPrice: _updatePrice(json['regularPrice']['value']),
        cardPrice: [
          CardPrice(
              price: 'с картой ' + _updatePrice(json['cardPrice']['value']))
        ],
        logo: 'assets/lenta_fav.png',
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
        regularPrice: _updatePrice(json['prices']['price']),
        cardPrice: (json['prices'].containsKey('levels'))
            ? _list(json['prices']['levels'],
                _updatePackingType(json['packing']['type']))
            : [],
        logo: 'assets/metro_fav.png',
      );
    } else {
      return ProductEntity(
        title: json['name'],
        subtitle: '',
        url: 'https://new.5ka.ru/special_offers/' + json['id'].toString(),
        imageUrl: '',
        brand: '',
        regularPrice: _updatePrice(json['current_prices']['price_promo__min']),
        cardPrice: [],
        logo: 'assets/5ka_fav.png',
      );
    }
  }
}

class CardPrice {
  final String price;

  CardPrice({this.price});

  static CardPrice fromEntity(CardPriceEntity entity) {
    return CardPrice(
      price: entity.price,
    );
  }
}

class CardPriceEntity {
  final String price;

  CardPriceEntity({this.price});

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

String _updatePrice(regularPrice) {
  return NumberFormat('#,##0.00').format(regularPrice.toDouble()) + ' руб.';
}

String _updatePackingType(packingType) {
  if (packingType == 'штука' || packingType == 'штуки') {
    return ' шт ';
  } else if (packingType == 'упаковка' || packingType == 'упаковок') {
    return ' уп ';
  } else if (packingType == 'кг') {
    return ' кг ';
  }
  return packingType;
}

List<CardPrice> _list(array, packingType) {
  return array
      .map<CardPrice>((element) =>
          CardPrice.fromEntity(CardPriceEntity.fromJson(element, packingType)))
      .toList();
}
