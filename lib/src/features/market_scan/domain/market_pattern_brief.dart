import 'market_book.dart';

class MarketPatternBrief {
  const MarketPatternBrief({
    required this.targetPlatform,
    required this.validatedHotPatterns,
    required this.titleNamingPatterns,
    required this.synopsisHookPatterns,
    required this.saturatedAreas,
    required this.opportunityGaps,
    required this.constraintsForDirections,
    required this.referenceExemplars,
    required this.similarityGuidance,
    required this.markdown,
  });

  final MarketPlatform targetPlatform;
  final List<ValidatedHotPattern> validatedHotPatterns;
  final List<NamedPattern> titleNamingPatterns;
  final List<NamedPattern> synopsisHookPatterns;
  final List<String> saturatedAreas;
  final List<String> opportunityGaps;
  final DirectionConstraints constraintsForDirections;
  final List<ReferenceExemplar> referenceExemplars;
  final String similarityGuidance;
  final String markdown;

  List<String> get evidenceTitles {
    final output = <String>[];
    for (final pattern in validatedHotPatterns) {
      for (final title in pattern.evidenceTitles) {
        if (!output.contains(title)) {
          output.add(title);
        }
      }
    }
    for (final exemplar in referenceExemplars) {
      if (!output.contains(exemplar.title)) {
        output.add(exemplar.title);
      }
    }
    return output;
  }

  List<String> get patternNames {
    return [
      ...validatedHotPatterns.map((pattern) => pattern.name),
      ...titleNamingPatterns.map((pattern) => pattern.name),
      ...synopsisHookPatterns.map((pattern) => pattern.name),
    ];
  }
}

class ValidatedHotPattern {
  const ValidatedHotPattern({
    required this.name,
    required this.summary,
    required this.evidenceTitles,
    required this.tags,
    required this.chartSignals,
  });

  final String name;
  final String summary;
  final List<String> evidenceTitles;
  final List<String> tags;
  final List<String> chartSignals;
}

class NamedPattern {
  const NamedPattern({
    required this.name,
    required this.formula,
    required this.summary,
    this.counterExample,
  });

  final String name;
  final String formula;
  final String summary;
  final String? counterExample;
}

class DirectionConstraints {
  const DirectionConstraints({
    required this.stableHotTopic,
    required this.adjacentVariant,
    required this.highRiskHighReward,
  });

  final String stableHotTopic;
  final String adjacentVariant;
  final String highRiskHighReward;
}

class ReferenceExemplar {
  const ReferenceExemplar({
    required this.title,
    required this.description,
    required this.chartPlacement,
    required this.tags,
  });

  final String title;
  final String description;
  final String chartPlacement;
  final List<String> tags;
}
