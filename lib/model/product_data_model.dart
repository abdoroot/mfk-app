class ProductModel {
  final int id;
  final String name;
  final String categoryId;
  final String subcategoryId;
  final String providerId;
  final num price;
  final String priceFormat;
  final String? discount;
  final String status;
  final String description;
  String isFeatured;
  final String providerName;
  final String providerImage;
  final String categoryName;
  final String subcategoryName;
  final List<String> attachments;
  final List<Attachment> attachmentsArray;
  final bool attachmentExtension;
  final String? deletedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    required this.providerId,
    required this.price,
    required this.priceFormat,
    this.discount,
    required this.status,
    required this.description,
    required this.isFeatured,
    required this.providerName,
    required this.providerImage,
    required this.categoryName,
    required this.subcategoryName,
    required this.attachments,
    required this.attachmentsArray,
    required this.attachmentExtension,
    this.deletedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryId: json['category_id'] ?? '',
      subcategoryId: json['subcategory_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      price: num.parse(json['price'].toString()),
      priceFormat: json['price_format'] ?? '',
      discount: json['discount'],
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      isFeatured: json['is_featured'] ?? '',
      providerName: json['provider_name'] ?? '',
      providerImage: json['provider_image'] ?? '',
      categoryName: json['category_name'] ?? '',
      subcategoryName: json['subcategory_name'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      attachmentsArray: (json['attachments_array'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e))
              .toList() ??
          [],
      attachmentExtension: json['attachment_extension'] ?? false,
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'provider_id': providerId,
      'price': price,
      'price_format': priceFormat,
      'discount': discount,
      'status': status,
      'description': description,
      'is_featured': isFeatured,
      'provider_name': providerName,
      'provider_image': providerImage,
      'category_name': categoryName,
      'subcategory_name': subcategoryName,
      'attachments': attachments,
      'attachments_array': attachmentsArray.map((e) => e.toJson()).toList(),
      'attachment_extension': attachmentExtension,
      'deleted_at': deletedAt,
    };
  }
}

class Attachment {
  int? id;
  String? url;

  Attachment({this.id, this.url});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}
