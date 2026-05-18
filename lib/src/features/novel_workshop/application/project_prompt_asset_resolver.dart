import '../../plot_lab/domain/plot_lab_repository.dart';
import '../../projects/domain/project_repository.dart';
import '../../style_lab/domain/style_lab_repository.dart';
import '../domain/writing_context.dart';

class ProjectPromptAssetResolver {
  const ProjectPromptAssetResolver({
    required ProjectRepository projectRepository,
    required StyleLabRepository styleLabRepository,
    required PlotLabRepository plotLabRepository,
  }) : _projectRepository = projectRepository,
       _styleLabRepository = styleLabRepository,
       _plotLabRepository = plotLabRepository;

  final ProjectRepository _projectRepository;
  final StyleLabRepository _styleLabRepository;
  final PlotLabRepository _plotLabRepository;

  Future<ProjectPromptAssets> resolve(String projectId) async {
    final project = await _projectRepository.findProject(projectId);
    if (project == null) {
      throw StateError('Project does not exist: $projectId');
    }

    final warnings = <String>[];
    var voiceProfileMarkdown = '';
    var storyEngineMarkdown = '';
    var plotSkeletonMarkdown = '';

    final styleProfileId = project.styleProfileId?.trim();
    if (styleProfileId == null || styleProfileId.isEmpty) {
      warnings.add('项目未绑定 Voice Profile。');
    } else {
      final styleProfile = await _styleLabRepository.findProfile(
        styleProfileId,
      );
      if (styleProfile == null) {
        warnings.add('项目绑定的 Voice Profile 不存在。');
      } else {
        voiceProfileMarkdown = styleProfile.profileMarkdown;
        warnings.addAll(
          _healthWarnings(
            label: 'Voice Profile',
            markdown: voiceProfileMarkdown,
          ),
        );
      }
    }

    final plotProfileId = project.plotProfileId?.trim();
    if (plotProfileId == null || plotProfileId.isEmpty) {
      warnings.add('项目未绑定 Story Engine。');
    } else {
      final plotProfile = await _plotLabRepository.findProfile(plotProfileId);
      if (plotProfile == null) {
        warnings.add('项目绑定的 Story Engine 不存在。');
      } else {
        storyEngineMarkdown = plotProfile.storyEngineMarkdown;
        plotSkeletonMarkdown = plotProfile.plotSkeletonMarkdown;
        warnings.addAll(
          _healthWarnings(label: 'Story Engine', markdown: storyEngineMarkdown),
        );
      }
    }

    return ProjectPromptAssets(
      voiceProfileMarkdown: voiceProfileMarkdown,
      storyEngineMarkdown: storyEngineMarkdown,
      plotSkeletonMarkdown: plotSkeletonMarkdown,
      warnings: List.unmodifiable(warnings),
    );
  }

  List<String> _healthWarnings({
    required String label,
    required String markdown,
  }) {
    final warnings = <String>[];
    final trimmed = markdown.trim();
    if (trimmed.isEmpty) {
      warnings.add('$label 为空。');
      return warnings;
    }
    if (!_hasMarkdownHeading(trimmed)) {
      warnings.add('$label 缺少 Markdown 标题。');
    }
    if (_startsFrontMatter(trimmed) && !_hasClosingFrontMatter(trimmed)) {
      warnings.add('$label front matter 异常，已按纯 Markdown 继续使用。');
    }
    return warnings;
  }

  bool _hasMarkdownHeading(String markdown) {
    return markdown.split('\n').any((line) => line.trimLeft().startsWith('# '));
  }

  bool _startsFrontMatter(String markdown) {
    return markdown.startsWith('---\n') || markdown == '---';
  }

  bool _hasClosingFrontMatter(String markdown) {
    final lines = markdown.split('\n');
    for (var index = 1; index < lines.length; index += 1) {
      if (lines[index].trim() == '---') {
        return true;
      }
    }
    return false;
  }
}
