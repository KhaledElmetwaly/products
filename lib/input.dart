class AddProductsInputData {
  String? name, description, price;

  AddProductsInputData({this.name, this.description, this.price});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "desc": description,
      "price": price,
    };
  }
}
