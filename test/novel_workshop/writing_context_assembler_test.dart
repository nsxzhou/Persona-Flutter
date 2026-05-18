import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/writing_context_assembler.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';

void main() {
  test('assembles writing context sections in stable order', () {
    const sections = WritingContextSections(
      outputContract: '只输出正文。',
      chapterObjectiveCard: ChapterObjectiveCard(
        chapterTitle: '第一章',
        objective: '主角进入雾港。',
        pressureSource: '追兵逼近。',
        payoffTarget: '找到第一条线索。',
        relationshipShift: '主角和向导从互疑转为临时合作。',
        hookType: '信息差钩子。',
      ),
      voiceProfileMarkdown: '# Voice Profile\n\n短句，压迫感强。',
      storyEngineMarkdown: '# Plot Writing Guide\n\n目标 -> 阻碍 -> 半兑现。',
      projectContextMarkdown: '# Project Context\n\n雾港长期被潮汐封锁。',
      runtimeMemory: RuntimeMemoryState(
        charactersStatus: '- 林岚：刚抵达雾港。',
        runtimeState: '- 潮汐即将封城。',
        runtimeThreads: '- 港务处线索未解。',
        storySummary: '林岚追查失踪案。',
      ),
      writingRulesMarkdown: '- 使用第三人称有限视角。',
    );

    final bundle = const WritingContextAssembler().assemble(sections);

    expect(bundle.warnings, isEmpty);
    expect(
      bundle.promptMarkdown,
      equals('''
## Output Contract

只输出正文。

## Chapter Objective Card

- Chapter Title: 第一章
- Objective: 主角进入雾港。
- Pressure Source: 追兵逼近。
- Payoff Target: 找到第一条线索。
- Relationship Shift: 主角和向导从互疑转为临时合作。
- Hook Type: 信息差钩子。

## Voice Profile

# Voice Profile

短句，压迫感强。

## Story Engine

# Plot Writing Guide

目标 -> 阻碍 -> 半兑现。

## Project Context

# Project Context

雾港长期被潮汐封锁。

## Runtime Memory

### Characters Status

- 林岚：刚抵达雾港。

### Runtime State

- 潮汐即将封城。

### Runtime Threads

- 港务处线索未解。

### Story Summary

林岚追查失踪案。

## Writing Rules

- 使用第三人称有限视角。'''),
    );
  });

  test(
    'omits empty section headings and reports non-blocking asset warnings',
    () {
      const sections = WritingContextSections(
        outputContract: '只输出正文。',
        chapterObjectiveCard: ChapterObjectiveCard(objective: '推进调查。'),
        voiceProfileMarkdown: '没有标题的文风资产。',
        storyEngineMarkdown: '',
        projectContextMarkdown: '',
        runtimeMemory: RuntimeMemoryState(),
        writingRulesMarkdown: '',
      );

      final bundle = const WritingContextAssembler().assemble(sections);

      expect(bundle.promptMarkdown, isNot(contains('Project Context')));
      expect(bundle.promptMarkdown, isNot(contains('Runtime Memory')));
      expect(bundle.promptMarkdown, isNot(contains('Writing Rules')));
      expect(bundle.promptMarkdown, contains('## Chapter Objective Card'));
      expect(bundle.promptMarkdown, contains('- Objective: 推进调查。'));
      expect(bundle.promptMarkdown, contains('没有标题的文风资产。'));
      expect(bundle.warnings, [
        'Voice Profile 缺少 Markdown 标题。',
        'Story Engine 为空。',
      ]);
    },
  );
}
