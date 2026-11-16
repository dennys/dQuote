// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $InstrumentsTable extends Instruments
    with TableInfo<$InstrumentsTable, Instrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TWD'),
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('america'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _inWidgetMeta = const VerificationMeta(
    'inWidget',
  );
  @override
  late final GeneratedColumn<bool> inWidget = GeneratedColumn<bool>(
    'in_widget',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_widget" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    name,
    alias,
    currency,
    market,
    sortOrder,
    inWidget,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Instrument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('in_widget')) {
      context.handle(
        _inWidgetMeta,
        inWidget.isAcceptableOrUnknown(data['in_widget']!, _inWidgetMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  Instrument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Instrument(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      inWidget: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_widget'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
    );
  }

  @override
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }
}

class Instrument extends DataClass implements Insertable<Instrument> {
  final String symbol;
  final String name;
  final String? alias;
  final String currency;
  final String market;
  final int sortOrder;
  final bool inWidget;
  final DateTime? addedAt;
  const Instrument({
    required this.symbol,
    required this.name,
    this.alias,
    required this.currency,
    required this.market,
    required this.sortOrder,
    required this.inWidget,
    this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || alias != null) {
      map['alias'] = Variable<String>(alias);
    }
    map['currency'] = Variable<String>(currency);
    map['market'] = Variable<String>(market);
    map['sort_order'] = Variable<int>(sortOrder);
    map['in_widget'] = Variable<bool>(inWidget);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      symbol: Value(symbol),
      name: Value(name),
      alias: alias == null && nullToAbsent
          ? const Value.absent()
          : Value(alias),
      currency: Value(currency),
      market: Value(market),
      sortOrder: Value(sortOrder),
      inWidget: Value(inWidget),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
    );
  }

  factory Instrument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Instrument(
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      alias: serializer.fromJson<String?>(json['alias']),
      currency: serializer.fromJson<String>(json['currency']),
      market: serializer.fromJson<String>(json['market']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      inWidget: serializer.fromJson<bool>(json['inWidget']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'alias': serializer.toJson<String?>(alias),
      'currency': serializer.toJson<String>(currency),
      'market': serializer.toJson<String>(market),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'inWidget': serializer.toJson<bool>(inWidget),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
    };
  }

  Instrument copyWith({
    String? symbol,
    String? name,
    Value<String?> alias = const Value.absent(),
    String? currency,
    String? market,
    int? sortOrder,
    bool? inWidget,
    Value<DateTime?> addedAt = const Value.absent(),
  }) => Instrument(
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    alias: alias.present ? alias.value : this.alias,
    currency: currency ?? this.currency,
    market: market ?? this.market,
    sortOrder: sortOrder ?? this.sortOrder,
    inWidget: inWidget ?? this.inWidget,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
  );
  Instrument copyWithCompanion(InstrumentsCompanion data) {
    return Instrument(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      alias: data.alias.present ? data.alias.value : this.alias,
      currency: data.currency.present ? data.currency.value : this.currency,
      market: data.market.present ? data.market.value : this.market,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      inWidget: data.inWidget.present ? data.inWidget.value : this.inWidget,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Instrument(')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('alias: $alias, ')
          ..write('currency: $currency, ')
          ..write('market: $market, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('inWidget: $inWidget, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    name,
    alias,
    currency,
    market,
    sortOrder,
    inWidget,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instrument &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.alias == this.alias &&
          other.currency == this.currency &&
          other.market == this.market &&
          other.sortOrder == this.sortOrder &&
          other.inWidget == this.inWidget &&
          other.addedAt == this.addedAt);
}

class InstrumentsCompanion extends UpdateCompanion<Instrument> {
  final Value<String> symbol;
  final Value<String> name;
  final Value<String?> alias;
  final Value<String> currency;
  final Value<String> market;
  final Value<int> sortOrder;
  final Value<bool> inWidget;
  final Value<DateTime?> addedAt;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.alias = const Value.absent(),
    this.currency = const Value.absent(),
    this.market = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.inWidget = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    required String symbol,
    this.name = const Value.absent(),
    this.alias = const Value.absent(),
    this.currency = const Value.absent(),
    this.market = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.inWidget = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol);
  static Insertable<Instrument> custom({
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? alias,
    Expression<String>? currency,
    Expression<String>? market,
    Expression<int>? sortOrder,
    Expression<bool>? inWidget,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (alias != null) 'alias': alias,
      if (currency != null) 'currency': currency,
      if (market != null) 'market': market,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (inWidget != null) 'in_widget': inWidget,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith({
    Value<String>? symbol,
    Value<String>? name,
    Value<String?>? alias,
    Value<String>? currency,
    Value<String>? market,
    Value<int>? sortOrder,
    Value<bool>? inWidget,
    Value<DateTime?>? addedAt,
    Value<int>? rowid,
  }) {
    return InstrumentsCompanion(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      currency: currency ?? this.currency,
      market: market ?? this.market,
      sortOrder: sortOrder ?? this.sortOrder,
      inWidget: inWidget ?? this.inWidget,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (inWidget.present) {
      map['in_widget'] = Variable<bool>(inWidget.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentsCompanion(')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('alias: $alias, ')
          ..write('currency: $currency, ')
          ..write('market: $market, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('inWidget: $inWidget, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTable extends Holdings with TableInfo<$HoldingsTable, Holding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('taiwan'),
  );
  static const VerificationMeta _ccyMeta = const VerificationMeta('ccy');
  @override
  late final GeneratedColumn<String> ccy = GeneratedColumn<String>(
    'ccy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TWD'),
  );
  static const VerificationMeta _sharesMeta = const VerificationMeta('shares');
  @override
  late final GeneratedColumn<double> shares = GeneratedColumn<double>(
    'shares',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costRateMeta = const VerificationMeta(
    'costRate',
  );
  @override
  late final GeneratedColumn<double> costRate = GeneratedColumn<double>(
    'cost_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buyDateMeta = const VerificationMeta(
    'buyDate',
  );
  @override
  late final GeneratedColumn<DateTime> buyDate = GeneratedColumn<DateTime>(
    'buy_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
    'broker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    market,
    ccy,
    shares,
    costPrice,
    costRate,
    buyDate,
    broker,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Holding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    }
    if (data.containsKey('ccy')) {
      context.handle(
        _ccyMeta,
        ccy.isAcceptableOrUnknown(data['ccy']!, _ccyMeta),
      );
    }
    if (data.containsKey('shares')) {
      context.handle(
        _sharesMeta,
        shares.isAcceptableOrUnknown(data['shares']!, _sharesMeta),
      );
    } else if (isInserting) {
      context.missing(_sharesMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_costPriceMeta);
    }
    if (data.containsKey('cost_rate')) {
      context.handle(
        _costRateMeta,
        costRate.isAcceptableOrUnknown(data['cost_rate']!, _costRateMeta),
      );
    }
    if (data.containsKey('buy_date')) {
      context.handle(
        _buyDateMeta,
        buyDate.isAcceptableOrUnknown(data['buy_date']!, _buyDateMeta),
      );
    }
    if (data.containsKey('broker')) {
      context.handle(
        _brokerMeta,
        broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Holding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      ccy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ccy'],
      )!,
      shares: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shares'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      costRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_rate'],
      ),
      buyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}buy_date'],
      ),
      broker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HoldingsTable createAlias(String alias) {
    return $HoldingsTable(attachedDatabase, alias);
  }
}

class Holding extends DataClass implements Insertable<Holding> {
  final int id;
  final String symbol;
  final String market;
  final String ccy;
  final double shares;
  final double costPrice;

  /// 買進時「1 ccy = ? 基礎貨幣」；null → 退回現匯率（匯兌損益記 0）。
  final double? costRate;
  final DateTime? buyDate;
  final String? broker;
  final String? note;
  final DateTime updatedAt;
  const Holding({
    required this.id,
    required this.symbol,
    required this.market,
    required this.ccy,
    required this.shares,
    required this.costPrice,
    this.costRate,
    this.buyDate,
    this.broker,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['ccy'] = Variable<String>(ccy);
    map['shares'] = Variable<double>(shares);
    map['cost_price'] = Variable<double>(costPrice);
    if (!nullToAbsent || costRate != null) {
      map['cost_rate'] = Variable<double>(costRate);
    }
    if (!nullToAbsent || buyDate != null) {
      map['buy_date'] = Variable<DateTime>(buyDate);
    }
    if (!nullToAbsent || broker != null) {
      map['broker'] = Variable<String>(broker);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HoldingsCompanion toCompanion(bool nullToAbsent) {
    return HoldingsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      market: Value(market),
      ccy: Value(ccy),
      shares: Value(shares),
      costPrice: Value(costPrice),
      costRate: costRate == null && nullToAbsent
          ? const Value.absent()
          : Value(costRate),
      buyDate: buyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(buyDate),
      broker: broker == null && nullToAbsent
          ? const Value.absent()
          : Value(broker),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory Holding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holding(
      id: serializer.fromJson<int>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      ccy: serializer.fromJson<String>(json['ccy']),
      shares: serializer.fromJson<double>(json['shares']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      costRate: serializer.fromJson<double?>(json['costRate']),
      buyDate: serializer.fromJson<DateTime?>(json['buyDate']),
      broker: serializer.fromJson<String?>(json['broker']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'ccy': serializer.toJson<String>(ccy),
      'shares': serializer.toJson<double>(shares),
      'costPrice': serializer.toJson<double>(costPrice),
      'costRate': serializer.toJson<double?>(costRate),
      'buyDate': serializer.toJson<DateTime?>(buyDate),
      'broker': serializer.toJson<String?>(broker),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Holding copyWith({
    int? id,
    String? symbol,
    String? market,
    String? ccy,
    double? shares,
    double? costPrice,
    Value<double?> costRate = const Value.absent(),
    Value<DateTime?> buyDate = const Value.absent(),
    Value<String?> broker = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => Holding(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    ccy: ccy ?? this.ccy,
    shares: shares ?? this.shares,
    costPrice: costPrice ?? this.costPrice,
    costRate: costRate.present ? costRate.value : this.costRate,
    buyDate: buyDate.present ? buyDate.value : this.buyDate,
    broker: broker.present ? broker.value : this.broker,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Holding copyWithCompanion(HoldingsCompanion data) {
    return Holding(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      ccy: data.ccy.present ? data.ccy.value : this.ccy,
      shares: data.shares.present ? data.shares.value : this.shares,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      costRate: data.costRate.present ? data.costRate.value : this.costRate,
      buyDate: data.buyDate.present ? data.buyDate.value : this.buyDate,
      broker: data.broker.present ? data.broker.value : this.broker,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holding(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('ccy: $ccy, ')
          ..write('shares: $shares, ')
          ..write('costPrice: $costPrice, ')
          ..write('costRate: $costRate, ')
          ..write('buyDate: $buyDate, ')
          ..write('broker: $broker, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    market,
    ccy,
    shares,
    costPrice,
    costRate,
    buyDate,
    broker,
    note,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holding &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.ccy == this.ccy &&
          other.shares == this.shares &&
          other.costPrice == this.costPrice &&
          other.costRate == this.costRate &&
          other.buyDate == this.buyDate &&
          other.broker == this.broker &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class HoldingsCompanion extends UpdateCompanion<Holding> {
  final Value<int> id;
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> ccy;
  final Value<double> shares;
  final Value<double> costPrice;
  final Value<double?> costRate;
  final Value<DateTime?> buyDate;
  final Value<String?> broker;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  const HoldingsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.ccy = const Value.absent(),
    this.shares = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.costRate = const Value.absent(),
    this.buyDate = const Value.absent(),
    this.broker = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HoldingsCompanion.insert({
    this.id = const Value.absent(),
    required String symbol,
    this.market = const Value.absent(),
    this.ccy = const Value.absent(),
    required double shares,
    required double costPrice,
    this.costRate = const Value.absent(),
    this.buyDate = const Value.absent(),
    this.broker = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime updatedAt,
  }) : symbol = Value(symbol),
       shares = Value(shares),
       costPrice = Value(costPrice),
       updatedAt = Value(updatedAt);
  static Insertable<Holding> custom({
    Expression<int>? id,
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? ccy,
    Expression<double>? shares,
    Expression<double>? costPrice,
    Expression<double>? costRate,
    Expression<DateTime>? buyDate,
    Expression<String>? broker,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (ccy != null) 'ccy': ccy,
      if (shares != null) 'shares': shares,
      if (costPrice != null) 'cost_price': costPrice,
      if (costRate != null) 'cost_rate': costRate,
      if (buyDate != null) 'buy_date': buyDate,
      if (broker != null) 'broker': broker,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HoldingsCompanion copyWith({
    Value<int>? id,
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? ccy,
    Value<double>? shares,
    Value<double>? costPrice,
    Value<double?>? costRate,
    Value<DateTime?>? buyDate,
    Value<String?>? broker,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
  }) {
    return HoldingsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      ccy: ccy ?? this.ccy,
      shares: shares ?? this.shares,
      costPrice: costPrice ?? this.costPrice,
      costRate: costRate ?? this.costRate,
      buyDate: buyDate ?? this.buyDate,
      broker: broker ?? this.broker,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (ccy.present) {
      map['ccy'] = Variable<String>(ccy.value);
    }
    if (shares.present) {
      map['shares'] = Variable<double>(shares.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (costRate.present) {
      map['cost_rate'] = Variable<double>(costRate.value);
    }
    if (buyDate.present) {
      map['buy_date'] = Variable<DateTime>(buyDate.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('ccy: $ccy, ')
          ..write('shares: $shares, ')
          ..write('costPrice: $costPrice, ')
          ..write('costRate: $costRate, ')
          ..write('buyDate: $buyDate, ')
          ..write('broker: $broker, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CashPositionsTable extends CashPositions
    with TableInfo<$CashPositionsTable, CashPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ccyMeta = const VerificationMeta('ccy');
  @override
  late final GeneratedColumn<String> ccy = GeneratedColumn<String>(
    'ccy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costRateMeta = const VerificationMeta(
    'costRate',
  );
  @override
  late final GeneratedColumn<double> costRate = GeneratedColumn<double>(
    'cost_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bank'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ccy,
    amount,
    costRate,
    kind,
    label,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashPosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ccy')) {
      context.handle(
        _ccyMeta,
        ccy.isAcceptableOrUnknown(data['ccy']!, _ccyMeta),
      );
    } else if (isInserting) {
      context.missing(_ccyMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('cost_rate')) {
      context.handle(
        _costRateMeta,
        costRate.isAcceptableOrUnknown(data['cost_rate']!, _costRateMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashPosition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ccy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ccy'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      costRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_rate'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CashPositionsTable createAlias(String alias) {
    return $CashPositionsTable(attachedDatabase, alias);
  }
}

class CashPosition extends DataClass implements Insertable<CashPosition> {
  final int id;
  final String ccy;
  final double amount;
  final double? costRate;
  final String kind;
  final String label;
  final String? note;
  final DateTime updatedAt;
  const CashPosition({
    required this.id,
    required this.ccy,
    required this.amount,
    this.costRate,
    required this.kind,
    required this.label,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ccy'] = Variable<String>(ccy);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || costRate != null) {
      map['cost_rate'] = Variable<double>(costRate);
    }
    map['kind'] = Variable<String>(kind);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CashPositionsCompanion toCompanion(bool nullToAbsent) {
    return CashPositionsCompanion(
      id: Value(id),
      ccy: Value(ccy),
      amount: Value(amount),
      costRate: costRate == null && nullToAbsent
          ? const Value.absent()
          : Value(costRate),
      kind: Value(kind),
      label: Value(label),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory CashPosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashPosition(
      id: serializer.fromJson<int>(json['id']),
      ccy: serializer.fromJson<String>(json['ccy']),
      amount: serializer.fromJson<double>(json['amount']),
      costRate: serializer.fromJson<double?>(json['costRate']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ccy': serializer.toJson<String>(ccy),
      'amount': serializer.toJson<double>(amount),
      'costRate': serializer.toJson<double?>(costRate),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String>(label),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CashPosition copyWith({
    int? id,
    String? ccy,
    double? amount,
    Value<double?> costRate = const Value.absent(),
    String? kind,
    String? label,
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => CashPosition(
    id: id ?? this.id,
    ccy: ccy ?? this.ccy,
    amount: amount ?? this.amount,
    costRate: costRate.present ? costRate.value : this.costRate,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CashPosition copyWithCompanion(CashPositionsCompanion data) {
    return CashPosition(
      id: data.id.present ? data.id.value : this.id,
      ccy: data.ccy.present ? data.ccy.value : this.ccy,
      amount: data.amount.present ? data.amount.value : this.amount,
      costRate: data.costRate.present ? data.costRate.value : this.costRate,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashPosition(')
          ..write('id: $id, ')
          ..write('ccy: $ccy, ')
          ..write('amount: $amount, ')
          ..write('costRate: $costRate, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ccy, amount, costRate, kind, label, note, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashPosition &&
          other.id == this.id &&
          other.ccy == this.ccy &&
          other.amount == this.amount &&
          other.costRate == this.costRate &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class CashPositionsCompanion extends UpdateCompanion<CashPosition> {
  final Value<int> id;
  final Value<String> ccy;
  final Value<double> amount;
  final Value<double?> costRate;
  final Value<String> kind;
  final Value<String> label;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  const CashPositionsCompanion({
    this.id = const Value.absent(),
    this.ccy = const Value.absent(),
    this.amount = const Value.absent(),
    this.costRate = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CashPositionsCompanion.insert({
    this.id = const Value.absent(),
    required String ccy,
    required double amount,
    this.costRate = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime updatedAt,
  }) : ccy = Value(ccy),
       amount = Value(amount),
       updatedAt = Value(updatedAt);
  static Insertable<CashPosition> custom({
    Expression<int>? id,
    Expression<String>? ccy,
    Expression<double>? amount,
    Expression<double>? costRate,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ccy != null) 'ccy': ccy,
      if (amount != null) 'amount': amount,
      if (costRate != null) 'cost_rate': costRate,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CashPositionsCompanion copyWith({
    Value<int>? id,
    Value<String>? ccy,
    Value<double>? amount,
    Value<double?>? costRate,
    Value<String>? kind,
    Value<String>? label,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
  }) {
    return CashPositionsCompanion(
      id: id ?? this.id,
      ccy: ccy ?? this.ccy,
      amount: amount ?? this.amount,
      costRate: costRate ?? this.costRate,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ccy.present) {
      map['ccy'] = Variable<String>(ccy.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (costRate.present) {
      map['cost_rate'] = Variable<double>(costRate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashPositionsCompanion(')
          ..write('id: $id, ')
          ..write('ccy: $ccy, ')
          ..write('amount: $amount, ')
          ..write('costRate: $costRate, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CandlesTable extends Candles with TableInfo<$CandlesTable, Candle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CandlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeKeyMeta = const VerificationMeta(
    'rangeKey',
  );
  @override
  late final GeneratedColumn<String> rangeKey = GeneratedColumn<String>(
    'range_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<int> time = GeneratedColumn<int>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openMeta = const VerificationMeta('open');
  @override
  late final GeneratedColumn<double> open = GeneratedColumn<double>(
    'open',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highMeta = const VerificationMeta('high');
  @override
  late final GeneratedColumn<double> high = GeneratedColumn<double>(
    'high',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowMeta = const VerificationMeta('low');
  @override
  late final GeneratedColumn<double> low = GeneratedColumn<double>(
    'low',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closeMeta = const VerificationMeta('close');
  @override
  late final GeneratedColumn<double> close = GeneratedColumn<double>(
    'close',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    rangeKey,
    time,
    open,
    high,
    low,
    close,
    volume,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'candles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Candle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('range_key')) {
      context.handle(
        _rangeKeyMeta,
        rangeKey.isAcceptableOrUnknown(data['range_key']!, _rangeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeKeyMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('open')) {
      context.handle(
        _openMeta,
        open.isAcceptableOrUnknown(data['open']!, _openMeta),
      );
    } else if (isInserting) {
      context.missing(_openMeta);
    }
    if (data.containsKey('high')) {
      context.handle(
        _highMeta,
        high.isAcceptableOrUnknown(data['high']!, _highMeta),
      );
    } else if (isInserting) {
      context.missing(_highMeta);
    }
    if (data.containsKey('low')) {
      context.handle(
        _lowMeta,
        low.isAcceptableOrUnknown(data['low']!, _lowMeta),
      );
    } else if (isInserting) {
      context.missing(_lowMeta);
    }
    if (data.containsKey('close')) {
      context.handle(
        _closeMeta,
        close.isAcceptableOrUnknown(data['close']!, _closeMeta),
      );
    } else if (isInserting) {
      context.missing(_closeMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol, rangeKey, time};
  @override
  Candle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Candle(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      rangeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range_key'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time'],
      )!,
      open: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}open'],
      )!,
      high: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}high'],
      )!,
      low: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low'],
      )!,
      close: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}close'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CandlesTable createAlias(String alias) {
    return $CandlesTable(attachedDatabase, alias);
  }
}

class Candle extends DataClass implements Insertable<Candle> {
  final String symbol;
  final String rangeKey;
  final int time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
  final DateTime fetchedAt;
  const Candle({
    required this.symbol,
    required this.rangeKey,
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['range_key'] = Variable<String>(rangeKey);
    map['time'] = Variable<int>(time);
    map['open'] = Variable<double>(open);
    map['high'] = Variable<double>(high);
    map['low'] = Variable<double>(low);
    map['close'] = Variable<double>(close);
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<double>(volume);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CandlesCompanion toCompanion(bool nullToAbsent) {
    return CandlesCompanion(
      symbol: Value(symbol),
      rangeKey: Value(rangeKey),
      time: Value(time),
      open: Value(open),
      high: Value(high),
      low: Value(low),
      close: Value(close),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory Candle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Candle(
      symbol: serializer.fromJson<String>(json['symbol']),
      rangeKey: serializer.fromJson<String>(json['rangeKey']),
      time: serializer.fromJson<int>(json['time']),
      open: serializer.fromJson<double>(json['open']),
      high: serializer.fromJson<double>(json['high']),
      low: serializer.fromJson<double>(json['low']),
      close: serializer.fromJson<double>(json['close']),
      volume: serializer.fromJson<double?>(json['volume']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'rangeKey': serializer.toJson<String>(rangeKey),
      'time': serializer.toJson<int>(time),
      'open': serializer.toJson<double>(open),
      'high': serializer.toJson<double>(high),
      'low': serializer.toJson<double>(low),
      'close': serializer.toJson<double>(close),
      'volume': serializer.toJson<double?>(volume),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  Candle copyWith({
    String? symbol,
    String? rangeKey,
    int? time,
    double? open,
    double? high,
    double? low,
    double? close,
    Value<double?> volume = const Value.absent(),
    DateTime? fetchedAt,
  }) => Candle(
    symbol: symbol ?? this.symbol,
    rangeKey: rangeKey ?? this.rangeKey,
    time: time ?? this.time,
    open: open ?? this.open,
    high: high ?? this.high,
    low: low ?? this.low,
    close: close ?? this.close,
    volume: volume.present ? volume.value : this.volume,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  Candle copyWithCompanion(CandlesCompanion data) {
    return Candle(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      rangeKey: data.rangeKey.present ? data.rangeKey.value : this.rangeKey,
      time: data.time.present ? data.time.value : this.time,
      open: data.open.present ? data.open.value : this.open,
      high: data.high.present ? data.high.value : this.high,
      low: data.low.present ? data.low.value : this.low,
      close: data.close.present ? data.close.value : this.close,
      volume: data.volume.present ? data.volume.value : this.volume,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Candle(')
          ..write('symbol: $symbol, ')
          ..write('rangeKey: $rangeKey, ')
          ..write('time: $time, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    rangeKey,
    time,
    open,
    high,
    low,
    close,
    volume,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Candle &&
          other.symbol == this.symbol &&
          other.rangeKey == this.rangeKey &&
          other.time == this.time &&
          other.open == this.open &&
          other.high == this.high &&
          other.low == this.low &&
          other.close == this.close &&
          other.volume == this.volume &&
          other.fetchedAt == this.fetchedAt);
}

class CandlesCompanion extends UpdateCompanion<Candle> {
  final Value<String> symbol;
  final Value<String> rangeKey;
  final Value<int> time;
  final Value<double> open;
  final Value<double> high;
  final Value<double> low;
  final Value<double> close;
  final Value<double?> volume;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CandlesCompanion({
    this.symbol = const Value.absent(),
    this.rangeKey = const Value.absent(),
    this.time = const Value.absent(),
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    this.close = const Value.absent(),
    this.volume = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CandlesCompanion.insert({
    required String symbol,
    required String rangeKey,
    required int time,
    required double open,
    required double high,
    required double low,
    required double close,
    this.volume = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       rangeKey = Value(rangeKey),
       time = Value(time),
       open = Value(open),
       high = Value(high),
       low = Value(low),
       close = Value(close),
       fetchedAt = Value(fetchedAt);
  static Insertable<Candle> custom({
    Expression<String>? symbol,
    Expression<String>? rangeKey,
    Expression<int>? time,
    Expression<double>? open,
    Expression<double>? high,
    Expression<double>? low,
    Expression<double>? close,
    Expression<double>? volume,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (rangeKey != null) 'range_key': rangeKey,
      if (time != null) 'time': time,
      if (open != null) 'open': open,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CandlesCompanion copyWith({
    Value<String>? symbol,
    Value<String>? rangeKey,
    Value<int>? time,
    Value<double>? open,
    Value<double>? high,
    Value<double>? low,
    Value<double>? close,
    Value<double?>? volume,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CandlesCompanion(
      symbol: symbol ?? this.symbol,
      rangeKey: rangeKey ?? this.rangeKey,
      time: time ?? this.time,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (rangeKey.present) {
      map['range_key'] = Variable<String>(rangeKey.value);
    }
    if (time.present) {
      map['time'] = Variable<int>(time.value);
    }
    if (open.present) {
      map['open'] = Variable<double>(open.value);
    }
    if (high.present) {
      map['high'] = Variable<double>(high.value);
    }
    if (low.present) {
      map['low'] = Variable<double>(low.value);
    }
    if (close.present) {
      map['close'] = Variable<double>(close.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CandlesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('rangeKey: $rangeKey, ')
          ..write('time: $time, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuoteCacheTable extends QuoteCache
    with TableInfo<$QuoteCacheTable, QuoteCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuoteCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousCloseMeta = const VerificationMeta(
    'previousClose',
  );
  @override
  late final GeneratedColumn<double> previousClose = GeneratedColumn<double>(
    'previous_close',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marketTimeMeta = const VerificationMeta(
    'marketTime',
  );
  @override
  late final GeneratedColumn<int> marketTime = GeneratedColumn<int>(
    'market_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TWD'),
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('america'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    price,
    previousClose,
    marketTime,
    volume,
    name,
    currency,
    market,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quote_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('previous_close')) {
      context.handle(
        _previousCloseMeta,
        previousClose.isAcceptableOrUnknown(
          data['previous_close']!,
          _previousCloseMeta,
        ),
      );
    }
    if (data.containsKey('market_time')) {
      context.handle(
        _marketTimeMeta,
        marketTime.isAcceptableOrUnknown(data['market_time']!, _marketTimeMeta),
      );
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  QuoteCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteCacheData(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      previousClose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_close'],
      ),
      marketTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}market_time'],
      ),
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuoteCacheTable createAlias(String alias) {
    return $QuoteCacheTable(attachedDatabase, alias);
  }
}

class QuoteCacheData extends DataClass implements Insertable<QuoteCacheData> {
  final String symbol;
  final double price;
  final double? previousClose;
  final int? marketTime;
  final double? volume;
  final String name;
  final String currency;
  final String market;

  /// 抓到的時刻（顯示「更新於 HH:mm」與判斷是否過期）
  final DateTime updatedAt;
  const QuoteCacheData({
    required this.symbol,
    required this.price,
    this.previousClose,
    this.marketTime,
    this.volume,
    required this.name,
    required this.currency,
    required this.market,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || previousClose != null) {
      map['previous_close'] = Variable<double>(previousClose);
    }
    if (!nullToAbsent || marketTime != null) {
      map['market_time'] = Variable<int>(marketTime);
    }
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<double>(volume);
    }
    map['name'] = Variable<String>(name);
    map['currency'] = Variable<String>(currency);
    map['market'] = Variable<String>(market);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuoteCacheCompanion toCompanion(bool nullToAbsent) {
    return QuoteCacheCompanion(
      symbol: Value(symbol),
      price: Value(price),
      previousClose: previousClose == null && nullToAbsent
          ? const Value.absent()
          : Value(previousClose),
      marketTime: marketTime == null && nullToAbsent
          ? const Value.absent()
          : Value(marketTime),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
      name: Value(name),
      currency: Value(currency),
      market: Value(market),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuoteCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteCacheData(
      symbol: serializer.fromJson<String>(json['symbol']),
      price: serializer.fromJson<double>(json['price']),
      previousClose: serializer.fromJson<double?>(json['previousClose']),
      marketTime: serializer.fromJson<int?>(json['marketTime']),
      volume: serializer.fromJson<double?>(json['volume']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String>(json['currency']),
      market: serializer.fromJson<String>(json['market']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'price': serializer.toJson<double>(price),
      'previousClose': serializer.toJson<double?>(previousClose),
      'marketTime': serializer.toJson<int?>(marketTime),
      'volume': serializer.toJson<double?>(volume),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String>(currency),
      'market': serializer.toJson<String>(market),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuoteCacheData copyWith({
    String? symbol,
    double? price,
    Value<double?> previousClose = const Value.absent(),
    Value<int?> marketTime = const Value.absent(),
    Value<double?> volume = const Value.absent(),
    String? name,
    String? currency,
    String? market,
    DateTime? updatedAt,
  }) => QuoteCacheData(
    symbol: symbol ?? this.symbol,
    price: price ?? this.price,
    previousClose: previousClose.present
        ? previousClose.value
        : this.previousClose,
    marketTime: marketTime.present ? marketTime.value : this.marketTime,
    volume: volume.present ? volume.value : this.volume,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    market: market ?? this.market,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuoteCacheData copyWithCompanion(QuoteCacheCompanion data) {
    return QuoteCacheData(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      price: data.price.present ? data.price.value : this.price,
      previousClose: data.previousClose.present
          ? data.previousClose.value
          : this.previousClose,
      marketTime: data.marketTime.present
          ? data.marketTime.value
          : this.marketTime,
      volume: data.volume.present ? data.volume.value : this.volume,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      market: data.market.present ? data.market.value : this.market,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteCacheData(')
          ..write('symbol: $symbol, ')
          ..write('price: $price, ')
          ..write('previousClose: $previousClose, ')
          ..write('marketTime: $marketTime, ')
          ..write('volume: $volume, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('market: $market, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    price,
    previousClose,
    marketTime,
    volume,
    name,
    currency,
    market,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteCacheData &&
          other.symbol == this.symbol &&
          other.price == this.price &&
          other.previousClose == this.previousClose &&
          other.marketTime == this.marketTime &&
          other.volume == this.volume &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.market == this.market &&
          other.updatedAt == this.updatedAt);
}

class QuoteCacheCompanion extends UpdateCompanion<QuoteCacheData> {
  final Value<String> symbol;
  final Value<double> price;
  final Value<double?> previousClose;
  final Value<int?> marketTime;
  final Value<double?> volume;
  final Value<String> name;
  final Value<String> currency;
  final Value<String> market;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuoteCacheCompanion({
    this.symbol = const Value.absent(),
    this.price = const Value.absent(),
    this.previousClose = const Value.absent(),
    this.marketTime = const Value.absent(),
    this.volume = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.market = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuoteCacheCompanion.insert({
    required String symbol,
    required double price,
    this.previousClose = const Value.absent(),
    this.marketTime = const Value.absent(),
    this.volume = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.market = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       price = Value(price),
       updatedAt = Value(updatedAt);
  static Insertable<QuoteCacheData> custom({
    Expression<String>? symbol,
    Expression<double>? price,
    Expression<double>? previousClose,
    Expression<int>? marketTime,
    Expression<double>? volume,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<String>? market,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (price != null) 'price': price,
      if (previousClose != null) 'previous_close': previousClose,
      if (marketTime != null) 'market_time': marketTime,
      if (volume != null) 'volume': volume,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (market != null) 'market': market,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuoteCacheCompanion copyWith({
    Value<String>? symbol,
    Value<double>? price,
    Value<double?>? previousClose,
    Value<int?>? marketTime,
    Value<double?>? volume,
    Value<String>? name,
    Value<String>? currency,
    Value<String>? market,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuoteCacheCompanion(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      previousClose: previousClose ?? this.previousClose,
      marketTime: marketTime ?? this.marketTime,
      volume: volume ?? this.volume,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      market: market ?? this.market,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (previousClose.present) {
      map['previous_close'] = Variable<double>(previousClose.value);
    }
    if (marketTime.present) {
      map['market_time'] = Variable<int>(marketTime.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuoteCacheCompanion(')
          ..write('symbol: $symbol, ')
          ..write('price: $price, ')
          ..write('previousClose: $previousClose, ')
          ..write('marketTime: $marketTime, ')
          ..write('volume: $volume, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('market: $market, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, Alert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<double> threshold = GeneratedColumn<double>(
    'threshold',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    symbol,
    threshold,
    scope,
    enabled,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Alert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      ),
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}threshold'],
      ),
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class Alert extends DataClass implements Insertable<Alert> {
  final int id;
  final String kind;
  final String? symbol;
  final double? threshold;
  final String scope;
  final bool enabled;
  final String? note;
  final DateTime createdAt;
  const Alert({
    required this.id,
    required this.kind,
    this.symbol,
    this.threshold,
    required this.scope,
    required this.enabled,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || symbol != null) {
      map['symbol'] = Variable<String>(symbol);
    }
    if (!nullToAbsent || threshold != null) {
      map['threshold'] = Variable<double>(threshold);
    }
    map['scope'] = Variable<String>(scope);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      kind: Value(kind),
      symbol: symbol == null && nullToAbsent
          ? const Value.absent()
          : Value(symbol),
      threshold: threshold == null && nullToAbsent
          ? const Value.absent()
          : Value(threshold),
      scope: Value(scope),
      enabled: Value(enabled),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Alert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alert(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      symbol: serializer.fromJson<String?>(json['symbol']),
      threshold: serializer.fromJson<double?>(json['threshold']),
      scope: serializer.fromJson<String>(json['scope']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'symbol': serializer.toJson<String?>(symbol),
      'threshold': serializer.toJson<double?>(threshold),
      'scope': serializer.toJson<String>(scope),
      'enabled': serializer.toJson<bool>(enabled),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Alert copyWith({
    int? id,
    String? kind,
    Value<String?> symbol = const Value.absent(),
    Value<double?> threshold = const Value.absent(),
    String? scope,
    bool? enabled,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Alert(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    symbol: symbol.present ? symbol.value : this.symbol,
    threshold: threshold.present ? threshold.value : this.threshold,
    scope: scope ?? this.scope,
    enabled: enabled ?? this.enabled,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Alert copyWithCompanion(AlertsCompanion data) {
    return Alert(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      scope: data.scope.present ? data.scope.value : this.scope,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alert(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('symbol: $symbol, ')
          ..write('threshold: $threshold, ')
          ..write('scope: $scope, ')
          ..write('enabled: $enabled, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, symbol, threshold, scope, enabled, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alert &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.symbol == this.symbol &&
          other.threshold == this.threshold &&
          other.scope == this.scope &&
          other.enabled == this.enabled &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class AlertsCompanion extends UpdateCompanion<Alert> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String?> symbol;
  final Value<double?> threshold;
  final Value<String> scope;
  final Value<bool> enabled;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.symbol = const Value.absent(),
    this.threshold = const Value.absent(),
    this.scope = const Value.absent(),
    this.enabled = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AlertsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.symbol = const Value.absent(),
    this.threshold = const Value.absent(),
    this.scope = const Value.absent(),
    this.enabled = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Alert> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? symbol,
    Expression<double>? threshold,
    Expression<String>? scope,
    Expression<bool>? enabled,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (symbol != null) 'symbol': symbol,
      if (threshold != null) 'threshold': threshold,
      if (scope != null) 'scope': scope,
      if (enabled != null) 'enabled': enabled,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AlertsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String?>? symbol,
    Value<double?>? threshold,
    Value<String>? scope,
    Value<bool>? enabled,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return AlertsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      symbol: symbol ?? this.symbol,
      threshold: threshold ?? this.threshold,
      scope: scope ?? this.scope,
      enabled: enabled ?? this.enabled,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<double>(threshold.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('symbol: $symbol, ')
          ..write('threshold: $threshold, ')
          ..write('scope: $scope, ')
          ..write('enabled: $enabled, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AlertLogsTable extends AlertLogs
    with TableInfo<$AlertLogsTable, AlertLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _alertIdMeta = const VerificationMeta(
    'alertId',
  );
  @override
  late final GeneratedColumn<int> alertId = GeneratedColumn<int>(
    'alert_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firedAtMeta = const VerificationMeta(
    'firedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firedAt = GeneratedColumn<DateTime>(
    'fired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _triggeredMeta = const VerificationMeta(
    'triggered',
  );
  @override
  late final GeneratedColumn<bool> triggered = GeneratedColumn<bool>(
    'triggered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("triggered" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alertId,
    firedAt,
    value,
    triggered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('alert_id')) {
      context.handle(
        _alertIdMeta,
        alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    if (data.containsKey('fired_at')) {
      context.handle(
        _firedAtMeta,
        firedAt.isAcceptableOrUnknown(data['fired_at']!, _firedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_firedAtMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('triggered')) {
      context.handle(
        _triggeredMeta,
        triggered.isAcceptableOrUnknown(data['triggered']!, _triggeredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      alertId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_id'],
      )!,
      firedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fired_at'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      ),
      triggered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}triggered'],
      )!,
    );
  }

  @override
  $AlertLogsTable createAlias(String alias) {
    return $AlertLogsTable(attachedDatabase, alias);
  }
}

class AlertLog extends DataClass implements Insertable<AlertLog> {
  final int id;
  final int alertId;
  final DateTime firedAt;
  final double? value;
  final bool triggered;
  const AlertLog({
    required this.id,
    required this.alertId,
    required this.firedAt,
    this.value,
    required this.triggered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alert_id'] = Variable<int>(alertId);
    map['fired_at'] = Variable<DateTime>(firedAt);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    map['triggered'] = Variable<bool>(triggered);
    return map;
  }

  AlertLogsCompanion toCompanion(bool nullToAbsent) {
    return AlertLogsCompanion(
      id: Value(id),
      alertId: Value(alertId),
      firedAt: Value(firedAt),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      triggered: Value(triggered),
    );
  }

  factory AlertLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertLog(
      id: serializer.fromJson<int>(json['id']),
      alertId: serializer.fromJson<int>(json['alertId']),
      firedAt: serializer.fromJson<DateTime>(json['firedAt']),
      value: serializer.fromJson<double?>(json['value']),
      triggered: serializer.fromJson<bool>(json['triggered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alertId': serializer.toJson<int>(alertId),
      'firedAt': serializer.toJson<DateTime>(firedAt),
      'value': serializer.toJson<double?>(value),
      'triggered': serializer.toJson<bool>(triggered),
    };
  }

  AlertLog copyWith({
    int? id,
    int? alertId,
    DateTime? firedAt,
    Value<double?> value = const Value.absent(),
    bool? triggered,
  }) => AlertLog(
    id: id ?? this.id,
    alertId: alertId ?? this.alertId,
    firedAt: firedAt ?? this.firedAt,
    value: value.present ? value.value : this.value,
    triggered: triggered ?? this.triggered,
  );
  AlertLog copyWithCompanion(AlertLogsCompanion data) {
    return AlertLog(
      id: data.id.present ? data.id.value : this.id,
      alertId: data.alertId.present ? data.alertId.value : this.alertId,
      firedAt: data.firedAt.present ? data.firedAt.value : this.firedAt,
      value: data.value.present ? data.value.value : this.value,
      triggered: data.triggered.present ? data.triggered.value : this.triggered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertLog(')
          ..write('id: $id, ')
          ..write('alertId: $alertId, ')
          ..write('firedAt: $firedAt, ')
          ..write('value: $value, ')
          ..write('triggered: $triggered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alertId, firedAt, value, triggered);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertLog &&
          other.id == this.id &&
          other.alertId == this.alertId &&
          other.firedAt == this.firedAt &&
          other.value == this.value &&
          other.triggered == this.triggered);
}

class AlertLogsCompanion extends UpdateCompanion<AlertLog> {
  final Value<int> id;
  final Value<int> alertId;
  final Value<DateTime> firedAt;
  final Value<double?> value;
  final Value<bool> triggered;
  const AlertLogsCompanion({
    this.id = const Value.absent(),
    this.alertId = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.value = const Value.absent(),
    this.triggered = const Value.absent(),
  });
  AlertLogsCompanion.insert({
    this.id = const Value.absent(),
    required int alertId,
    required DateTime firedAt,
    this.value = const Value.absent(),
    this.triggered = const Value.absent(),
  }) : alertId = Value(alertId),
       firedAt = Value(firedAt);
  static Insertable<AlertLog> custom({
    Expression<int>? id,
    Expression<int>? alertId,
    Expression<DateTime>? firedAt,
    Expression<double>? value,
    Expression<bool>? triggered,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alertId != null) 'alert_id': alertId,
      if (firedAt != null) 'fired_at': firedAt,
      if (value != null) 'value': value,
      if (triggered != null) 'triggered': triggered,
    });
  }

  AlertLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? alertId,
    Value<DateTime>? firedAt,
    Value<double?>? value,
    Value<bool>? triggered,
  }) {
    return AlertLogsCompanion(
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      firedAt: firedAt ?? this.firedAt,
      value: value ?? this.value,
      triggered: triggered ?? this.triggered,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alertId.present) {
      map['alert_id'] = Variable<int>(alertId.value);
    }
    if (firedAt.present) {
      map['fired_at'] = Variable<DateTime>(firedAt.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (triggered.present) {
      map['triggered'] = Variable<bool>(triggered.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertLogsCompanion(')
          ..write('id: $id, ')
          ..write('alertId: $alertId, ')
          ..write('firedAt: $firedAt, ')
          ..write('value: $value, ')
          ..write('triggered: $triggered')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $HoldingsTable holdings = $HoldingsTable(this);
  late final $CashPositionsTable cashPositions = $CashPositionsTable(this);
  late final $CandlesTable candles = $CandlesTable(this);
  late final $QuoteCacheTable quoteCache = $QuoteCacheTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $AlertLogsTable alertLogs = $AlertLogsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    instruments,
    holdings,
    cashPositions,
    candles,
    quoteCache,
    alerts,
    alertLogs,
    settings,
  ];
}

typedef $$InstrumentsTableCreateCompanionBuilder =
    InstrumentsCompanion Function({
      required String symbol,
      Value<String> name,
      Value<String?> alias,
      Value<String> currency,
      Value<String> market,
      Value<int> sortOrder,
      Value<bool> inWidget,
      Value<DateTime?> addedAt,
      Value<int> rowid,
    });
typedef $$InstrumentsTableUpdateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> symbol,
      Value<String> name,
      Value<String?> alias,
      Value<String> currency,
      Value<String> market,
      Value<int> sortOrder,
      Value<bool> inWidget,
      Value<DateTime?> addedAt,
      Value<int> rowid,
    });

class $$InstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inWidget => $composableBuilder(
    column: $table.inWidget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inWidget => $composableBuilder(
    column: $table.inWidget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get inWidget =>
      $composableBuilder(column: $table.inWidget, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$InstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentsTable,
          Instrument,
          $$InstrumentsTableFilterComposer,
          $$InstrumentsTableOrderingComposer,
          $$InstrumentsTableAnnotationComposer,
          $$InstrumentsTableCreateCompanionBuilder,
          $$InstrumentsTableUpdateCompanionBuilder,
          (
            Instrument,
            BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>,
          ),
          Instrument,
          PrefetchHooks Function()
        > {
  $$InstrumentsTableTableManager(_$AppDatabase db, $InstrumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> inWidget = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion(
                symbol: symbol,
                name: name,
                alias: alias,
                currency: currency,
                market: market,
                sortOrder: sortOrder,
                inWidget: inWidget,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                Value<String> name = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> inWidget = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion.insert(
                symbol: symbol,
                name: name,
                alias: alias,
                currency: currency,
                market: market,
                sortOrder: sortOrder,
                inWidget: inWidget,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstrumentsTable, Instrument>(table),
                  BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentsTable,
      Instrument,
      $$InstrumentsTableFilterComposer,
      $$InstrumentsTableOrderingComposer,
      $$InstrumentsTableAnnotationComposer,
      $$InstrumentsTableCreateCompanionBuilder,
      $$InstrumentsTableUpdateCompanionBuilder,
      (
        Instrument,
        BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>,
      ),
      Instrument,
      PrefetchHooks Function()
    >;
typedef $$HoldingsTableCreateCompanionBuilder = HoldingsCompanion Function({
  Value<int> id,
  required String symbol,
  Value<String> market,
  Value<String> ccy,
  required double shares,
  required double costPrice,
  Value<double?> costRate,
  Value<DateTime?> buyDate,
  Value<String?> broker,
  Value<String?> note,
  required DateTime updatedAt,
});
typedef $$HoldingsTableUpdateCompanionBuilder = HoldingsCompanion Function({
  Value<int> id,
  Value<String> symbol,
  Value<String> market,
  Value<String> ccy,
  Value<double> shares,
  Value<double> costPrice,
  Value<double?> costRate,
  Value<DateTime?> buyDate,
  Value<String?> broker,
  Value<String?> note,
  Value<DateTime> updatedAt,
});

class $$HoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ccy => $composableBuilder(
    column: $table.ccy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shares => $composableBuilder(
    column: $table.shares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costRate => $composableBuilder(
    column: $table.costRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get buyDate => $composableBuilder(
    column: $table.buyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ccy => $composableBuilder(
    column: $table.ccy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shares => $composableBuilder(
    column: $table.shares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costRate => $composableBuilder(
    column: $table.costRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get buyDate => $composableBuilder(
    column: $table.buyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get ccy =>
      $composableBuilder(column: $table.ccy, builder: (column) => column);

  GeneratedColumn<double> get shares =>
      $composableBuilder(column: $table.shares, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get costRate =>
      $composableBuilder(column: $table.costRate, builder: (column) => column);

  GeneratedColumn<DateTime> get buyDate =>
      $composableBuilder(column: $table.buyDate, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingsTable,
          Holding,
          $$HoldingsTableFilterComposer,
          $$HoldingsTableOrderingComposer,
          $$HoldingsTableAnnotationComposer,
          $$HoldingsTableCreateCompanionBuilder,
          $$HoldingsTableUpdateCompanionBuilder,
          (Holding, BaseReferences<_$AppDatabase, $HoldingsTable, Holding>),
          Holding,
          PrefetchHooks Function()
        > {
  $$HoldingsTableTableManager(_$AppDatabase db, $HoldingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> ccy = const Value.absent(),
                Value<double> shares = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double?> costRate = const Value.absent(),
                Value<DateTime?> buyDate = const Value.absent(),
                Value<String?> broker = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HoldingsCompanion(
                id: id,
                symbol: symbol,
                market: market,
                ccy: ccy,
                shares: shares,
                costPrice: costPrice,
                costRate: costRate,
                buyDate: buyDate,
                broker: broker,
                note: note,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String symbol,
                Value<String> market = const Value.absent(),
                Value<String> ccy = const Value.absent(),
                required double shares,
                required double costPrice,
                Value<double?> costRate = const Value.absent(),
                Value<DateTime?> buyDate = const Value.absent(),
                Value<String?> broker = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
              }) => HoldingsCompanion.insert(
                id: id,
                symbol: symbol,
                market: market,
                ccy: ccy,
                shares: shares,
                costPrice: costPrice,
                costRate: costRate,
                buyDate: buyDate,
                broker: broker,
                note: note,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HoldingsTable, Holding>(table),
                  BaseReferences<_$AppDatabase, $HoldingsTable, Holding>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingsTable,
      Holding,
      $$HoldingsTableFilterComposer,
      $$HoldingsTableOrderingComposer,
      $$HoldingsTableAnnotationComposer,
      $$HoldingsTableCreateCompanionBuilder,
      $$HoldingsTableUpdateCompanionBuilder,
      (Holding, BaseReferences<_$AppDatabase, $HoldingsTable, Holding>),
      Holding,
      PrefetchHooks Function()
    >;
typedef $$CashPositionsTableCreateCompanionBuilder =
    CashPositionsCompanion Function({
      Value<int> id,
      required String ccy,
      required double amount,
      Value<double?> costRate,
      Value<String> kind,
      Value<String> label,
      Value<String?> note,
      required DateTime updatedAt,
    });
typedef $$CashPositionsTableUpdateCompanionBuilder =
    CashPositionsCompanion Function({
      Value<int> id,
      Value<String> ccy,
      Value<double> amount,
      Value<double?> costRate,
      Value<String> kind,
      Value<String> label,
      Value<String?> note,
      Value<DateTime> updatedAt,
    });

class $$CashPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $CashPositionsTable> {
  $$CashPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ccy => $composableBuilder(
    column: $table.ccy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costRate => $composableBuilder(
    column: $table.costRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashPositionsTable> {
  $$CashPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ccy => $composableBuilder(
    column: $table.ccy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costRate => $composableBuilder(
    column: $table.costRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashPositionsTable> {
  $$CashPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ccy =>
      $composableBuilder(column: $table.ccy, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get costRate =>
      $composableBuilder(column: $table.costRate, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CashPositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashPositionsTable,
          CashPosition,
          $$CashPositionsTableFilterComposer,
          $$CashPositionsTableOrderingComposer,
          $$CashPositionsTableAnnotationComposer,
          $$CashPositionsTableCreateCompanionBuilder,
          $$CashPositionsTableUpdateCompanionBuilder,
          (
            CashPosition,
            BaseReferences<_$AppDatabase, $CashPositionsTable, CashPosition>,
          ),
          CashPosition,
          PrefetchHooks Function()
        > {
  $$CashPositionsTableTableManager(_$AppDatabase db, $CashPositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ccy = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double?> costRate = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CashPositionsCompanion(
                id: id,
                ccy: ccy,
                amount: amount,
                costRate: costRate,
                kind: kind,
                label: label,
                note: note,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ccy,
                required double amount,
                Value<double?> costRate = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
              }) => CashPositionsCompanion.insert(
                id: id,
                ccy: ccy,
                amount: amount,
                costRate: costRate,
                kind: kind,
                label: label,
                note: note,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashPositionsTable, CashPosition>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashPositionsTable,
                    CashPosition
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashPositionsTable,
      CashPosition,
      $$CashPositionsTableFilterComposer,
      $$CashPositionsTableOrderingComposer,
      $$CashPositionsTableAnnotationComposer,
      $$CashPositionsTableCreateCompanionBuilder,
      $$CashPositionsTableUpdateCompanionBuilder,
      (
        CashPosition,
        BaseReferences<_$AppDatabase, $CashPositionsTable, CashPosition>,
      ),
      CashPosition,
      PrefetchHooks Function()
    >;
typedef $$CandlesTableCreateCompanionBuilder = CandlesCompanion Function({
  required String symbol,
  required String rangeKey,
  required int time,
  required double open,
  required double high,
  required double low,
  required double close,
  Value<double?> volume,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$CandlesTableUpdateCompanionBuilder = CandlesCompanion Function({
  Value<String> symbol,
  Value<String> rangeKey,
  Value<int> time,
  Value<double> open,
  Value<double> high,
  Value<double> low,
  Value<double> close,
  Value<double?> volume,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$CandlesTableFilterComposer
    extends Composer<_$AppDatabase, $CandlesTable> {
  $$CandlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rangeKey => $composableBuilder(
    column: $table.rangeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CandlesTableOrderingComposer
    extends Composer<_$AppDatabase, $CandlesTable> {
  $$CandlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rangeKey => $composableBuilder(
    column: $table.rangeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CandlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CandlesTable> {
  $$CandlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get rangeKey =>
      $composableBuilder(column: $table.rangeKey, builder: (column) => column);

  GeneratedColumn<int> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get open =>
      $composableBuilder(column: $table.open, builder: (column) => column);

  GeneratedColumn<double> get high =>
      $composableBuilder(column: $table.high, builder: (column) => column);

  GeneratedColumn<double> get low =>
      $composableBuilder(column: $table.low, builder: (column) => column);

  GeneratedColumn<double> get close =>
      $composableBuilder(column: $table.close, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CandlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CandlesTable,
          Candle,
          $$CandlesTableFilterComposer,
          $$CandlesTableOrderingComposer,
          $$CandlesTableAnnotationComposer,
          $$CandlesTableCreateCompanionBuilder,
          $$CandlesTableUpdateCompanionBuilder,
          (Candle, BaseReferences<_$AppDatabase, $CandlesTable, Candle>),
          Candle,
          PrefetchHooks Function()
        > {
  $$CandlesTableTableManager(_$AppDatabase db, $CandlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CandlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CandlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CandlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> rangeKey = const Value.absent(),
                Value<int> time = const Value.absent(),
                Value<double> open = const Value.absent(),
                Value<double> high = const Value.absent(),
                Value<double> low = const Value.absent(),
                Value<double> close = const Value.absent(),
                Value<double?> volume = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CandlesCompanion(
                symbol: symbol,
                rangeKey: rangeKey,
                time: time,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required String rangeKey,
                required int time,
                required double open,
                required double high,
                required double low,
                required double close,
                Value<double?> volume = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CandlesCompanion.insert(
                symbol: symbol,
                rangeKey: rangeKey,
                time: time,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CandlesTable, Candle>(table),
                  BaseReferences<_$AppDatabase, $CandlesTable, Candle>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CandlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CandlesTable,
      Candle,
      $$CandlesTableFilterComposer,
      $$CandlesTableOrderingComposer,
      $$CandlesTableAnnotationComposer,
      $$CandlesTableCreateCompanionBuilder,
      $$CandlesTableUpdateCompanionBuilder,
      (Candle, BaseReferences<_$AppDatabase, $CandlesTable, Candle>),
      Candle,
      PrefetchHooks Function()
    >;
typedef $$QuoteCacheTableCreateCompanionBuilder = QuoteCacheCompanion Function({
  required String symbol,
  required double price,
  Value<double?> previousClose,
  Value<int?> marketTime,
  Value<double?> volume,
  Value<String> name,
  Value<String> currency,
  Value<String> market,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$QuoteCacheTableUpdateCompanionBuilder = QuoteCacheCompanion Function({
  Value<String> symbol,
  Value<double> price,
  Value<double?> previousClose,
  Value<int?> marketTime,
  Value<double?> volume,
  Value<String> name,
  Value<String> currency,
  Value<String> market,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$QuoteCacheTableFilterComposer
    extends Composer<_$AppDatabase, $QuoteCacheTable> {
  $$QuoteCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousClose => $composableBuilder(
    column: $table.previousClose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marketTime => $composableBuilder(
    column: $table.marketTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuoteCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $QuoteCacheTable> {
  $$QuoteCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousClose => $composableBuilder(
    column: $table.previousClose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marketTime => $composableBuilder(
    column: $table.marketTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuoteCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuoteCacheTable> {
  $$QuoteCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get previousClose => $composableBuilder(
    column: $table.previousClose,
    builder: (column) => column,
  );

  GeneratedColumn<int> get marketTime => $composableBuilder(
    column: $table.marketTime,
    builder: (column) => column,
  );

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuoteCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuoteCacheTable,
          QuoteCacheData,
          $$QuoteCacheTableFilterComposer,
          $$QuoteCacheTableOrderingComposer,
          $$QuoteCacheTableAnnotationComposer,
          $$QuoteCacheTableCreateCompanionBuilder,
          $$QuoteCacheTableUpdateCompanionBuilder,
          (
            QuoteCacheData,
            BaseReferences<_$AppDatabase, $QuoteCacheTable, QuoteCacheData>,
          ),
          QuoteCacheData,
          PrefetchHooks Function()
        > {
  $$QuoteCacheTableTableManager(_$AppDatabase db, $QuoteCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuoteCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuoteCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuoteCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> previousClose = const Value.absent(),
                Value<int?> marketTime = const Value.absent(),
                Value<double?> volume = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuoteCacheCompanion(
                symbol: symbol,
                price: price,
                previousClose: previousClose,
                marketTime: marketTime,
                volume: volume,
                name: name,
                currency: currency,
                market: market,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required double price,
                Value<double?> previousClose = const Value.absent(),
                Value<int?> marketTime = const Value.absent(),
                Value<double?> volume = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> market = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuoteCacheCompanion.insert(
                symbol: symbol,
                price: price,
                previousClose: previousClose,
                marketTime: marketTime,
                volume: volume,
                name: name,
                currency: currency,
                market: market,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuoteCacheTable, QuoteCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QuoteCacheTable,
                    QuoteCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuoteCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuoteCacheTable,
      QuoteCacheData,
      $$QuoteCacheTableFilterComposer,
      $$QuoteCacheTableOrderingComposer,
      $$QuoteCacheTableAnnotationComposer,
      $$QuoteCacheTableCreateCompanionBuilder,
      $$QuoteCacheTableUpdateCompanionBuilder,
      (
        QuoteCacheData,
        BaseReferences<_$AppDatabase, $QuoteCacheTable, QuoteCacheData>,
      ),
      QuoteCacheData,
      PrefetchHooks Function()
    >;
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  Value<int> id,
  required String kind,
  Value<String?> symbol,
  Value<double?> threshold,
  Value<String> scope,
  Value<bool> enabled,
  Value<String?> note,
  required DateTime createdAt,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String?> symbol,
  Value<double?> threshold,
  Value<String> scope,
  Value<bool> enabled,
  Value<String?> note,
  Value<DateTime> createdAt,
});

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<double> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertsTable,
          Alert,
          $$AlertsTableFilterComposer,
          $$AlertsTableOrderingComposer,
          $$AlertsTableAnnotationComposer,
          $$AlertsTableCreateCompanionBuilder,
          $$AlertsTableUpdateCompanionBuilder,
          (Alert, BaseReferences<_$AppDatabase, $AlertsTable, Alert>),
          Alert,
          PrefetchHooks Function()
        > {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> symbol = const Value.absent(),
                Value<double?> threshold = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AlertsCompanion(
                id: id,
                kind: kind,
                symbol: symbol,
                threshold: threshold,
                scope: scope,
                enabled: enabled,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<String?> symbol = const Value.absent(),
                Value<double?> threshold = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => AlertsCompanion.insert(
                id: id,
                kind: kind,
                symbol: symbol,
                threshold: threshold,
                scope: scope,
                enabled: enabled,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertsTable, Alert>(table),
                  BaseReferences<_$AppDatabase, $AlertsTable, Alert>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertsTable,
      Alert,
      $$AlertsTableFilterComposer,
      $$AlertsTableOrderingComposer,
      $$AlertsTableAnnotationComposer,
      $$AlertsTableCreateCompanionBuilder,
      $$AlertsTableUpdateCompanionBuilder,
      (Alert, BaseReferences<_$AppDatabase, $AlertsTable, Alert>),
      Alert,
      PrefetchHooks Function()
    >;
typedef $$AlertLogsTableCreateCompanionBuilder = AlertLogsCompanion Function({
  Value<int> id,
  required int alertId,
  required DateTime firedAt,
  Value<double?> value,
  Value<bool> triggered,
});
typedef $$AlertLogsTableUpdateCompanionBuilder = AlertLogsCompanion Function({
  Value<int> id,
  Value<int> alertId,
  Value<DateTime> firedAt,
  Value<double?> value,
  Value<bool> triggered,
});

class $$AlertLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertLogsTable> {
  $$AlertLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertId => $composableBuilder(
    column: $table.alertId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get triggered => $composableBuilder(
    column: $table.triggered,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertLogsTable> {
  $$AlertLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertId => $composableBuilder(
    column: $table.alertId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get triggered => $composableBuilder(
    column: $table.triggered,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertLogsTable> {
  $$AlertLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get alertId =>
      $composableBuilder(column: $table.alertId, builder: (column) => column);

  GeneratedColumn<DateTime> get firedAt =>
      $composableBuilder(column: $table.firedAt, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get triggered =>
      $composableBuilder(column: $table.triggered, builder: (column) => column);
}

class $$AlertLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertLogsTable,
          AlertLog,
          $$AlertLogsTableFilterComposer,
          $$AlertLogsTableOrderingComposer,
          $$AlertLogsTableAnnotationComposer,
          $$AlertLogsTableCreateCompanionBuilder,
          $$AlertLogsTableUpdateCompanionBuilder,
          (AlertLog, BaseReferences<_$AppDatabase, $AlertLogsTable, AlertLog>),
          AlertLog,
          PrefetchHooks Function()
        > {
  $$AlertLogsTableTableManager(_$AppDatabase db, $AlertLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> alertId = const Value.absent(),
                Value<DateTime> firedAt = const Value.absent(),
                Value<double?> value = const Value.absent(),
                Value<bool> triggered = const Value.absent(),
              }) => AlertLogsCompanion(
                id: id,
                alertId: alertId,
                firedAt: firedAt,
                value: value,
                triggered: triggered,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int alertId,
                required DateTime firedAt,
                Value<double?> value = const Value.absent(),
                Value<bool> triggered = const Value.absent(),
              }) => AlertLogsCompanion.insert(
                id: id,
                alertId: alertId,
                firedAt: firedAt,
                value: value,
                triggered: triggered,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertLogsTable, AlertLog>(table),
                  BaseReferences<_$AppDatabase, $AlertLogsTable, AlertLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertLogsTable,
      AlertLog,
      $$AlertLogsTableFilterComposer,
      $$AlertLogsTableOrderingComposer,
      $$AlertLogsTableAnnotationComposer,
      $$AlertLogsTableCreateCompanionBuilder,
      $$AlertLogsTableUpdateCompanionBuilder,
      (AlertLog, BaseReferences<_$AppDatabase, $AlertLogsTable, AlertLog>),
      AlertLog,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db, _db.instruments);
  $$HoldingsTableTableManager get holdings =>
      $$HoldingsTableTableManager(_db, _db.holdings);
  $$CashPositionsTableTableManager get cashPositions =>
      $$CashPositionsTableTableManager(_db, _db.cashPositions);
  $$CandlesTableTableManager get candles =>
      $$CandlesTableTableManager(_db, _db.candles);
  $$QuoteCacheTableTableManager get quoteCache =>
      $$QuoteCacheTableTableManager(_db, _db.quoteCache);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$AlertLogsTableTableManager get alertLogs =>
      $$AlertLogsTableTableManager(_db, _db.alertLogs);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
