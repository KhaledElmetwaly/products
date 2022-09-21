import 'package:equatable/equatable.dart';

class Product extends Equatable {
  late String name;
  late String description;
  late num price;
  late String image;
  Product(
      {required this.name,
      required this.description,
      required this.price,
      required this.image});

  Product.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
  }

  @override
  // TODO: implement props
  List<Object?> get props => [name, description, price, image];
}
