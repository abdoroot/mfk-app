class HistoryPlanData {
  int? id;
  int? plan_id;
  String? status;

  // Optional: Assuming similar optional properties as before

  HistoryPlanData({
    this.id,
    this.plan_id,
    this.status,
  });

  factory HistoryPlanData.fromJson(Map<String, dynamic> json) {
    return HistoryPlanData(
      id: json['id'],
      plan_id: json['plan_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['plan_id'] = this.plan_id;
    data['status'] = this.status;

    return data;
  }
}

class PlansData {
  int? id;
  dynamic providerId;
  String? title; // Previously name
  dynamic status;
  dynamic categoryId;
  dynamic subCategoryId;
  num? amount; // Previously price
  String? planType; // Previously type
  String? description;
  String? createdAt;
  String? updatedAt;

  // Optional: Assuming similar optional properties as before
  num? totalRating;
  num? totalReview;

  PlansData({
    this.id,
    this.providerId,
    this.title,
    this.status,
    this.categoryId,
    this.subCategoryId,
    this.amount,
    this.planType,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.totalRating,
    this.totalReview,
  });

  factory PlansData.fromJson(Map<String, dynamic> json) {
    return PlansData(
      id: json['id'],
      providerId: json['provider_id'],
      title: json['title'],
      status: json['status'],
      categoryId: json['category_id'],
      subCategoryId: json['subcategory_id'],
      amount: json['amount'],
      planType: json['plan_type'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      totalRating: json['total_rating'],
      totalReview: json['total_review'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['provider_id'] = this.providerId;
    data['title'] = this.title;
    data['status'] = this.status;
    data['category_id'] = this.categoryId;
    data['subcategory_id'] = this.subCategoryId;
    data['amount'] = this.amount;
    data['plan_type'] = this.planType;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['total_rating'] = this.totalRating;
    data['total_review'] = this.totalReview;
    return data;
  }
}
