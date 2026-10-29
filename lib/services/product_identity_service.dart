import 'package:flutter/foundation.dart';

import '../models/access_control.dart';

typedef ProductIdentityKey = (RobinBusinessDivision, String);

@immutable
class ProductSpecification {
  final String model;
  final String stroke;
  final String motorDirection;
  final String sensorDirection;
  final Map<String, String> smartOrderOptions;
  const ProductSpecification(
      {this.model = '',
      this.stroke = '',
      this.motorDirection = '',
      this.sensorDirection = '',
      this.smartOrderOptions = const {}});

  Map<String, String> get fields => {
        '모델': model,
        'Stroke(mm)': stroke,
        '모터 방향': motorDirection,
        '센서 방향': sensorDirection,
        ...smartOrderOptions,
      };

  bool sameAs(ProductSpecification other) => mapEquals(fields, other.fields);
}

@immutable
class ProductIdentity {
  final String productCode;
  final String productNumber;
  final String drawingNumber;
  final ProductSpecification specification;
  final String source;
  final String reference;
  final bool needsReview;
  final int revision;
  final String author;
  final DateTime? savedAt;
  final List<String> history;

  const ProductIdentity(
      {this.productCode = '',
      this.productNumber = '',
      this.drawingNumber = '',
      this.specification = const ProductSpecification(),
      this.source = '직접 입력',
      this.reference = '',
      this.needsReview = false,
      this.revision = 0,
      this.author = '',
      this.savedAt,
      this.history = const []});

  String get status => needsReview
      ? '사양 변경 · 코드 재확인 필요'
      : productCode.isEmpty
          ? '생성 규칙 확인 필요'
          : '입력 코드 · 공식 검증 전';
}

/// Session-only prototype data. Neither API writes nor official ERP code issuance.
final productIdentities =
    ValueNotifier<Map<ProductIdentityKey, ProductIdentity>>({});
final proposalSpecifications =
    ValueNotifier<Map<ProductIdentityKey, ProductSpecification>>({});

ProductIdentity identityFor(ProductIdentityKey key) =>
    productIdentities.value[key] ?? const ProductIdentity();

void saveProductIdentity(ProductIdentityKey key, ProductIdentity draft,
    {required String author}) {
  final previous = identityFor(key);
  final specChanged = !previous.specification.sameAs(draft.specification);
  final changes = <String>[];
  final before = {
    '제품코드': previous.productCode,
    '제품번호': previous.productNumber,
    '도면번호': previous.drawingNumber,
    ...previous.specification.fields,
    '정보 출처': previous.source,
    '근거': previous.reference,
  };
  final after = {
    '제품코드': draft.productCode,
    '제품번호': draft.productNumber,
    '도면번호': draft.drawingNumber,
    ...draft.specification.fields,
    '정보 출처': draft.source,
    '근거': draft.reference,
  };
  for (final field in {...before.keys, ...after.keys}) {
    if (before[field] != after[field]) {
      changes.add(
          '$field: ${(before[field] ?? '').isEmpty ? '미입력' : before[field]} → ${(after[field] ?? '').isEmpty ? '미입력' : after[field]}');
    }
  }
  if (changes.isEmpty) return;
  final now = DateTime.now();
  productIdentities.value = {
    ...productIdentities.value,
    key: ProductIdentity(
      productCode: draft.productCode,
      productNumber: draft.productNumber,
      drawingNumber: draft.drawingNumber,
      specification: draft.specification,
      source: draft.source,
      reference: draft.reference,
      needsReview: previous.needsReview ||
          (previous.productCode.isNotEmpty && specChanged),
      revision: previous.revision + 1,
      author: author,
      savedAt: now,
      history: [
        ...previous.history,
        'Rev.${previous.revision + 1} · $author · ${now.toIso8601String()}\n${changes.join('\n')}'
      ],
    )
  };
}

void updateProposalSpecification(
    ProductIdentityKey key, String field, String value) {
  final old = proposalSpecifications.value[key] ?? const ProductSpecification();
  proposalSpecifications.value = {
    ...proposalSpecifications.value,
    key: ProductSpecification(
      model: field == 'model' ? value : old.model,
      stroke: field == 'stroke' ? value : old.stroke,
      motorDirection: field == 'motor' ? value : old.motorDirection,
      sensorDirection: field == 'sensor' ? value : old.sensorDirection,
      smartOrderOptions: old.smartOrderOptions,
    )
  };
}
