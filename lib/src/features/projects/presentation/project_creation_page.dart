import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_route.dart';
import '../../../core/ui/analysis_lab_widgets.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_profile.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_profile.dart';
import '../application/project_providers.dart';
import '../domain/writing_project.dart';

class ProjectCreationPage extends ConsumerStatefulWidget {
  const ProjectCreationPage({
    this.prefillTitle,
    this.prefillSynopsis,
    this.prefillGenreTags,
    this.prefillWordCount,
    super.key,
  });

  final String? prefillTitle;
  final String? prefillSynopsis;
  final List<String>? prefillGenreTags;
  final int? prefillWordCount;

  @override
  ConsumerState<ProjectCreationPage> createState() =>
      _ProjectCreationPageState();
}

class _ProjectCreationPageState extends ConsumerState<ProjectCreationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _languageController;
  late final TextEditingController _targetLengthController;
  late final TextEditingController _totalTargetLengthController;
  late final TextEditingController _perspectiveController;
  String? _selectedProviderId;
  String? _selectedModelName;
  String? _selectedStyleProfileId;
  String? _selectedPlotProfileId;
  bool _useHighQualityGeneration = true;
  bool _saving = false;
  String? _errorMessage;

  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prefillTitle ?? '');
    _descriptionController = TextEditingController(
      text: widget.prefillSynopsis ?? '',
    );
    _languageController = TextEditingController(text: defaultProjectLanguage);
    _targetLengthController = TextEditingController(
      text: defaultProjectTargetLength.toString(),
    );
    _totalTargetLengthController = TextEditingController(
      text: (widget.prefillWordCount ?? defaultProjectTotalTargetLength)
          .toString(),
    );
    _perspectiveController = TextEditingController(
      text: defaultProjectNarrativePerspective,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _languageController.dispose();
    _targetLengthController.dispose();
    _totalTargetLengthController.dispose();
    _perspectiveController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final providerId = _selectedProviderId?.trim();
    final modelName = _selectedModelName?.trim();
    if (providerId == null || providerId.isEmpty) {
      setState(() => _errorMessage = '请先选择 Provider。');
      return;
    }
    if (modelName == null || modelName.isEmpty) {
      setState(() => _errorMessage = '请先选择模型。');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final newId = _uuid.v4();
      final repo = ref.read(projectRepositoryProvider);
      await repo.saveProject(
        id: newId,
        input: WritingProjectInput(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: ProjectStatus.active,
          defaultProviderId: providerId,
          defaultModelName: modelName,
          styleProfileId: _selectedStyleProfileId?.trim().isNotEmpty == true
              ? _selectedStyleProfileId
              : null,
          plotProfileId: _selectedPlotProfileId?.trim().isNotEmpty == true
              ? _selectedPlotProfileId
              : null,
          language: _languageController.text.trim(),
          targetLength:
              int.tryParse(_targetLengthController.text.trim()) ??
              defaultProjectTargetLength,
          totalTargetLength:
              int.tryParse(_totalTargetLengthController.text.trim()) ??
              defaultProjectTotalTargetLength,
          narrativePerspective: _perspectiveController.text.trim(),
          useHighQualityGeneration: _useHighQualityGeneration,
        ),
      );
      if (mounted) {
        context.go('/projects/$newId/workshop');
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = '创建失败：$error';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerConfigsProvider);
    final styleProfiles = ref.watch(styleProfilesProvider);
    final plotProfiles = ref.watch(plotProfilesProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasPreFill = widget.prefillTitle != null;

    return PersonaPage(
      eyebrow: '新建项目',
      title: hasPreFill ? '基于推荐创建项目' : '创建新项目',
      description: hasPreFill
          ? '已根据 AI 推荐预填了标题、简介和字数目标，确认后即可创建。'
          : '填写基本信息创建写作项目，后续可在项目设置中调整更多参数。',
      maxWidth: 720,
      actions: [
        OutlinedButton.icon(
          onPressed: _saving ? null : () => context.go(AppRoute.projects.path),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回'),
        ),
      ],
      children: [
        providers.when(
          data: (providerItems) => styleProfiles.when(
            data: (styleItems) => plotProfiles.when(
              data: (plotItems) {
                _syncSelections(providerItems);
                return _buildForm(
                  providerItems,
                  styleItems,
                  plotItems,
                  textTheme,
                  colorScheme,
                );
              },
              error: (error, _) =>
                  InlineError(message: '无法加载 Plot Profiles：$error'),
              loading: () => const _FormLoading(),
            ),
            error: (error, _) =>
                InlineError(message: '无法加载 Style Profiles：$error'),
            loading: () => const _FormLoading(),
          ),
          error: (error, _) => InlineError(message: '无法加载 Providers：$error'),
          loading: () => const _FormLoading(),
        ),
      ],
    );
  }

  void _syncSelections(List<ProviderConfig> providers) {
    // Auto-select first enabled provider if none selected.
    if (_selectedProviderId == null && providers.isNotEmpty) {
      final enabled = providers.where((p) => p.isEnabled);
      final provider = enabled.isEmpty ? providers.first : enabled.first;
      _selectedProviderId = provider.id;
      _selectedModelName = provider.defaultModel;
    }
    // Reset if selected provider was removed.
    if (_selectedProviderId != null &&
        !providers.any((p) => p.id == _selectedProviderId)) {
      _selectedProviderId = providers.isEmpty ? null : providers.first.id;
      _selectedModelName = providers.isEmpty
          ? null
          : providers.first.defaultModel;
    }
    // Reset model if not in current provider's model list.
    final selected = providers.cast<ProviderConfig?>().firstWhere(
      (p) => p!.id == _selectedProviderId,
      orElse: () => null,
    );
    if (selected != null && !selected.modelNames.contains(_selectedModelName)) {
      _selectedModelName = selected.defaultModel;
    }
  }

  Widget _buildForm(
    List<ProviderConfig> providerItems,
    List<StyleProfile> styleItems,
    List<PlotProfile> plotItems,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final selectedProvider = providerItems.cast<ProviderConfig?>().firstWhere(
      (p) => p!.id == _selectedProviderId,
      orElse: () => null,
    );
    final modelNames = selectedProvider?.modelNames ?? const <String>[];
    final canSave = providerItems.isNotEmpty && !_saving;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Error ---
          if (_errorMessage != null) ...[
            InlineError(message: _errorMessage!),
            const SizedBox(height: 16),
          ],

          // --- Basic info section ---
          _FormSection(
            title: '基本信息',
            description: '标题为必填项，简介和标签可稍后补充。',
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '项目标题',
                  hintText: '例如：雾港纪事',
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '简介 / 一句话概念',
                  hintText: '写下项目的核心设定、主线或创作目标。',
                ),
                minLines: 4,
                maxLines: 8,
              ),
              if (widget.prefillGenreTags != null &&
                  widget.prefillGenreTags!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text('推荐标签：', style: textTheme.labelMedium),
                    for (final tag in widget.prefillGenreTags!)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            tag,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // --- Model config section ---
          _FormSection(
            title: '创作配置',
            description: '选择项目默认调用的 Provider 和模型。',
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedProviderId,
                items: [
                  for (final provider in providerItems)
                    DropdownMenuItem(
                      value: provider.id,
                      child: Text(
                        '${provider.name} · ${provider.defaultModel}${provider.isEnabled ? '' : '（停用）'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: providerItems.isEmpty
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedProviderId = value;
                            final p = providerItems.firstWhere(
                              (item) => item.id == value,
                            );
                            _selectedModelName = p.defaultModel;
                          });
                        }
                      },
                decoration: const InputDecoration(
                  labelText: '默认 Provider',
                  border: OutlineInputBorder(),
                ),
                validator: (_) =>
                    providerItems.isEmpty ? '请先在 Settings 配置 Provider' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedModelName,
                items: [
                  for (final modelName in modelNames)
                    DropdownMenuItem(
                      value: modelName,
                      child: Text(modelName, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: selectedProvider == null
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedModelName = value);
                        }
                      },
                decoration: const InputDecoration(
                  labelText: '默认模型',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              if (providerItems.isEmpty) ...[
                const SizedBox(height: 12),
                _ProviderMissingNotice(colorScheme: colorScheme),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // --- Writing parameters ---
          _FormSection(
            title: '写作参数',
            description: '项目级默认值，可在项目设置中修改。',
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final language = TextFormField(
                    controller: _languageController,
                    decoration: const InputDecoration(
                      labelText: '语言',
                      border: OutlineInputBorder(),
                    ),
                    validator: _requiredValidator,
                  );
                  final targetLength = TextFormField(
                    controller: _targetLengthController,
                    decoration: const InputDecoration(
                      labelText: '单章目标字数',
                      suffixText: '字',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _positiveIntValidator,
                  );
                  final totalTargetLength = TextFormField(
                    controller: _totalTargetLengthController,
                    decoration: const InputDecoration(
                      labelText: '全书目标字数',
                      suffixText: '字',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _positiveIntValidator,
                  );

                  if (constraints.maxWidth < 620) {
                    return Column(
                      children: [
                        language,
                        const SizedBox(height: 12),
                        targetLength,
                        const SizedBox(height: 12),
                        totalTargetLength,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: language),
                      const SizedBox(width: 12),
                      Expanded(child: targetLength),
                      const SizedBox(width: 12),
                      Expanded(child: totalTargetLength),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _perspectiveController,
                decoration: const InputDecoration(
                  labelText: '叙事视角',
                  hintText: defaultProjectNarrativePerspective,
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 8),
              _QualityGenerationSwitchRow(
                value: _useHighQualityGeneration,
                onChanged: (value) =>
                    setState(() => _useHighQualityGeneration = value),
                title: '默认使用高质量成稿链',
                subtitle: '生成章节时自动执行任务书、读感评审、必要修订和最终润色',
              ),
            ],
          ),

          // --- Optional profiles ---
          if (styleItems.isNotEmpty || plotItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _FormSection(
              title: 'Profile 挂载（可选）',
              description: '关联已有的 Style / Plot Profile，或留空后续绑定。',
              children: [
                if (styleItems.isNotEmpty) ...[
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedStyleProfileId,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('不挂载 Style Profile'),
                      ),
                      for (final profile in styleItems)
                        DropdownMenuItem<String?>(
                          value: profile.id,
                          child: Text(
                            profile.styleName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStyleProfileId = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Style Profile',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (styleItems.isNotEmpty && plotItems.isNotEmpty)
                  const SizedBox(height: 12),
                if (plotItems.isNotEmpty) ...[
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedPlotProfileId,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('不挂载 Plot Profile'),
                      ),
                      for (final profile in plotItems)
                        DropdownMenuItem<String?>(
                          value: profile.id,
                          child: Text(
                            profile.plotName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPlotProfileId = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Plot Profile',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 24),

          // --- Actions ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _saving
                    ? null
                    : () => context.go(AppRoute.projects.path),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: canSave ? _save : null,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_saving ? '创建中...' : '创建项目'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Helper widgets ---

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkbenchSectionLabel(title, major: true),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _QualityGenerationSwitchRow extends StatelessWidget {
  const _QualityGenerationSwitchRow({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.auto_fix_high_outlined,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ProviderMissingNotice extends StatelessWidget {
  const _ProviderMissingNotice({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '请先在 Settings 配置 Provider，项目需要默认 Provider 和模型才能创建。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLoading extends StatelessWidget {
  const _FormLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SkeletonBox(width: 80, height: 12),
                SizedBox(width: 14),
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Validators ---

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return '必填';
  return null;
}

String? _positiveIntValidator(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) return '请输入大于 0 的整数';
  return null;
}
